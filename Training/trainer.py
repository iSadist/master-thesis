import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from sklearn.utils import shuffle

import plotter

image_width = 200
image_height = 150
number_of_color_channels = 3
image_libraries = ["UnknownObjects", "Seat", "Piece1", "Piece2"]

# MARK: - Functions

def loadImageLibrary(library_name, folder, image_list, label, label_list, start, end):
	print("Saving images " + library_name + "...")
	for num in range(start, end + 1):
		for artificalNum in range(1,18):
			filename = './Images/' + folder + '/Artificial' + library_name + '/image_' + str(num) + '-' + str(artificalNum) + '.jpg'
			addImage(filename, image_list, label, label_list)

def addImage(filename, image_list, label, label_list):
	image = Image.open(filename)
	image_array = np.asarray(image)/255.0
	image_list.append(image_array)
	label_list.append(label)
	return

def reshapeArray(oldArray):
	print("Reshaping...")
	reshapedArray = np.asarray(oldArray)
	return reshapedArray

def createModel():
	# Create the neural network
	model = keras.Sequential([
		keras.layers.Conv2D(16, kernel_size=(3, 3), strides=(1, 1), input_shape=(image_height, image_width, number_of_color_channels)),
		keras.layers.Conv2D(16, kernel_size=(2,2), strides=(1, 1)),
		keras.layers.Conv2D(16, kernel_size=(3,3), strides=(1, 1)),
		keras.layers.Conv2D(16, kernel_size=(2,2), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Conv2D(8, kernel_size=(3,3), strides=(1, 1)),
		keras.layers.Conv2D(8, kernel_size=(2,2), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Conv2D(4, kernel_size=(3,3), strides=(1, 1)),
		keras.layers.Conv2D(4, kernel_size=(2,2), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Conv2D(4, kernel_size=(2,2), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(4, 4), padding="valid"),
		keras.layers.Flatten(),
	    keras.layers.Dense(64, kernel_regularizer=keras.regularizers.l2(0.002), activation=tf.nn.relu),
	    keras.layers.Dropout(0.5),
	    keras.layers.Dense(4, activation=tf.nn.softmax) # The number of nodes must be the same as the number of possibilities
	])

	model.compile(optimizer=keras.optimizers.Adam(),
	              loss='sparse_categorical_crossentropy',
	              metrics=['accuracy'])
	model.summary()
	return model

def trainModel(model, train_data, train_labels, test_images, test_labels):
	print("Starting training...")
	train_data, train_labels = shuffle(train_data, train_labels) # Shuffle the whole training set
	history = model.fit(train_data, train_labels, epochs=50, batch_size=10, validation_data=(test_images, test_labels), verbose=1)
	return history

def loadImages(image_list, labels_list, folder, number_of_images):
	for i in range(0,len(image_libraries)):
		loadImageLibrary(image_libraries[i], folder, image_list, i, labels_list, 1, number_of_images)

def test(model, test_images,test_labels):
	print("Start testing...")
	test_loss, test_acc = model.evaluate(test_images, test_labels)
	print('Test accuracy:', test_acc)

def main():
	train_images = []
	train_labels = []
	loadImages(train_images, train_labels, "Train", 134)
	train_images = reshapeArray(train_images)

	test_images = []
	test_labels = []
	loadImages(test_images, test_labels, "Test", 31)
	test_images = reshapeArray(test_images)

	model = createModel()
	history = trainModel(model, train_images, train_labels, test_images, test_labels)
	model.save("./Models/recognizer.h5")
	test(model, test_images, test_labels)

	plotter.graphTrainingData(history)

main()
