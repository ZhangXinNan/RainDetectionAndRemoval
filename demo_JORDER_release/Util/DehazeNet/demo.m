clc;
clear;
close all;

haze=imread('data/canyon.png');
haze=double(haze)./255;
dehaze=run_cnn(haze);
imshow(dehaze);
