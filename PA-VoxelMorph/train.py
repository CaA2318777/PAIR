""" This is a PA-VoxelMorph training Implementation on the PA-Allen dataset.

    Dataset is split into:
    24 for training 
    5 for validation
    5 for test

    Dataset is saved in .h5 file with format below:
    train.h5/
        vol_index/
                 subject/
                        vol
                        affine
                 target/
                        vol
                        affine

    Even saving as numpy arrays, memory usage is still quite small

    upsample: whether upsample the volumes from 75um resolution to 25 um resolution

"""

# import necessary packages
import sys
import os 
import time
os.environ['NEURITE_BACKEND'] = 'pytorch'
os.environ['VXM_BACKEND'] = 'pytorch'
import voxelmorph as vxm 
import torch
from torch.utils.data import DataLoader
from torch.optim import lr_scheduler
import numpy as np
from utils import dataset
import matplotlib.pyplot as plt

# set multiple gpus to use
# os.environ["CUDA_VISIBLE_DEVICES"] = "0,1,2,3,4,5"

# directory path
file_path = '/JCY/Registration'
train_data_path = file_path+'/new_train.h5'
test_data_path = file_path+'/new_test.h5'
validation_data_path = file_path+'/new_evaluation.h5'

# whether upsample the volumes from 75um resolution to 25 um resolution
upsample = False
default_shape = (160, 208, 112)
if upsample:
    inshape = tuple(i*3 for i in default_shape)
else:
    inshape = default_shape

# train and validation dataset 
train_dataset = dataset.HDF5Dataset(file_path=train_data_path, upsample=upsample)
validation_dataset = dataset.HDF5Dataset(file_path=validation_data_path, upsample=upsample)

# collate_fn function
def numpy_collate(batch):
    # batch is a list of tuples (invols, outvols)
    invols, outvols = zip(*batch)
        
    # Convert each element of invols and outvols from tensors to numpy arrays
    invols_numpy =  [np.stack([lst[i] for lst in invols], axis=0) for i in range(len(invols[0]))]
    outvols_numpy = [np.stack([lst[i] for lst in outvols], axis=0) for i in range(len(outvols[0]))]

    return(invols_numpy, outvols_numpy)

# train, validation dataloader and accumulation steps (true batch size = batch_size * accumulation_steps)
train_loader = DataLoader(train_dataset, batch_size=2, shuffle=False, collate_fn=numpy_collate)
validation_loader = DataLoader(validation_dataset, batch_size=5, shuffle=False)
accumulation_steps = 2

# prepare model directory
model_dir = file_path+'/checkpoints/vxm_checkpoints'
os.makedirs(model_dir, exist_ok=True)

# device handling
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# enabling cudnn determinism appears to speed up training by a lot
torch.backends.cudnn.deterministic = True

# certain random seed
seed = 42
torch.manual_seed(seed)
np.random.seed(seed)
if torch.cuda.is_available():
    torch.cuda.manual_seed_all(seed)

# training parameters
int_steps = 7
int_downsize = 2
lr = 1e-4
weight = 1
initial_epoch = 0
epochs = 2000

# unet architecture
enc_nf = [16, 32, 32, 32]
dec_nf = [32, 32, 32, 32, 32, 16, 16]
model = vxm.networks.VxmDense(
    inshape=inshape,
    nb_unet_features=[enc_nf, dec_nf],
    bidir=False,
    int_steps=7,
    int_downsize=2
    )
#model = model.half()
#model = torch.nn.DataParallel(model)
#model.save = model.module.save

#model_parameters = sum(p.numel() for p in model.parameters())
#print(f"模型参数数量: {model_parameters}")
#print(f"模型参数所占空间 (float32): {model_parameters * 4 / (1024 ** 2):.2f} MB")
#print(f"模型参数所占空间 (float16): {model_parameters * 2 / (1024 ** 2):.2f} MB")

before_model_to_device_memory = torch.cuda.memory_allocated()
print(f'Memory before model:{before_model_to_device_memory/(1024 ** 2):.2f} MB')

# prepare the model for training and send to device
model.to(device)
after_model_to_device_memory = torch.cuda.memory_allocated()
model_used_memory = after_model_to_device_memory - before_model_to_device_memory
print(f'Memory used for model: {model_used_memory / (1024 ** 2):.2f} MB')

# set optimizer and learning rate scheduler
optimizer = torch.optim.Adam(model.parameters(), lr=lr, weight_decay=1e-4)
scheduler = lr_scheduler.StepLR(optimizer, step_size=4800, gamma=0.1)

# prepare image loss
image_loss_func = vxm.losses.NCC().loss
losses = [image_loss_func]
weights = [1]

# prepare deformation loss
losses += [vxm.losses.Grad('l2', loss_mult=int_downsize).loss]
weights += [weight]

# prepare list to store loss for plotting
epoch_total_list = []
epoch_similarity_loss_list = []
epoch_deformation_loss_list = []

validation_loss_list = []
validation_similarity_loss_list = []
validation_deformation_loss_list = []

# training loop
for epoch in range(initial_epoch, epochs):
    model.train()
    optimizer.zero_grad()
    running_loss = 0.0
    running_similarity_loss = 0.0
    running_deformation_loss = 0.0

     # save model checkpoint
    if epoch % 5 == 0:
        model.save(os.path.join(model_dir, '%04d.pt' % epoch))

    epoch_total_loss = []
    epoch_similarity_loss = []
    epoch_deformation_loss = []

    epoch_validation_loss = []
    epoch_validation_similarity_loss = []
    epoch_validation_deformation_loss =[]


    i = 0
    for invols,outvols in train_loader:
        batch_start_time = time.time()
        before_loading_data_memory = torch.cuda.memory_allocated()
        inputs = [torch.from_numpy(d).to(device).permute(0, 4, 1, 2, 3) for d in invols]
        y_true = [torch.from_numpy(d).to(device).permute(0, 4, 1, 2, 3) for d in outvols]
        after_loading_data_memory = torch.cuda.memory_allocated()
        print(f'Memory used for loading one batch data: {(after_loading_data_memory-before_loading_data_memory)/(1024 ** 2):.2f} MB')

        torch.cuda.empty_cache()

        data_loading_time = time.time()
        print(f"load data to device took{data_loading_time-batch_start_time: .2f} seconds")
        
        before_forward_memory = torch.cuda.memory_allocated()

        # run inputs through the model to produce a warped image and flow field
        y_pred = model(*inputs)

        torch.cuda.empty_cache()

        #print(torch.cuda.memory_summary(device=device))

        after_forward_memory = torch.cuda.memory_allocated()
        print(f'Memory used for forward model: {(after_forward_memory-before_forward_memory)/(1024 ** 2):.2f} MB')

        go_through_model_time = time.time()
        print(f"go through the model took {go_through_model_time-data_loading_time: .2f} seconds")

        # calculate total loss
        before_loss_cal_memory = torch.cuda.memory_allocated()
        loss = 0
        loss_list = []
        for n, loss_function in enumerate(losses):
            curr_loss = loss_function(y_true[n], y_pred[n]) * weights[n]
            loss_list.append(curr_loss.item())
            loss += curr_loss
        loss = loss / accumulation_steps
        
        after_loss_cal_memory = torch.cuda.memory_allocated()
        print(after_loss_cal_memory)
        print(f'Memory used for calculating loss: {(after_loss_cal_memory-before_loss_cal_memory)/(1024 ** 2):.2f} MB')
        loss.backward()
        
        after_loss_backward_memory = torch.cuda.memory_allocated()
        print(after_loss_backward_memory)
        print(f'Memory used for loss backward: {(after_loss_backward_memory-after_loss_cal_memory)/(1024 ** 2):.2f} MB')
        running_loss+=loss.item()
        running_similarity_loss += loss_list[0] / accumulation_steps
        running_deformation_loss += loss_list[1] / accumulation_steps
        
        # backpropagate and optimize
        before_step_memory = torch.cuda.memory_allocated()
        if (i + 1)%accumulation_steps == 0:
            torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)
            optimizer.step()
            optimizer.zero_grad()

            epoch_total_loss.append(running_loss)
            epoch_similarity_loss.append(running_similarity_loss)
            epoch_deformation_loss.append(running_deformation_loss)

            print(f"Training Epoch [{epoch+1}/{epochs}], Step [{i+1}/{len(train_loader)}], Step Total Loss: {running_loss:.4e}, Step Similarity Loss: {running_similarity_loss:.4e}, Step Deformation Loss: {running_deformation_loss:.4e}")
            running_loss = 0.0
            running_similarity_loss = 0.0
            running_deformation_loss = 0.0
        after_step_memory = torch.cuda.memory_allocated()
        print(f'Memory used by backpropagation: {(after_step_memory-before_step_memory)/(1024**2):.2f} MB')

        # Step the learning rate scheduler at the end of each epoch
        scheduler.step()

        # print the learning rate at each epoch
        print(f"Epoch [{epoch+1}], Learning Rate: {scheduler.get_last_lr()[0]}")
        i += 1

    torch.cuda.empty_cache()
    
    before_model_validation_memory = torch.cuda.memory_allocated()
    print(f'Memory before model validation:{before_model_validation_memory/(1024 ** 2):.2f} MB')

    # model evaluation
    model.eval()
    with torch.no_grad():
        for val_invols,val_outvols in validation_loader:
            val_batch_start_time = time.time()
            before_loading_data_memory = torch.cuda.memory_allocated()
            val_inputs = [d.to(device).permute(0, 4, 1, 2, 3) for d in val_invols]
            val_y_true = [d.to(device).permute(0, 4, 1, 2, 3) for d in val_outvols]
            after_loading_data_memory = torch.cuda.memory_allocated()
            print(f'Memory used for loading one batch validation data: {(after_loading_data_memory-before_loading_data_memory)/(1024 ** 2):.2f} MB')
            val_data_loading_time = time.time()
            print(f"load validation data to device took {val_data_loading_time-val_batch_start_time: .2f} seconds")
            before_forward_memory = torch.cuda.memory_allocated()
            val_y_pred = model(*val_inputs)
            after_forward_memory = torch.cuda.memory_allocated()
            print(f'Memory used for forward model: {(after_forward_memory-before_forward_memory)/(1024 ** 2):.2f} MB')
            val_through_model_time = time.time()
            print(f"validation data through model took {val_through_model_time-val_data_loading_time: .2f} seconds")
            before_loss_cal_memory = torch.cuda.memory_allocated()
            val_loss = 0
            val_loss_list = []
            for n, loss_function in enumerate(losses):
                curr_loss = loss_function(val_y_true[n], val_y_pred[n]) * weights[n]
                val_loss_list.append(curr_loss.item())
                val_loss += curr_loss
            epoch_validation_loss.append(val_loss.cpu())
            epoch_validation_similarity_loss.append(val_loss_list[0])
            epoch_validation_deformation_loss.append(val_loss_list[1])
            after_loss_cal_memory = torch.cuda.memory_allocated()
            print(f"Epoch Summary: Training Epoch[{epoch+1}/{epoch}], Epoch Total Loss: {np.mean(epoch_total_loss):.4e}, Epoch Similarity Loss: {np.mean(epoch_similarity_loss):.4e}, Epoch Deformation Loss: {np.mean(epoch_deformation_loss):.4e}", flush=True)
            print(f"Validation Total Loss: {np.mean(epoch_validation_loss):.4e}, Validation Similarity Loss: {np.mean(epoch_validation_similarity_loss):.4e}, Validation Deformation Loss: {np.mean(epoch_deformation_loss):.4e}", flush=True)
            print(after_loss_cal_memory)
            print(f'Memory used for calculating loss: {(after_loss_cal_memory-before_loss_cal_memory)/(1024 ** 2):.2f} MB')

    epoch_total_list.append(np.mean(epoch_total_loss))
    epoch_similarity_loss_list.append(np.mean(epoch_similarity_loss))
    epoch_deformation_loss_list.append(np.mean(epoch_deformation_loss))

    validation_loss_list.append(np.mean(epoch_validation_loss))
    validation_similarity_loss_list.append(np.mean(epoch_validation_similarity_loss))
    validation_deformation_loss_list.append(np.mean(epoch_validation_deformation_loss))

# save model checkpoints
model.save(os.path.join(model_dir, '%04d.pt' % epochs))

# start ploting
print('models saved, now start generating plots')

epochs = range(1, len(epoch_total_list)+1)

# training-validation loss plot
plt.figure(figsize=(12,12))
plt.plot(epochs, epoch_total_list, label = 'Training')
plt.plot(epochs, validation_loss_list, label = 'Validation')
plt.legend()
plt.title('Training and Validation Losses')
plt.xlabel('Epochs')
plt.ylabel('Loss')

# save the plot
plt.savefig('/data/bml/JCY/Registration/plot/training_and_validation_loss.png', dpi=300)
plt.close()

# training total loss plot
plt.figure(figsize=(12,12))
plt.plot(epochs, epoch_total_list)
plt.title('Training Total Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')

# save the plot
plt.savefig('/data/bml/JCY/Registration/plot/training_total_loss.png', dpi=300)
plt.close()

# training similarity loss plot
plt.figure(figsize=(12,12))
plt.plot(epochs, epoch_similarity_loss_list)
plt.title('Training Similarity Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')

# save the plot
plt.savefig('/data/bml/JCY/Registration/plot/training_similarity_loss.png', dpi=300)
plt.close()

# training deformation loss plot
plt.figure(figsize=(12,12))
plt.plot(epochs, epoch_deformation_loss_list)
plt.title('Training Deformation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')

# save the plot
plt.savefig('/data/bml/JCY/Registration/plot/training_deformation_loss.png', dpi=300)
plt.close()

# validation loss plot
plt.figure(figsize=(12,12))
plt.plot(epochs, validation_loss_list)
plt.title('Validation Total Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')

# save the plot
plt.savefig('/data/bml/JCY/Registration/plot/validation_total_loss.png', dpi=300)
plt.close()

# validation similarity loss plot
plt.figure(figsize=(12,12))
plt.plot(epochs, validation_similarity_loss_list)
plt.title('Validation Similarity Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')

# save the plot
plt.savefig('/data/bml/JCY/Registration/plot/validation_similarity_loss.png', dpi=300)
plt.close()

# validation deformation loss plot
plt.figure(figsize=(12,12))
plt.plot(epochs, validation_deformation_loss_list)
plt.title('Validation Deformation Loss')
plt.xlabel('Epochs')
plt.ylabel('Loss')

# save the plot
plt.savefig('/data/bml/JCY/Registration/plot/validation_deformation_loss.png', dpi=300)
plt.close()
            
