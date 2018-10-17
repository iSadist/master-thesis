import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

image = Image.open("IMG_3642.JPG").convert("L")
arr = np.asarray(image)

# Read Depth data file

depth_data = open('IMG_3642_depth-map.txt', 'r')
depth_map = depth_data.read().split(' ')

depth_map = np.reshape(depth_map, (576, 768))
# depth_map = np.asarray(depth_map) * 50.0
depth_map = depth_map.astype(float)

depth_data.close()

# plt.imshow(arr, cmap='gray')
plt.imshow(depth_map, cmap='gray')
plt.show()
# image.show()

