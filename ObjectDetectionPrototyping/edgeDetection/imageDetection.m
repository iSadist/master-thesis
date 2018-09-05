clear all
close all

%% Load image 
im1  = imread('im2.jpg');


%% Print original image
figure(1)
imshow(im1);

%% Processing
C = coloredges(im1);
C = C/max(C(:));

grayIm1 = single(rgb2gray(im1))/255;
g = sqrt(imfilter(grayIm1, fspecial('prewitt')').^2 + imfilter(grayIm1, fspecial('prewitt')).^2);
g = g/max(g(:));

figure(2)
imshow(uint8(255 * cat(3, C, g, g)))

%
BW = edge(grayIm1,'sobel',0.05);
figure(3);
imshow(BW);