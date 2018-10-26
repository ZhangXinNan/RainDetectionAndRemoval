function [ adjust_image ] = white_balance( image )

R = mean(mean(image(:,:,1)));
G = mean(mean(image(:,:,2)));
B = mean(mean(image(:,:,3)));

k = (R+G+B)/3;

k_r = k/R;
k_g = k/G;
k_b = k/B;

image(:,:,1) = image(:,:,1)*k_r;
image(:,:,2) = image(:,:,2)*k_g;
image(:,:,3) = image(:,:,3)*k_b;

adjust_image = image;

end

