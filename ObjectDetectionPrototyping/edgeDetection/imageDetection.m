clear all
close all

%% Load image 
im1  = imread('im3.jpg');

%% Histogram equalization


%% Print original image
figure(1)

imshow(im1);

%% Processing with color
C = coloredges(im1);
C = C/max(C(:));

grayIm1 = single(rgb2gray(im1))/255;
g = sqrt(imfilter(grayIm1, fspecial('prewitt')').^2 + imfilter(grayIm1, fspecial('prewitt')).^2);
g = g/max(g(:));
im = uint8(255 * cat(3, C, g, g));
figure(2)
imshow(im)

bw1 = ~imbinarize(C,0.05);
bw2 = bwareaopen(bw1,100);
figure(3)
hold on
imshow(bw2)
figure(1)
hold on
struct = regionprops(bw2);
cell = struct2cell(struct);
for i = 1:size(cell,2)
    rectangle('Position', cell{3,i},...
        'EdgeColor','r', 'LineWidth', 3)
end
% 
% %% Trying gray scale
% BW1 = edge(grayIm1,'sobel');
% h = fspecial('disk');
% BW1 = imfilter(BW1,h);
% figure(4);
% imshow(BW1);
% BW2 = bwareaopen(BW1,10);
% figure(5);
% imshow(BW2);

