% clear all;
warning('off');

addpath('./mtv/');
addpath('./vifvec/');
addpath('./matlabPyrTools/');
addpath('./Util/');
addpath('./Util/matlab/');
addpath('./Util/dehazing_code/');
addpath('./Util/DehazeNet/');

matcaffe_path = '/home/ywh/platform/caffe-master/matlab/';

test_tag = 4;
use_gpu = 1;
gpu_id = 3;
multi_view_tag = 0;
rain_accu_proposed = 0;
conduct_twice = 1;
heavy_case = 1;
rain_accu_case = 1;

if exist([matcaffe_path, '+caffe'], 'dir')
    addpath(matcaffe_path);
else
    error('Please run this demo from caffe/matlab/demo');
end

model_dir = './SRCNN_model/';
net_model_path = [model_dir, 'deploy_rain_removal_single.prototxt'];

if heavy_case==1
    net_weights = [model_dir, 'rain_removal_single_practical_heavy.caffemodel'];
else
    net_weights = [model_dir, 'rain_removal_single_practical_light.caffemodel'];
end

model_dir = './SRCNN_model/';
net_accu_model_path = [model_dir, 'deploy_rain_accu_removal.prototxt'];
net_accu_weights = [model_dir, 'rain_accu_removal.caffemodel'];

phase = 'test';
if ~exist(net_weights, 'file')
    error('Please download CaffeNet from Model Zoo before you run this demo');
end

if exist('use_gpu', 'var') && use_gpu
    caffe.set_mode_gpu();
    caffe.set_device(gpu_id);
else
    caffe.set_mode_cpu();
end


rain_dir = './Dataset/Practical_full/';

files=dir([rain_dir, '*.jpg']);
test_len = length(files);
front_tag = 'Practical';
save_dir = 'Results';

m=size(files,1);

psnr_res = 0;
ssim_res = 0;
psnr_list  =zeros(1, test_len);
ssim_list  =zeros(1, test_len);

for i=1:test_len
    image_name = [rain_dir, files(i).name];
    display(image_name);
    image = imread(image_name);
    
    [~,~,c] = size(image);

    if c~=3
        image = cat(3, image, image, image);
    end
    image = rgb2ycbcr(image);
    image_cb = double(image(:,:,2));
    image_cr = double(image(:,:,3));    
    

    caffe.reset_all();
    net = caffe.Net(net_model_path, net_weights, phase);
    
    image = double(image(:,:,1));
    
    [input_height, input_width, ~] = size(image);
    rain_image = double(image)/255;
    
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
        
        im_res_step1 = (im_res + im_res_lr + im_res_ud + im_res_lr_ud)/4;
    else
        im_res_step1 = im_res;
    end
   
    %
    % Accumulation removal
    % 

    im_res_step1_color = double(cat(3, uint8(im_res_step1(:,:)*255), image_cb, image_cr))/255.0;
    im_res_step1_color = ycbcr2rgb(im_res_step1_color);

    if rain_accu_case==1
        if rain_accu_proposed==1
            addpath('Util/dark_channel');
            addpath('Util/dehazing_code');

            caffe.reset_all();
            net = caffe.Net(net_accu_model_path, net_accu_weights, phase);

            im_trans = matcaffe_rain_joint_one_direction(net, cat(3, im_res_step1, im_res_step1_color));
            im_trans(im_trans>1) = 1;
            im_trans(im_trans<0.05) = 0.05;
            im_trans = imguidedfilter(im_trans,'NeighborhoodSize', [20 20], 'DegreeOfSmoothing',  0.001*diff(getrangefromclass(im_res_step1)).^2 );


            dark_ch = get_dark_channel(im_res_step1_color, 5);
            atmo = get_atmosphere(im_res_step1_color, dark_ch);

            im_res_step2_color = im_res_step1_color;
            diff_factor = 1;

            for t=1:3
                tmp_A_layer = (1 - im_trans)*atmo(t)*diff_factor;
                im_res_step2_color(:,:,t) = (im_res_step1_color(:,:,t) - tmp_A_layer)./im_trans;
            end
        else
            im_res_step2_color = run_cnn(im_res_step1_color, 0.5, 0.7);
        end
    else
        im_res_step2_color = im_res_step1_color;
    end
    
    %
    % final rain removal
    % 
    
    if conduct_twice==1
        image = uint8(im_res_step2_color*255);
        [~,~,c] = size(image);

        if c==3
            image = rgb2ycbcr(image);
            image_cb = double(image(:,:,2));
            image_cr = double(image(:,:,3));
        end

        caffe.reset_all();
        net = caffe.Net(net_model_path, net_weights, phase);

        image = double(image(:,:,1));

        [input_height, input_width, ~] = size(image);
        rain_image = double(image)/255;

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

            im_res_step3 = (im_res + im_res_lr + im_res_ud + im_res_lr_ud)/4;
        else
            im_res_step3 = im_res;
        end
        im_res_step3_color = double(cat(3, uint8(im_res_step3(:,:)*255), image_cb, image_cr))/255.0;
        im_res_step3_color = ycbcr2rgb(im_res_step3_color);        
    else
        im_res_step3_color = im_res_step2_color;
    end
 
    output_image_name = ['./', save_dir, '/Derained-', front_tag, '-' files(i).name];
    imwrite(im_res_step3_color, output_image_name);
end

psnr_res = psnr_res/test_len;
ssim_res = ssim_res/test_len;

display('Average: ');
display(psnr_res);
display(ssim_res);
