warning('off','all');

addpath('./weighted_GE/');

tic;
image = double(imread('h3.jpg'))/255;
image_ref = double(imread('h3_ref.jpg'))/255;

image = imresize(image, 1);

result = image;
for iter = 1:2
    display(iter);
    result = dehaze_fast(result, 0.5, 5);
    
    mink_norm = 5;
    sigma = 2;
    diff_order = 1;
    kappa = 10; 
    [wR, wG, wB, result_balanced] = weightedGE( result, kappa, mink_norm, sigma );

    imshow(result_balanced)
    figure, imshow(result)

    if iter == 1
        result_ycbcr = rgb2ycbcr(uint8(result*255));
        result_y = result_ycbcr(:,:,1);
        result_cb = result_ycbcr(:,:,2);
        result_cr = result_ycbcr(:,:,3);
        
        result_y_clahe = adapthisteq(result_y);
        nhoodSize = 20;
        smoothValue  = 0.00001*diff(getrangefromclass(result_y)).^2;
        
        result_y_clahe = imguidedfilter(result_y_clahe, result_y, 'NeighborhoodSize',nhoodSize, 'DegreeOfSmoothing',smoothValue);
        
        result_y = double(result_y)/255;
        result_y_clahe = double(result_y_clahe)/255;
        result(:,:,1) = result(:,:,1).*(result_y_clahe./result_y).^(0.5);
        result(:,:,2) = result(:,:,2).*(result_y_clahe./result_y).^(0.5);
        result(:,:,3) = result(:,:,3).*(result_y_clahe./result_y).^(0.5);
    end
end

toc;

figure, imshow(image)
figure, imshow(result)

warning('on','all');