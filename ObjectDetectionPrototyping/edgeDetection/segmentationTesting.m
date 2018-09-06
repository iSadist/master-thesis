clear all
close all

%% Testing of the function activecontour to segment images

I = imread('im3.jpg');
G_I = rgb2gray(I);
G_I = histeq(G_I);
imshow(G_I)

% specify a mask
str = 'Click to select initial contour location. Double-click to confirm and proceed.';
title(str,'Color','b','FontSize',12);
disp(sprintf('\nNote: Click close to object boundaries for more accurate result.'))

mask = roipoly;
  
figure, imshow(mask)
title('Initial MASK');
% perform contour
maxIterations = 500; 
bw = activecontour(G_I, mask, maxIterations, 'Chan-Vese');
  
% Display segmented image
figure, imshow(bw)
title('Segmented Image');
imshow(bw)
title('Segmented Image')

