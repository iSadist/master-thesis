import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from sklearn.utils import shuffle

import plotter

image_width = 800
image_height = 600
number_of_color_channels = 3

training_share = 0.75

number_of_total_images = 77
training_batch_size = int(number_of_total_images * training_share)

image_libraries = ["UnknownObjects", "Seat", "Piece1", "Piece2"]

# MARK: - Functions

def loadImageLibrary(library_name, image_list, label, label_list, start, end):
	print("Saving images " + library_name + "...")
	for num in xrange(start, end):
		for artificalNum in xrange(1,18):
			filename = './Images/Artificial' + library_name + '/image_' + str(num) + '-' + str(artificalNum) + '.jpg'
			addImage(filename, image_list, label, label_list)
			pass
		pass
	print("Done with " + library_name + "!")

def addImage(filename, image_list, label, label_list):
	image = Image.open(filename)
	image_array = np.asarray(image)
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
		keras.layers.Conv2D(16, kernel_size=(4, 4), strides=(4, 4), input_shape=(image_height, image_width, number_of_color_channels)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Conv2D(16, kernel_size=(4,4), strides=(4, 4)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Conv2D(16, kernel_size=(2,2), strides=(2, 2)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Flatten(),
	    keras.layers.Dense(16, activation=tf.nn.relu),
	    keras.layers.Dropout(0.1),
	    keras.layers.Dense(16, activation=tf.nn.relu),
	    keras.layers.Dropout(0.1),
	    keras.layers.Dense(16, activation=tf.nn.relu),
	    keras.layers.Dropout(0.1),
	    keras.layers.Dense(4, activation=tf.nn.softmax) # The number of nodes must be the same as the number of possibilities
	])

	model.compile(optimizer=keras.optimizers.Adam(),
	              loss='sparse_categorical_crossentropy',
	              metrics=['accuracy'])
	model.summary()
	return model

def trainModel(model, train_data, train_labels):
	print("Starting training...")
	train_data_size = len(train_data)
	validation_part = 0.75
	partial_train_size = int(train_data_size*validation_part)

	partial_x_train = train_data[:partial_train_size]
	partial_y_train = train_labels[:partial_train_size]

	x_validation = train_data[partial_train_size:]
	y_validation = train_labels[partial_train_size:]

	history = model.fit(train_data, train_labels, epochs=100, batch_size=476, validation_data=(x_validation, y_validation), verbose=1)
	return history

def loadTrainImages(image_list, labels_list):
	for i in xrange(0,len(image_libraries)):
		loadImageLibrary(image_libraries[i], image_list, i, labels_list, 1, training_batch_size)

def loadTestImages(image_list, labels_list):
	for i in xrange(0,len(image_libraries)):
		loadImageLibrary(image_libraries[i], image_list, i, labels_list, training_batch_size + 1, number_of_total_images)

def test(model, test_images,test_labels):
	print("Start testing...")
	test_loss, test_acc = model.evaluate(test_images, test_labels)
	print('Test accuracy:', test_acc)

def main():
	train_images = []
	train_labels = []

	test_images = []
	test_labels = []

	loadTrainImages(train_images, train_labels)
	train_images = reshapeArray(train_images)
	train_images, train_labels = shuffle(train_images, train_labels)

	model = createModel()
	history = trainModel(model, train_images, train_labels)
	model.save("./Models/recognizer.h5")
	loadTestImages(test_images,test_labels)
	test_images = reshapeArray(test_images)
	test(model, test_images,test_labels)

	plotter.graphTrainingData(history)

main()
