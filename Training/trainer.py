import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

image_width = 400
image_height = 300

# # Load test image dataset from tensorflow
# fashion_mnist = keras.datasets.fashion_mnist
# (train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

def loadImageLibrary(library_name, label, start, end):
	for num in xrange(start, end):
		print("Saving image " + str(num) + "...")
		for artificalNum in xrange(1,13):
			filename = './Images/Artificial' + library_name + '/IMG_' + str(num) + '-' + str(artificalNum) + '.jpg'
			addImage(filename, label)
			pass
		pass
	pass

def addImage(filename, label):
	image = Image.open(filename)
	images.append(list(image.getdata(0)))
	train_labels.append(label)
	return 

# Create the neural network
model = keras.Sequential([
	keras.layers.Conv2D(16, kernel_size=(20,20), strides=(5, 5), input_shape=(image_width, image_height, 1)),
	keras.layers.MaxPool2D(pool_size=(4, 4), padding="valid"),
	keras.layers.Conv2D(16, kernel_size=(5,5), strides=(1, 1)),
	keras.layers.MaxPool2D(pool_size=(4, 4), padding="valid"),
	keras.layers.Flatten(),
    keras.layers.Dense(32, activation=tf.nn.relu),
    keras.layers.Dense(32, activation=tf.nn.relu),
    keras.layers.Dense(32, activation=tf.nn.relu),
    keras.layers.Dense(32, activation=tf.nn.relu),
    keras.layers.Dense(32, activation=tf.nn.relu),
    keras.layers.Dense(3, activation=tf.nn.softmax) # The number of nodes must be the same as the number of possibilities
])

model.compile(optimizer=tf.train.AdamOptimizer(), 
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
model.summary()

# Load images from datasets

images = []
train_labels = []

# Seats
loadImageLibrary('Seat', 0, 1863, 1963)

print("Done with seats!")

# Pieces 1
loadImageLibrary('Piece1', 1, 2253, 2353)

print("Done with pieces 1!")

loadImageLibrary('Piece2', 2, 2536, 2636)

print("Done with pieces 2!")
print("Importing images complete!")
print("--------------------------------")
print("Reshaping to fit train images...")

train_images = np.array(images).reshape(len(images), image_width, image_height, 1)

print("Reshaping complete!")

print("Starting training...")

model.fit(train_images, train_labels, epochs=200)

print("Training complete!")

# Evaluate the model
# test_loss, test_acc = model.evaluate(test_images, test_labels)
# print('Test accuracy:', test_acc)

# model.save("recognizer.h5")
