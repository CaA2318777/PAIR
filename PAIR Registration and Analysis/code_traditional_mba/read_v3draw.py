from v3dpy.loaders import Raw
import scipy.io
import argparse
import re
import numpy as np
import nibabel as nib
import scipy.io as io
from scipy.io import savemat

def format_number(num):
    # 将数字转换为字符串，保留两位小数
    str_num = f"{num:.2f}"
    # 使用正则表达式去除不必要的小数位
    str_num = re.sub(r'\.?0+$', '', str_num)
    return str_num


def transflip(arr):
    arr = np.squeeze(arr)
    arr = np.transpose(arr, (1, 2, 0))
    arr = np.flip(arr, axis=0)
    return arr


def main():

    # 创建 ArgumentParser 对象
    parser = argparse.ArgumentParser(description='Get resolution and mouse_num.')
    # 添加 -r 参数
    parser.add_argument('-r', type=int, required=True, help='The value of resolution.')
    # 添加 -num 参数
    parser.add_argument('-num', type=float, required=True, help='The value of num.')
    # 解析命令行参数

    args = parser.parse_args()

    mice_num =  args.num
    resolution = args.r 

    #Y:\xxx\xxx\Data\2024\240926_align\270.2\25um\step2_ants_mba\Warped_IMS_result
    warped_ims_datapath = 'Y:/xxx/xxx/Data/2024/240926_align/' + format_number(mice_num) + '/' + str(resolution) +'um/'+ 'traditional_mba/'
     # 读取.v3draw文件
    raw = Raw()
    warped_ims = raw.load(warped_ims_datapath + 'Warped_IMS_result/' + 'local_registered_image.v3draw')
 
    warped_ims = transflip(warped_ims)
   
    savemat(warped_ims_datapath + 'mba_warped_ims_' + str(resolution) +'um.mat',{'warped_ims': warped_ims})
    nib.Nifti1Image(warped_ims,np.eye(4)).to_filename(warped_ims_datapath +'mba_warped_ims_' + str(resolution) +'um.nii.gz')
    print((warped_ims.shape))


    raw2 = Raw()
    warped_ims = raw2.load(warped_ims_datapath + 'Warped_IMS_result/' + 'global.v3draw')
    warped_ims = transflip(warped_ims)
    savemat(warped_ims_datapath+'mba_global_warped_ims_' + str(resolution) +'um.mat',{'warped_ims': warped_ims})
    nib.Nifti1Image(warped_ims,np.eye(4)).to_filename(warped_ims_datapath +'mba_global_warped_ims_' + str(resolution) +'um.nii.gz')
    print((warped_ims.shape))

if __name__ == '__main__':
    main()




