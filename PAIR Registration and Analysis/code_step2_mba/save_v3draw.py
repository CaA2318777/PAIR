from v3dpy.loaders import Raw
import scipy.io
import argparse
import re
import numpy as np
from skimage import exposure  # 需要安装 scikit-image


def format_number(num):
    # 将数字转换为字符串，保留两位小数
    str_num = f"{num:.2f}"
    # 使用正则表达式去除不必要的小数位
    str_num = re.sub(r'\.?0+$', '', str_num)
    return str_num


def histogram_equalization_global(data):
    # 将三维数据展平
    flat_data = data.ravel()
    
    # 计算直方图均衡化
    equalized_flat = exposure.equalize_hist(flat_data)  # 输出范围为 [0, 1]
    
    # 重塑回原始形状并映射到 [0, 255]
    equalized_data = (equalized_flat.reshape(data.shape) * 255).astype(np.uint8)
    return equalized_data

import h5py
import os
# 定义一个函数来检查文件格式
def is_hdf5(file_path):
    try:
        with h5py.File(file_path, 'r') as f:
            return True
    except OSError:
        return False


# 根据格式读取文件
def load_data(file_path, key):
    if is_hdf5(file_path):
        with h5py.File(file_path, 'r') as f:
            return f[key][:]
    else:
        return scipy.io.loadmat(file_path)[key]
    


def main():

    # 创建 ArgumentParser 对象
    parser = argparse.ArgumentParser(description='Get resolution and mouse_num.')
    # 添加 -r 参数
    parser.add_argument('-r', type=int, required=True, help='The value of resolution.')
    # 添加 -num 参数
    parser.add_argument('-num', type=float, required=True, help='The value of num.')
    # 解析命令行参数
    parser.add_argument('-method1', type=str, required=True, help='The value of num.')
    # 解析命令行参数
    args = parser.parse_args()

    mice_num =  args.num
    resolution = args.r 
    method1 = args.method1


    # mice_num = 259
    # resolution = 25
    # method1 = 'ants'

    datapath = 'Y:/xxx/xxx/Data/2024/240926_align/' + format_number(mice_num) + '/' + str(resolution) + 'um/step2_'+method1+'_mba/Warped_CCF_target/atlas_v3draw/'




    # 设置路径和文件名
    base_path = 'Y:/xxx/xxx/Data/2024/240926_align/'
    mice_path = base_path + format_number(mice_num) + '/' + str(resolution) + 'um/step2_' + method1 + '_mba/'


    # 文件路径
    ims_file = os.path.join(mice_path, 'ims_data.mat')
    atlas_file = os.path.join(datapath, 'warped_Atlas.mat')
    mask_file = os.path.join(datapath, 'mask.mat')
    roi_file = os.path.join(datapath, 'ROI.mat')
    boundary_file = os.path.join(datapath, 'boundary.mat')

    # 加载数据
    ims_data = load_data(ims_file, 'ims_data')
    warped_Atlas = load_data(atlas_file, 'warped_Atlas')
    mask = load_data(mask_file, 'mask')
    my_ROI = load_data(roi_file, 'ROI')
    boundary = load_data(boundary_file, 'boundary')



    # # 读取.mat文件
    # ims_data  = scipy.io.loadmat('Y:/xxx/xxx/Data/2024/240926_align/' + format_number(mice_num) + '/' + str(resolution) + 'um/step2_'+method1+'_mba/' + 'ims_data.mat')
    # warped_Atlas = scipy.io.loadmat(datapath + 'warped_Atlas.mat')
    # mask = scipy.io.loadmat(datapath + 'mask.mat')
    # my_ROI = scipy.io.loadmat(datapath + 'ROI.mat')
    # boundary = scipy.io.loadmat(datapath + 'boundary.mat')

    # # 假设你的三维数组在MATLAB中的名字是'yourArrayName'
    # warped_Atlas = warped_Atlas['warped_Atlas']
    # mask = mask['mask']
    # boundary = boundary['boundary']
    # my_ROI = my_ROI['ROI']
    # ims_data = ims_data['ims_data']
    
    warped_Atlas = np.transpose(warped_Atlas, (0, 2, 1))
    mask = np.transpose(mask, (0, 2, 1))
    boundary = np.transpose(boundary, (0, 2, 1))
    my_ROI = np.transpose(my_ROI, (0, 2, 1))
    ims_data = np.transpose(ims_data, (0, 2, 1))


    # warped_Atlas = np.transpose(warped_Atlas, (2, 0, 1))
    # mask = np.transpose(mask, (2, 0, 1))
    # boundary = np.transpose(boundary, (2, 0, 1))
    # my_ROI = np.transpose(my_ROI, (2, 0, 1))
    # ims_data = np.transpose(ims_data, (2, 0, 1))

    warped_Atlas = np.flip(warped_Atlas, axis=1)
    mask = np.flip(mask, axis=1)
    boundary = np.flip(boundary, axis=1)
    my_ROI = np.flip(my_ROI, axis=1)
    ims_data = np.flip(ims_data, axis=1)

    warped_Atlas = np.expand_dims(warped_Atlas, axis=0)
    mask = np.expand_dims(mask, axis=0)
    my_ROI = np.expand_dims(my_ROI, axis=0)
    boundary = np.expand_dims(boundary, axis=0)
    ims_data = np.expand_dims(ims_data, axis=0)


    print(warped_Atlas.shape)
    


    ims_data = ims_data/np.max(ims_data) * 400
    ims_data = ims_data.astype(np.uint8)
    ims_data[ims_data > 255] = 255

    # warped_Atlas = warped_Atlas/np.max(warped_Atlas) * 255
    warped_Atlas = warped_Atlas.astype(np.uint8)
    warped_Atlas[warped_Atlas > 255] = 255


    mask = mask.astype(np.uint8)
    boundary = boundary.astype(np.uint8)
    my_ROI = my_ROI.astype(np.uint8)


    # ims_data[ims_data<0] = 0
    # equalized_ims_data_global = histogram_equalization_global(ims_data)
    # ims_data = equalized_ims_data_global.astype(np.uint8)
    # print(f"Equalized global data shape: {equalized_ims_data_global.shape}")


    raw = Raw()
    raw.save(datapath + 'CCF_u8_xpad.v3draw', warped_Atlas)

   
    raw.save(datapath + 'CCF_mask.v3draw', mask)
    raw.save(datapath + 'CCF_contour.v3draw', boundary)
    raw.save(datapath + 'CCF_roi.v3draw', my_ROI)
    raw.save('Y:/xxx/xxx/Data/2024/240926_align/' + format_number(mice_num) + '/' + str(resolution) + 'um/step2_'+method1+'_mba/' + 'ims_data.v3draw', ims_data)

    
if __name__ == '__main__':
    main()




