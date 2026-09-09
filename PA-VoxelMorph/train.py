# import necessary libraries
import os
import time
os.environ['NEURITE_BACKEND'] = 'pytorch'
os.environ['VXM_BACKEND'] = 'pytorch'
import voxelmorph as vxm
import torch
import numpy as np
import glob
import matplotlib.pyplot as plt

seed = 42
torch.manual_seed(seed)
np.random.seed(seed)
if torch.cuda.is_available():
    torch.cuda.manual_seed_all(seed)

#volume generator
def volgen(
    vol_names,
    batch_size=1,
    segs=None,
    np_var='vol',
    pad_shape=None,
    resize_factor=1,
    add_feat_axis=True
):
    """
    Base generator for random volume loading. Volumes can be passed as a path to
    the parent directory, a glob pattern, a list of file paths, or a list of
    preloaded volumes. Corresponding segmentations are additionally loaded if
    `segs` is provided as a list (of file paths or preloaded segmentations) or set
    to True. If `segs` is True, npz files with variable names 'vol' and 'seg' are
    expected. Passing in preloaded volumes (with optional preloaded segmentations)
    allows volumes preloaded in memory to be passed to a generator.

    Parameters:
        vol_names: Path, glob pattern, list of volume files to load, or list of
            preloaded volumes.
        batch_size: Batch size. Default is 1.
        segs: Loads corresponding segmentations. Default is None.
        np_var: Name of the volume variable if loading npz files. Default is 'vol'.
        pad_shape: Zero-pads loaded volumes to a given shape. Default is None.
        resize_factor: Volume resize factor. Default is 1.
        add_feat_axis: Load volume arrays with added feature axis. Default is True.
    """

    # convert glob path to filenames
    if isinstance(vol_names, str):
        if os.path.isdir(vol_names):
            vol_names = os.path.join(vol_names, '*')
        vol_names = glob.glob(vol_names)

    if isinstance(segs, list) and len(segs) != len(vol_names):
        raise ValueError('Number of image files must match number of seg files.')

    while True:
        # generate [batchsize] random image indices
        indices = np.random.randint(len(vol_names), size=batch_size)
        print(indices)

        # load volumes and concatenate
        load_params = dict(np_var=np_var, add_batch_axis=True, add_feat_axis=add_feat_axis,
                           pad_shape=pad_shape, resize_factor=resize_factor)
        imgs = [vxm.py.utils.load_volfile(vol_names[i], **load_params) for i in indices]
        vols = [np.concatenate(imgs, axis=0)]

        # optionally load segmentations and concatenate
        if segs is True:
            # assume inputs are npz files with 'seg' key
            load_params['np_var'] = 'seg'  # be sure to load seg
            s = [vxm.py.utils.load_volfile(vol_names[i], **load_params) for i in indices]
            vols.append(np.concatenate(s, axis=0))
        elif isinstance(segs, list):
            # assume segs is a corresponding list of files or preloaded volumes
            s = [vxm.py.utils.load_volfile(segs[i], **load_params) for i in indices]
            vols.append(np.concatenate(s, axis=0))

        yield indices,tuple(vols)

#scan-to-scan generator 
def atlas_to_scan(vol_names, atlas, bidir=False, batch_size=1, no_warp=False, segs=None, **kwargs):
    """
    Generator for atlas-to-scan registration.


    Parameters:
        vol_names: List of volume files to load, or list of preloaded volumes.
        atlas: Atlas volume data.
        bidir: Yield input image as output for bidirectional models. Default is False.
        batch_size: Batch size. Default is 1.
        no_warp: Excludes null warp in output list if set to True (for affine training). 
            Default is False.
        segs: Load segmentations as output, for supervised training. Forwarded to the
            internal volgen generator. Default is None.
        kwargs: Forwarded to the internal volgen generator.
    """
    shape = atlas.shape[1:-1]
    zeros = np.zeros((batch_size, *shape, len(shape)))
    gen = volgen(vol_names, batch_size=batch_size, segs=segs, **kwargs)
    while True:
        if batch_size == 1:
            indices, res = next(gen)
            indices_str = ''.join(map(str,indices+1))
            atlas = vxm.py.utils.load_volfile('/data/bml/JCY/Registration/Affine_Aligned/normalized_allen_'+indices_str+'.nii', np_var='vol',
                                      add_batch_axis=True, add_feat_axis=True)
            atlas = np.repeat(atlas, batch_size, axis=0)
            scan = res[0]
            invols = [atlas, scan]
            if not segs:
                outvols = [atlas, scan] if bidir else [scan]
            else:
                seg = res[1]
                outvols = [seg, scan] if bidir else [seg]
            if not no_warp:
                outvols.append(zeros)
            yield indices,(invols, outvols)
        else:
            indices, res = next(gen)
            load_params = dict(np_var='vol', add_batch_axis=True, add_feat_axis=True,
                           pad_shape=None)
            atlas_imgs = [vxm.py.utils.load_volfile(vol_names[i].replace('pa','allen'), **load_params) for i in indices]
            atlas_vols = tuple([np.concatenate(atlas_imgs, axis=0)])
            atlas = atlas_vols[0]
            scan = res[0]
            invols = [atlas, scan]
            if not segs:
                outvols = [atlas, scan] if bidir else [scan]
            else:
                seg = res[1]
                outvols = [seg, scan] if bidir else [seg]
            if not no_warp:
                outvols.append(zeros)
            yield indices,(invols, outvols)

            

# prepare training data
batch_size = 4
with open('/data/bml/JCY/Registration/Affine_Aligned/train_images.txt','r') as file:
    suffix = '.nii'
    content = file.readlines()
filelist = [x.strip() for x in content if x.strip()]
if suffix is not None:
        filelist = ['/data/bml/JCY/Registration/Affine_Aligned/'+f + suffix for f in filelist]
require_atlas = True
if require_atlas:
    atlas = vxm.py.utils.load_volfile('/data/bml/JCY/Registration/Affine_Aligned/normalized_allen_1.nii', np_var='vol',
                                      add_batch_axis=True, add_feat_axis=True)
    generator = atlas_to_scan(filelist, atlas,
                                             batch_size=batch_size, bidir=False,
                                             add_feat_axis=True, segs = False)
    
# extract shape from sampled input
inshape = next(generator)[1][0][0].shape[1:-1]

# prepare validation data
with open('/data/bml/JCY/Registration/Affine_Aligned/validation_images.txt','r') as file_val:
    suffix = '.nii'
    content_val = file_val.readlines()
filelist_val = [x.strip() for x in content_val if x.strip()]
filelist_val = ['/data/bml/JCY/Registration/Affine_Aligned/' +f + suffix for f in filelist_val]
load_val_params = dict(np_var='vol', add_batch_axis=True, add_feat_axis=True,)
val_imgs = [vxm.py.utils.load_volfile(filelist_val[i], **load_val_params) for i in range(len(filelist_val))]
val_vols = tuple([np.concatenate(val_imgs, axis=0)])[0]

load_params = dict(np_var='vol', add_batch_axis=True, add_feat_axis=True,)
val_atlas_imgs = [vxm.py.utils.load_volfile(filelist_val[i].replace('pa','allen'), **load_params) for i in range(len(filelist_val))]
val_atlas_vols = tuple([np.concatenate(val_atlas_imgs, axis=0)])
val_atlas = val_atlas_vols[0]

inputs = [val_atlas, val_vols]
outputs = [val_vols]
outputs.append(np.zeros((len(filelist_val), *inshape, len(inshape))))
input_val = [inputs, outputs]

val_inputs, val_y_true = input_val

# prepare model folder
model_dir = '/data/bml/JCY/Registration/checkpoints'
os.makedirs(model_dir, exist_ok=True)

# device handling
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
val_inputs = [torch.from_numpy(d).float().permute(0, 4, 1, 2, 3) for d in val_inputs]
val_y_true = [torch.from_numpy(d).float().permute(0, 4, 1, 2, 3) for d in val_y_true]

# enabling cudnn determinism appears to speed up training by a lot
torch.backends.cudnn.deterministic = True

# training parameters
int_steps = 7
int_downsize = 2
lr = 1e-4
weight = 1
initial_epoch = 0
epochs = 1000
steps_per_epoch = 1

# unet architecture
enc_nf = [16, 32, 32, 32]
dec_nf = [32, 32, 32, 32, 32, 16, 16]
model = vxm.networks.VxmDense(
    inshape=inshape,
    nb_unet_features=[enc_nf, dec_nf],
    bidir=False,
    int_steps= 7,
    int_downsize=2
    )
#model.transformer = nnSpatialTransformer(inshape)

# prepare the model for training and send to device
model.to(device)


# set optimizer
optimizer = torch.optim.Adam(model.parameters(), lr=lr, weight_decay=1e-4)

# prepare image loss
image_loss_func = vxm.losses.NCC().loss
losses = [image_loss_func]
weights = [1]

# prepare deformation loss
losses += [vxm.losses.Grad('l2', loss_mult=int_downsize).loss]
weights += [weight]

#train
image_number_list=[] # list to store image number of each batch (batch = 1)
epoch_total_loss_list = [] # list to store the total loss of each epoch
epoch_similarity_loss_list = [] # list to store the similarity loss of each epoch
epoch_deformation_loss_list = [] # list to store the deformation loss of each epoch
validation_loss_list = [] # list to store the total loss of validation dataset each epoch
validation_similarity_loss_list = [] # list to store the similarity loss of validatation dataset each epoch
validation_deformation_loss_list =[] # list to store the deformation loss of validataion dataset each epoch

# training loops
for epoch in range(initial_epoch, epochs):

    model.train()

    # save model checkpoint
    if epoch % 5 == 0:
        model.save(os.path.join(model_dir, '%04d.pt' % epoch))

    epoch_loss = [] # store the list of loss for each step in one specific epoch
    epoch_total_loss = [] # store the total loss for each step in one specific epoch
    epoch_step_time = [] # store the time used for each step in one specific epoch
    
    val_epoch_loss = [] # store the list of loss for the validation dataset for each step in one specific epoch
    val_epoch_total_loss = [] # store the total loss for the validation dataset for each step in one specific epoch
    val_step_time = [] # store the time used for the validation datset for each step in one specific epoch

    for step in range(steps_per_epoch):

        step_start_time = time.time()

        # generate inputs (and true outputs) and convert them to tensors
        indices,(inputs, y_true)= next(generator)
        if batch_size == 1 :
            image_number_list.append(indices.item())
        else:
            image_number_list.append(indices)

        inputs = [torch.from_numpy(d).to(device).float().permute(0, 4, 1, 2, 3) for d in inputs]
        y_true = [torch.from_numpy(d).to(device).float().permute(0, 4, 1, 2, 3) for d in y_true]
        data_loading_time = time.time()
        print(f"load data to device took{data_loading_time-step_start_time: .2f} seconds")

        # run inputs through the model to produce a warped image and flow field
        y_pred = model(*inputs)
        go_through_model_time = time.time()
        print(f"go through the model took {go_through_model_time-data_loading_time: .2f} seconds")

        # calculate total loss
        loss = 0
        loss_list = []
        for n, loss_function in enumerate(losses):
            curr_loss = loss_function(y_true[n], y_pred[n]) * weights[n]
            loss_list.append(curr_loss.item())
            loss += curr_loss
        epoch_similarity_loss_list.append(loss_list[0])
        epoch_deformation_loss_list.append(loss_list[1])
        loss_calculation_time = time.time()
        print(f"loss calculationt took {loss_calculation_time-go_through_model_time: .2f} seconds")

        epoch_loss.append(loss_list)
        epoch_total_loss.append(loss.item())
        epoch_total_loss_list.append(loss.item())

        # backpropagate and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        backpropagate_time = time.time()
        print(f"backpropagate took {backpropagate_time-loss_calculation_time: .2f} seconds")

        # get compute time
        epoch_step_time.append(time.time() - step_start_time)
    model.eval()
    with torch.no_grad():
        val_start_time = time.time()
        val_inputs = [item.to(device) for item in val_inputs]
        val_y_true = [item.to(device) for item in val_y_true]
        val_to_device_time = time.time()
        print(f"validation data to device took {val_to_device_time-val_start_time: .2f} seconds")
        val_y_pred = model(*val_inputs)
        val_through_model_time = time.time()
        print(f"validation data through model took {val_through_model_time-val_to_device_time: .2f} seconds")
        val_loss = 0
        val_loss_list = []
        for n, loss_function in enumerate(losses):
            curr_loss = loss_function(val_y_true[n], val_y_pred[n]) * weights[n]
            val_loss_list.append(curr_loss.item())
            val_loss += curr_loss
        val_inputs = [item.to('cpu') for item in val_inputs]
        val_y_true = [item.to('cpu') for item in val_y_true]
        val_calculate_loss_time = time.time()
        print(f"validation loss calculation took {val_calculate_loss_time-val_through_model_time: .2f} seconds")
        val_epoch_loss.append(val_loss_list)
        val_epoch_total_loss.append(val_loss.item())
        validation_loss_list.append(val_loss)
        validation_similarity_loss_list.append(val_loss_list[0])
        validation_deformation_loss_list.append(val_loss_list[1])
        val_step_time.append(time.time()-val_start_time)

    # print epoch info
    epoch_info = 'Epoch %d/%d' % (epoch + 1, epochs)
    time_info = 'training %.4f sec/step' % np.mean(epoch_step_time)
    val_time_info = 'validation %.4f sec/step' % np.mean(val_step_time)
    losses_info = ', '.join(['%.4e' % f for f in np.mean(epoch_loss, axis=0)])
    val_losses_info =', '.join(['%.4e' % f for f in np.mean(val_epoch_loss, axis=0)])
    loss_info = 'loss: %.4e  (%s)' % (np.mean(epoch_total_loss), losses_info)
    val_loss_info = 'loss: %.4e (%s)' % (np.mean(val_epoch_total_loss), val_losses_info)
    print(' - '.join((epoch_info, time_info, loss_info)), flush=True)
    print(' - '.join(('Validation', val_time_info, val_loss_info)), flush=True)

# final model save
model.save(os.path.join(model_dir, '%04d.pt' % epochs))
print('model training and validation is complete, now start to save plots')

"""
When batch size is 1, it is possible to visualize the loss change of each training image.
Under this scenario we can plot 6 figures:

training_loss.png -- loss trajectory of each training image
training_and_validation_loss.png -- loss trajectories of traning data and validation data 
training_similarity_loss.png -- similarity loss trajectory of each training image
training_deformation_loss.png -- deformation loss trajectory of each training image
validation_similarity_loss.png -- mean similarity loss trajectory of the validation data
validation_deformation_loss.png -- mean deformation loss trajectory of the validation data

When batch size is not 1, we can not track the loss change of each training image.
Under this scenario we can plot only 3 figures:

training_and_validation_loss.png -- loss trajectories of training data and validation data
validation_similarity_loss.png -- mean similarity loss trajectory of the validation data
validation_deformation_loss.png -- mean deformation loss trajectory of the validation data

"""
if batch_size == 1:
    image_epoch_loss = tuple([] for _ in range(len(filelist)))
    image_similarity_loss = tuple([] for _ in range(len(filelist)))
    image_deformation_loss = tuple([] for _ in range(len(filelist)))

    n = 0
    for i in image_number_list:
        image_epoch_loss[i].append(epoch_total_loss_list[n])
        image_similarity_loss[i].append(epoch_similarity_loss_list[n])
        image_deformation_loss[i].append(epoch_deformation_loss_list[n])  
        n = n+1

    validation_loss_list = [i.cpu() for i in validation_loss_list]
    
    names = [f"Image_{x+1}" for x in range(len(filelist))]

    # Plot Training Losses (Training Dataset)
    # Assign names to lists using a dictionary
    named_losses = {name: losses for name, losses in zip(names, image_epoch_loss)}
    plt.figure(figsize=(8,8))

    # Plot the named lists
    for name, losses in named_losses.items():
        epochs = range(1, len(losses) + 1)
        plt.plot(epochs, losses, label=name)

    # Add titles and labels
    plt.title('Training Losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend()
    
    # save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/training_loss.png', dpi=300)
    plt.close()

    # Plot Training and Validation Losses (Training Dataset and Validation Dataset)
    epochs = range(1, len(image_number_list)+1)
    plt.figure(figsize=(8,8))
    plt.plot(epochs, epoch_total_loss_list, label = 'training')
    plt.plot(epochs, validation_loss_list, label = 'validation')
    plt.title('trainning and validation losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend()

    # save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/training_and_validation_loss.png', dpi=300)
    plt.close()

    # Plot Similarity Losses (Training Dataset)
    named_losses = {name: losses for name, losses in zip(names, image_similarity_loss)}
    plt.figure(figsize=(8,8))

    # Plot the named lists
    for name, losses in named_losses.items():
        epochs = range(1, len(losses) + 1)
        plt.plot(epochs, losses, label=name)

    # Add titles and labels
    plt.title('Similarity Losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend()

    # Save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/training_similarity_loss.png', dpi=300)
    plt.close()

    # Plot the Deformation Losses (Training Dataset)
    named_losses = {name: losses for name, losses in zip(names, image_deformation_loss)}
    plt.figure(figsize=(8,8))

    # Plot the named lists
    for name, losses in named_losses.items():
        epochs = range(1, len(losses) + 1)
        plt.plot(epochs, losses, label=name)

    # Add titles and labels
    plt.title('Deformation Losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend()

    # Save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/training_deformation_loss.png', dpi=300)
    plt.close()

    # Plot the Validation Similarity Losses (Validation Dataset)
    epochs = range(1, len(image_number_list)+1)
    plt.figure(figsize=(8,8))
    plt.plot(epochs, validation_similarity_loss_list)
    plt.title('validation similarity losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')

    # Save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/validation_similarity_loss.png', dpi=300)
    plt.close()

    # Plot the Validation Deformation Losses (Validation Dataset)
    plt.figure(figsize=(8,8))
    plt.plot(epochs, validation_deformation_loss_list)
    plt.title('validation deformation losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')

    # Save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/validation_deformation_loss.png', dpi=300)
    plt.close()

else:
    validation_loss_list = [i.cpu() for i in validation_loss_list]

    # Plot Training and Validation Losses (Training Dataset and Validation Dataset)
    epochs = range(1, len(image_number_list)+1)
    plt.figure(figsize=(8,8))
    plt.plot(epochs, epoch_total_loss_list, label = 'training')
    plt.plot(epochs, validation_loss_list, label = 'validation')
    plt.title('trainning and validation losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend()

    # save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/training_and_validation_loss.png', dpi=300)
    plt.close()

    # Plot the Validation Similarity Losses (Validation Dataset)
    plt.figure(figsize=(8,8))
    plt.plot(epochs, validation_similarity_loss_list)
    plt.title('validation similarity losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')

    # Save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/validation_similarity_loss.png', dpi=300)
    plt.close()

    # Plot the Validation Deformation Losses (Validation Dataset)
    plt.figure(figsize=(8,8))
    plt.plot(epochs, validation_deformation_loss_list)
    plt.title('validation deformation losses')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')

    # Save the plot
    plt.savefig('/data/bml/JCY/Registration/plot/validation_deformation_loss.png', dpi=300)
    plt.close()
