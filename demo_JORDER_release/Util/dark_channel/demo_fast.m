warning('off','all');

tic;
image = double(imread('h12.jpg'))/255;

image = imresize(image, 1);

result = image;
for iter = 1:1
    display(iter);
    result = dehaze_fast(result, 0.95, 5);
end

toc;

figure, imshow(image)
figure, imshow(result)

warning('on','all');