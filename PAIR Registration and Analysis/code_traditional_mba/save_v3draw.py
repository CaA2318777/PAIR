from v3dpy.loaders import Raw
import scipy.io
import argparse
import re
import numpy as np

def format_number(num):
    # 将数字转换为字符串，保留两位小数
    str_num = f"{num:.2f}"
    # 使用正则表达式去除不必要的小数位
    str_num = re.sub(r'\.?0+$', '', str_num)
    return str_num



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
    datapath = 'Y:/xxx/xxx/Data/2024/240926_align/' + format_number(mice_num) + '/' + str(resolution) + 'um/step2_'+method1+'_mba/Warped_CCF_target/atlas_v3draw/'

    # 读取.mat文件
    ims_data  = scipy.io.loadmat('Y:/xxx/xxx/Data/2024/240926_align/' + format_number(mice_num) + '/' + str(resolution) + 'um/step2_'+method1+'_mba/' + 'ims_data.mat')
    warped_Atlas = scipy.io.loadmat(datapath + 'warped_Atlas.mat')
    mask = scipy.io.loadmat(datapath + 'mask.mat')
    my_ROI = scipy.io.loadmat(datapath + 'ROI.mat')
    boundary = scipy.io.loadmat(datapath + 'boundary.mat')

    # 假设你的三维数组在MATLAB中的名字是'yourArrayName'
    warped_Atlas = warped_Atlas['warped_Atlas']
    mask = mask['mask']
    boundary = boundary['boundary']
    my_ROI = my_ROI['ROI']
    ims_data = ims_data['ims_data']
    
    
    warped_Atlas = np.transpose(warped_Atlas, (2, 0, 1))
    mask = np.transpose(mask, (2, 0, 1))
    boundary = np.transpose(boundary, (2, 0, 1))
    my_ROI = np.transpose(my_ROI, (2, 0, 1))
    ims_data = np.transpose(ims_data, (2, 0, 1))

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
    warped_Atlas = warped_Atlas.astype(np.uint8)
    ims_data[ims_data < 50] = 0
    ims_data = ims_data/np.max(ims_data) * 600
    # ims_data = ims_data - np.min(ims_data) 
    ims_data = ims_data.astype(np.uint8)
    ims_data[ims_data > 255] = 255

    raw = Raw()
    raw.save(datapath + 'CCF_u8_xpad.v3draw', warped_Atlas)
    raw.save(datapath + 'CCF_mask.v3draw', mask)
    raw.save(datapath + 'CCF_contour.v3draw', boundary)
    raw.save(datapath + 'CCF_roi.v3draw', my_ROI)
    raw.save('Y:/xxx/xxx/Data/2024/240926_align/' + format_number(mice_num) + '/' + str(resolution) + 'um/step2_'+method1+'_mba/' + 'ims_data.v3draw', ims_data)

    
if __name__ == '__main__':
    main()




