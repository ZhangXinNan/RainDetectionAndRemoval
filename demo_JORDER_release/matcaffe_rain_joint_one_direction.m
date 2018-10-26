function [ im_final ] = matcaffe_rain_joint_one_direction(net, rain_image)

pad = 20;
im_lr = rain_image;
im_lr = padarray(im_lr,[pad, pad],'replicate','both');

[input_height, input_width, ~] = size(im_lr);

im_final  = zeros(input_height, input_width);
im_weight = zeros(input_height, input_width);
tic;

crop_step = 100;
move_step = 80;
border = 10;
[rh,rw,~] = size(im_final);

for ii = 1:move_step:rh
    if ii+crop_step-1 <= rh
        tmpi = ii;
    else
        tmpi = rh - crop_step + 1;
    end
    
    for jj=1:move_step:rw
        if jj+crop_step-1 <= rw
            tmpj = jj;
        else
            tmpj = rw - crop_step +1;
        end
        
        tmp_lr = im_lr(tmpi:tmpi+crop_step-1,tmpj:tmpj+crop_step-1,:);
        [~, temp_res] = matcaffe_rain_joint(net, tmp_lr);
        
        im_final(tmpi+border:tmpi+crop_step-1-border,tmpj+border:tmpj+crop_step-1-border) = im_final(tmpi+border:tmpi+crop_step-1-border,tmpj+border:tmpj+crop_step-1-border) + temp_res(1+border:end-border, 1+border:end-border, :);
        im_weight(tmpi+border:tmpi+crop_step-1-border,tmpj+border:tmpj+crop_step-1-border) = im_weight(tmpi+border:tmpi+crop_step-1-border,tmpj+border:tmpj+crop_step-1-border) + ones(size(im_weight(tmpi+border:tmpi+crop_step-1-border,tmpj+border:tmpj+crop_step-1-border)));
    end
end

im_final = im_final(pad+1:end-pad, pad+1:end-pad, :)./im_weight(pad+1:end-pad, pad+1:end-pad, :);


