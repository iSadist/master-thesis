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

training_share = 0.9

image_libraries = ["UnknownObjects", "Seat", "Piece1", "Piece2"]

number_of_total_images = 154 
training_batch_size = int(number_of_total_images * training_share * 18 * len(image_libraries))


# MARK: - Functions

def loadImageLibrary(library_name, image_list, label, label_list, start, end):
	print("Saving images " + library_name + "...")
	for num in range(start, end):
		for artificalNum in range(1,18):
			filename = './Images/Artificial' + library_name + '/image_' + str(num) + '-' + str(artificalNum) + '.jpg'
			addImage(filename, image_list, label, label_list)
			pass
		pass
	print("Done with " + library_name + "!")

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
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Dropout(0.4),
		keras.layers.Conv2D(16, kernel_size=(3,3), strides=(1, 1)),
		keras.layers.Conv2D(16, kernel_size=(2,2), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Dropout(0.4),
		keras.layers.Conv2D(32, kernel_size=(3,3), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.Dropout(0.4),
		keras.layers.Flatten(),
	    keras.layers.Dense(128, activation=tf.nn.relu),
	    keras.layers.Dropout(0.5),
	    keras.layers.Dense(64, activation=tf.nn.relu),
	    keras.layers.Dropout(0.2),
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
	training_part = 0.75
	partial_train_size = int(train_data_size*training_part)

	partial_x_train = train_data[:partial_train_size]
	partial_y_train = train_labels[:partial_train_size]

	x_validation = train_data[partial_train_size:]
	y_validation = train_labels[partial_train_size:]


	history = model.fit(train_data, train_labels, epochs=100, batch_size=100, validation_data=(x_validation, y_validation), verbose=1)
	return history

def loadImages(image_list, labels_list):
	for i in range(0,len(image_libraries)):
		loadImageLibrary(image_libraries[i], image_list, i, labels_list, 1, number_of_total_images)

def test(model, test_images,test_labels):
	print("Start testing...")
	test_loss, test_acc = model.evaluate(test_images, test_labels)
	print('Test accuracy:', test_acc)

def main():
	images = []
	labels = []

	loadImages(images, labels)
	images = reshapeArray(images)
	images, labels = shuffle(images, labels)

	train_images = images[:training_batch_size]
	train_labels = labels[:training_batch_size]

	test_images = images[training_batch_size + 1:]
	test_labels = labels[training_batch_size + 1:]

	model = createModel()
	history = trainModel(model, train_images, train_labels)
	model.save("./Models/recognizer.h5")
	test(model, test_images,test_labels)

	plotter.graphTrainingData(history)

main()
