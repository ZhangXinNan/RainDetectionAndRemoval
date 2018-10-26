clear all;
warning('off');

%
% Include Path.
%
addpath('./mtv/');
addpath('./vifvec/');
addpath('./matlabPyrTools/');

matcaffe_path = '/home/ywh/platform/caffe-master/matlab/';

% 
% Set Tags.
%
use_gpu = 1;
gpu_id = 3;
obj_tag = 1;        % Whether perform a objective evaluation
multi_view_tag = 0; % Whether conduct a multi-view aggreation in the testing phase


%
% Caffe and Model Settings.
%
if exist([matcaffe_path, '+caffe'], 'dir')
    addpath(matcaffe_path);
else
    error('Please run this demo from caffe/matlab/demo');
end

model_dir = './SRCNN_model/';
net_model_path = [model_dir, 'deploy_rain_removal_single.prototxt'];
net_weights = [model_dir, 'rain_removal_single_light.caffemodel'];
phase = 'test';

if exist('use_gpu', 'var') && use_gpu
    caffe.set_mode_gpu();
    caffe.set_device(gpu_id);
else
    caffe.set_mode_cpu();
end


if ~exist(net_weights, 'file')
    error('Please download CaffeNet from Model Zoo before you run this demo');
end
caffe.reset_all();
net = caffe.Net(net_model_path, net_weights, phase);

% 
% Set Datasets.
%
rain_dir = './Dataset/Rain100L/';
norain_dir = './Dataset/Rain100L/';

files=dir([rain_dir, 'rain-*.png']);
norain_files=dir([norain_dir, 'norain-*.png']);
test_len = length(files);
front_tag = 'Rain100L';
save_dir = 'Results';
m=size(files,1);

% 
% Evaluation Metrics.
%
psnr_res = 0;
ssim_res = 0;
psnr_list  =zeros(1, test_len);
ssim_list  =zeros(1, test_len);

% 
% Testing.
%
for i=1:test_len
    image_name = [rain_dir, files(i).name];
    display(image_name);
    image = imread(image_name);
    
    [~,~,c] = size(image);
    if c==3
        image = rgb2ycbcr(image);
        image_cb = double(image(:,:,2));
        image_cr = double(image(:,:,3));
    end
    
    image = double(image(:,:,1));
    im_gt = imread([norain_dir, norain_files(i).name]);
    
    if c==3
        im_gt = rgb2ycbcr(im_gt);
        im_gt_cb = im_gt(:,:,2);
        im_gt_cr = im_gt(:,:,3);
        im_gt = double(im_gt(:,:,1));
    end
    
    [input_height, input_width, ~] = size(image);
    rain_image = double(image)/255;
    im_gt = double(im_gt)/255;
    
    im_res = matcaffe_rain_joint_one_direction(net, rain_image);
    
    if multi_view_tag==1
        rain_image_ud = flipud(rain_image);
        im_res_ud = matcaffe_rain_joint_one_direction(net, rain_image_ud);
        im_res_ud = flipud(im_res_ud);
        
        rain_image_lr = fliplr(rain_image);
        im_res_lr = matcaffe_rain_joint_one_direction(net, rain_image_lr);
        im_res_lr = fliplr(im_res_lr);
        
        rain_image_lr_ud = flipud(fliplr(rain_image));
        im_res_lr_ud = matcaffe_rain_joint_one_direction(net, rain_image_lr_ud);
        im_res_lr_ud = flipud(fliplr(im_res_lr_ud));
        
        im_res_final = (im_res + im_res_lr + im_res_ud + im_res_lr_ud)/4;
    else
        im_res_final = im_res;
    end
    
    if obj_tag == 1
        [psnr_value] = compute_psnr(uint8(im_res_final*255), uint8(im_gt*255), 'psnr');
        [ssim_value] = cal_ssim(uint8(im_res_final*255), uint8(im_gt*255),0,0);
        
        display(psnr_value);
        display(ssim_value);
        
        psnr_list(1,i) = psnr_value;
        ssim_list(1,i) = ssim_value;
        
        psnr_res = psnr_res + psnr_value;
        ssim_res = ssim_res + ssim_value;
    end
    
    output_image_name = ['./', save_dir, '/Derained-', front_tag, '-' files(i).name];
    im_final_color = cat(3, uint8(im_res_final(:,:)*255), im_gt_cb, im_gt_cr);
    im_final_color = ycbcr2rgb(im_final_color);
    imwrite(im_final_color, output_image_name);
end

psnr_res = psnr_res/test_len;
ssim_res = ssim_res/test_len;

display('Average: ');
display(psnr_res);
display(ssim_res);
