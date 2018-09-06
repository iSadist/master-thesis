%% Possible to scrap
%% Testing method of Point Feature Matching to detect an object

stickImage = rgb2gray(imread('im2.jpg'));
figure;
imshow(stickImage);
title('Image of a stick');

sceneImage = rgb2gray(imread('im1.jpg'));
figure;
imshow(sceneImage);
title('Image of a Cluttered Scene');

stickPoints = detectSURFFeatures(stickImage);
scenePoints = detectSURFFeatures(sceneImage);

figure;
imshow(stickImage);
title('100 Strongest Feature Points from stick Image');
hold on;
plot(selectStrongest(stickPoints, 100));

figure;
imshow(sceneImage);
title('300 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(scenePoints, 300));

[stickFeatures, stickPoints] = extractFeatures(stickImage, stickPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

stickPairs = matchFeatures(stickFeatures, sceneFeatures);

matchedStickPoints = stickPoints(stickPairs(:, 1), :);
matchedScenePoints = scenePoints(stickPairs(:, 2), :);
figure;
showMatchedFeatures(stickImage, sceneImage, matchedStickPoints, ...
    matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');