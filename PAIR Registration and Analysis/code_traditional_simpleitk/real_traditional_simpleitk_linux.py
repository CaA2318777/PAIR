import SimpleITK as sitk
import pathlib
import time
# 加载固定图像、移动图像和移动掩码
import json
import argparse
import os



current_file_path = os.path.abspath(__file__)
path_before_hd6 = current_file_path.rsplit('HD6', 1)[0]


parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument(
    '-n',
    "--num",
    default=[315],
    nargs="+",  # "+" 表示至少一个值
    type=int,   # 转换为整数
    help="List of mice_num"
)
parser.add_argument('-r', '--resolution', default=25, type=int, help='resolution')
parser.add_argument('-p', '--protein',default=0, type=int, help='protein') 
parser.add_argument('-s', '--step1',default='vm', type=str, help='step1') 
args = parser.parse_args()



mice_nums = args.num
resolution = args.resolution
ifresult = args.protein
method1 = args.step1

def iteration_callback():
    global iteration_loss
    loss = bspline_registration.GetMetricValue()
    # 只在损失值发生变化时记录
    if len(iteration_loss) == 0 or loss != iteration_loss[-1]:
        iteration_loss.append(loss)
        print(f"Iteration {len(iteration_loss)}: Loss = {loss}")



for mice_num in mice_nums:
    datapath = path_before_hd6+'/xxx/xxx/Data/2024/240926_align/'  +str(mice_num)+'/25um/'
    pathlib.Path(datapath+'traditional_simpleitk').mkdir(parents=True, exist_ok=True) 


    # 加载固定图像和移动图像
    fixed_image = sitk.ReadImage(datapath+'origin/Atlas_25um.nii.gz', sitk.sitkFloat32)
    moving_image = sitk.ReadImage(datapath+'origin/ims_data_25um.nii.gz', sitk.sitkFloat32)

    if ifresult:
        moving_mask = sitk.ReadImage(datapath+'origin/ims_data_result_25um.nii', sitk.sitkFloat32)

    # Step 1: 线性（仿射）配准
    affine_registration = sitk.ImageRegistrationMethod()
    affine_registration.SetMetricAsMattesMutualInformation(numberOfHistogramBins=50)
    affine_registration.SetMetricSamplingStrategy(affine_registration.RANDOM)
    affine_registration.SetMetricSamplingPercentage(0.01)
    affine_registration.SetInterpolator(sitk.sitkLinear)

    affine_registration.SetOptimizerAsGradientDescent(learningRate=1.0, numberOfIterations=100, convergenceMinimumValue=1e-6, convergenceWindowSize=10)
    affine_registration.SetOptimizerScalesFromPhysicalShift()

    # 初始化仿射变换
    initial_transform = sitk.CenteredTransformInitializer(fixed_image, moving_image, sitk.AffineTransform(fixed_image.GetDimension()))
    affine_registration.SetInitialTransform(initial_transform, inPlace=False)

    # 执行仿射配准
    affine_transform = affine_registration.Execute(fixed_image, moving_image)


    affine_moving_resampled = sitk.Resample(
        moving_image,
        fixed_image,
        affine_transform,
        sitk.sitkLinear,
        0.0,
        moving_image.GetPixelID(),
    )

    sitk.WriteImage(
        affine_moving_resampled, datapath+'traditional_simpleitk/simpleitk_affine_warped_ims_25um.nii.gz'
    )
    print('save affine ims')

    if ifresult:
        affine_moving_mask_resampled = sitk.Resample(
            moving_mask,
            fixed_image,
            affine_transform,
            sitk.sitkNearestNeighbor,
            0.0,
            moving_mask.GetPixelID(),
        )

        sitk.WriteImage(
            affine_moving_mask_resampled, datapath+'traditional_simpleitk/simpleitk_affine_warped_ims_result_25um.nii.gz'
        )

        print('save affine ims result')


    print('affine end')





    import matplotlib.pyplot as plt
    # 用于存储每次迭代的 Loss 值
    iteration_loss = []


    # 回调函数，记录 Loss 值


    T1 = time.time()
    # Step 2: 使用仿射变换对齐后的结果作为输入，进行B样条非刚性配准
    bspline_registration = sitk.ImageRegistrationMethod()
    bspline_registration.SetMetricAsMattesMutualInformation(numberOfHistogramBins=50)
    bspline_registration.SetMetricSamplingStrategy(bspline_registration.RANDOM)
    bspline_registration.SetMetricSamplingPercentage(0.01)
    bspline_registration.SetInterpolator(sitk.sitkLinear)

    # 设置B样条网格
    transform_domain_mesh_size = [2, 2, 2]  # 可以根据需求调整
    bspline_transform = sitk.BSplineTransformInitializer(fixed_image, transform_domain_mesh_size)
    bspline_registration.SetInitialTransform(bspline_transform, inPlace=True)

    # 设置优化器
    bspline_registration.SetOptimizerAsLBFGSB(gradientConvergenceTolerance=1e-5, numberOfIterations=300, maximumNumberOfCorrections=5, maximumNumberOfFunctionEvaluations=1000)
    bspline_registration.AddCommand(sitk.sitkIterationEvent, iteration_callback)


    print('begin')




    # 执行B样条配准
    final_transform = bspline_registration.Execute(fixed_image, affine_moving_resampled)


    # 生成配准后的移动图像
    registered_image = sitk.Resample(
        affine_moving_resampled,
        fixed_image,
        final_transform,
        sitk.sitkLinear,
        0.0,
        affine_moving_resampled.GetPixelID(),
    )

    sitk.WriteImage(registered_image, datapath+"traditional_simpleitk/simpleitk_warped_ims_25um.nii.gz")

    if ifresult:
        registered_image_mask = sitk.Resample(
            affine_moving_mask_resampled,
            fixed_image,
            affine_transform,
            sitk.sitkNearestNeighbor,
            0.0,
            affine_moving_mask_resampled.GetPixelID(),
        )

        sitk.WriteImage(
            registered_image_mask, datapath+'traditional_simpleitk/simpleitk_warped_ims_result_25um.nii.gz'
        )

        print('save ims protein result')


    print("Affine and B-spline registration completed.")
    T2 = time.time()
    print('程序运行时间:%s秒' % ((T2 - T1)))



    # 将损失值保存到文本文件
    with open(datapath+'traditional_simpleitk/loss.txt', "w") as file:
        file.write("Iteration,Loss\n")
        for i, loss in enumerate(iteration_loss, start=1):
            file.write(f"{i},{loss}\n")



    print("Final metric value: ", bspline_registration.GetMetricValue())
    print("Optimizer's stopping condition: ", bspline_registration.GetOptimizerStopConditionDescription())



    # 绘制 Loss 曲线
    plt.plot(iteration_loss, label="Loss")
    plt.xlabel("Iteration")
    plt.ylabel("Metric Value (Loss)")
    plt.title("Loss Curve")
    plt.legend()
    plt.savefig(datapath+"traditional_simpleitk/output.png")  # 保存为 PNG 格式
    plt.close()