A = zeros(150,200,100);
B = zeros(150,200,120);


% 球的参数
cx = 50;  % 球的 x 轴中心
cy = 50;  % 球的 y 轴中心
cz = 50;  % 球的 z 轴中心

matrix_size = size(A);
% 创建球体
a = 15;   % 椭球在 x 轴方向的半轴长度
b = 20;   % 椭球在 y 轴方向的半轴长度
c = 10;    % 椭球在 z 轴方向的半轴长度

% 创建椭球体
[x, y, z] = ndgrid(1:matrix_size(1), 1:matrix_size(2), 1:matrix_size(3));
ellipsoid_region = ((x - cx) / a).^2 + ((y - cy) / b).^2 + ((z - cz) / c).^2 <= 1;

% 将椭球区域填充为 1
A(ellipsoid_region) = 1;
temp = make_nii(A);
save_nii(temp,'Z:\xxx\tmp\test\241023-270-ls\A.nii.gz')



% 球的参数
cx = 100;  % 球的 x 轴中心
cy = 50;  % 球的 y 轴中心
cz = 50;  % 球的 z 轴中心

matrix_size = size(B);
% 创建球体
a = 15;   % 椭球在 x 轴方向的半轴长度
b = 20;   % 椭球在 y 轴方向的半轴长度
c = 12;    % 椭球在 z 轴方向的半轴长度

% 创建椭球体
[x, y, z] = ndgrid(1:matrix_size(1), 1:matrix_size(2), 1:matrix_size(3));
ellipsoid_region = ((x - cx) / a).^2 + ((y - cy) / b).^2 + ((z - cz) / c).^2 <= 1;

% 将椭球区域填充为 1
B(ellipsoid_region) = 1;
temp = make_nii(B);
save_nii(temp,'Z:\xxx\tmp\test\241023-270-ls\B.nii.gz')


%%
close all
data = load_nii('Z:\xxx\tmp\test\241023-270-ls\A.nii.gz');
data = data.img;



% figure;imagesc(squeeze(data(20,:,:)));
% figure;imagesc(squeeze(data(:,20,:)));
% figure;imagesc(squeeze(data(:,:,20)));


% data = permute(data,[2,3,1]);
% data = flip(data,1);
% data = flip(data,3);
load('Z:\xxx\tmp\test\241023-270-ls\Generic_Affine_up.mat')

% 假设 affine_params 是 ANTs 的 12 个仿射参数，fixed 是中心点坐标 [cx, cy, cz]
affine_params = AffineTransform_float_3_3;

% fixed = abs(fixed);
% affine_params([3,6,7,8,10,11]) = -affine_params([3,6,7,8,10,11]);

%%
% 1. 构建 4x4 的仿射矩阵 A
A = [affine_params(1), affine_params(2), affine_params(3), affine_params(10);
     affine_params(4), affine_params(5), affine_params(6), affine_params(11);
     affine_params(7), affine_params(8), affine_params(9), affine_params(12);
     0,              0,               0,               1];

% 2. 构建平移矩阵 T1 和 T2
% T1: 平移图像到中心点
T1 = eye(4);
T1(1:3, 4) = fixed;

% T2: 平移回原位置
T2 = eye(4);
T2(1:3, 4) = -fixed;

% 3. 组合最终变换矩阵 M
M = T2 * A * T1;


%%
% 1. 构建符合 affine3d 要求的 4x4 仿射矩阵 M
M = eye(4);  % 创建单位矩阵
M(1:3, 1:3) = [affine_params(1), affine_params(2), affine_params(3);  % 旋转/缩放部分
               affine_params(4), affine_params(5), affine_params(6);
               affine_params(7), affine_params(8), affine_params(9)];
M(1:3, 4) = [affine_params(10); affine_params(11); affine_params(12)];  % 平移部分

% 2. 创建 affine3d 对象




m = fixed(1);
n = fixed(2);
k = fixed(3);


% 提取平移向量

t = [M(1,4); M(2,4); M(3,4); 1];
temp = [m; n; k; 1];
% 计算中心点的位移
t_center = M * temp - t;

% 计算位移差异
delta_t = t_center - t;

% 输出位移差异
disp(delta_t);
%%
tform = affine3d(M');


[dimX, dimY, dimZ] = size(data);

% 1. 定义原始图像的八个角点
corners = [
    1, 1, 1;
    dimX, 1, 1;
    1, dimY, 1;
    dimX, dimY, 1;
    1, 1, dimZ;
    dimX, 1, dimZ;
    1, dimY, dimZ;
    dimX, dimY, dimZ
];

% 2. 将角点转换为齐次坐标并应用仿射变换
corners = [corners, ones(8, 1)]';
transformed_corners = M * corners;
% transformed_corners = corners * tform.T;

% 3. 获取转换后的坐标范围
xLimitsOut = [min(transformed_corners(1,:)), max(transformed_corners(1,:))];
yLimitsOut = [min(transformed_corners(2,:)), max(transformed_corners(2,:))];
zLimitsOut = [min(transformed_corners(3,:)), max(transformed_corners(3,:))];

% xLimitsOut = xLimitsOut + fixed(1);
% yLimitsOut = yLimitsOut + fixed(2);
% zLimitsOut = zLimitsOut + fixed(3);


yLimitsOut = [delta_t(1)-228,delta_t(1)+228];
xLimitsOut = [delta_t(2)-256,delta_t(2)+256] ;
zLimitsOut = [delta_t(3)-160,delta_t(3)+160] ;

xLimitsOut = [-affine_params(10),-affine_params(10)+size(B,1)] ;
yLimitsOut = [affine_params(11),affine_params(11)+size(B,2)] ;
zLimitsOut = [affine_params(12),affine_params(12)+size(B,3)] ;

% 4. 使用新的坐标范围创建足够大的输出视图
imageSize = [size(B,1),size(B,2),size(B,3)];
R = imref3d(imageSize);                 % 仅指定大小
R = imref3d(imageSize, yLimitsOut, xLimitsOut, zLimitsOut); % 指定大小和物理坐标范围


% 5. 使用新的 OutputView 执行仿射变换
transformed_data = imwarp(data, tform, 'FillValues', 0);




save('Z:\xxx\tmp\test\241023-270-ls\my_affine_trans.mat','transformed_data')
transformed_data2=make_nii(transformed_data);
save_nii(transformed_data2,'Z:\xxx\tmp\test\241023-270-ls\my_affine_trans.nii.gz')
% transformed_data 现在应包含整个变换后的图像

%%
% 定义旋转部分和原平移量
R = [0.99977016, 0.10023896, 0.20152861;
     0.09761637, 0.99884564, 0.19134966;
     0.09617625, 0.20088449, 0.99350011];
t = [19.6; 14; 29.84];



% 构造系数矩阵 A 和常数向量 d
A = R-eye(3);

d = -t;

% 求解 a, b, c
if det(A) ~= 0
    abc = A \ d; % 求解方程组
    a = abc(1);
    b = abc(2);
    c = abc(3);
else
    error('矩阵 A 不可逆，无法解出唯一解');
end

% 输出结果
fprintf('a = %.4f\n', a);
fprintf('b = %.4f\n', b);
fprintf('c = %.4f\n', c);



% 求解 a, b, c
abc = -R \ t;

% 输出 a, b, c
a = abc(1);
b = abc(2);
c = abc(3);
