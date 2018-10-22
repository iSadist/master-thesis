import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from sklearn.utils import shuffle

import plotter

image_width = 256
image_height = 256
number_of_color_channels = 3
image_libraries = ["UnknownObjects", "Seat", "Piece1", "Piece2"]

number_of_augmentations = 12

# MARK: - Functions

def loadImageLibrary(library_name, folder, image_list, label, label_list, start, end):
	print("Saving images " + library_name + "...")
	for num in range(start, end + 1):
		for artificalNum in range(1,number_of_augmentations):
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
		keras.layers.Conv2D(4, kernel_size=(5, 5), strides=(2, 2), input_shape=(image_height, image_width, number_of_color_channels)),
		keras.layers.Conv2D(4, kernel_size=(3, 3), strides=(1, 1), input_shape=(image_height, image_width, number_of_color_channels)),
		keras.layers.MaxPool2D(pool_size=(2, 2), padding="valid"),
		keras.layers.BatchNormalization(),
		keras.layers.LeakyReLU(),
		keras.layers.Conv2D(8, kernel_size=(3, 3), strides=(1, 1)),
		keras.layers.Conv2D(8, kernel_size=(3, 3), strides=(1, 1)),
		keras.layers.Conv2D(8, kernel_size=(3, 3), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(3, 3), padding="valid"),
		keras.layers.BatchNormalization(),
		keras.layers.LeakyReLU(),
		keras.layers.Conv2D(16, kernel_size=(3, 3), strides=(1, 1)),
		keras.layers.Conv2D(16, kernel_size=(3, 3), strides=(1, 1)),
		keras.layers.Conv2D(16, kernel_size=(3, 3), strides=(1, 1)),
		keras.layers.MaxPool2D(pool_size=(3, 3), padding="valid"),
		keras.layers.BatchNormalization(),
		keras.layers.LeakyReLU(),
		keras.layers.Flatten(),
		keras.layers.Dropout(0.5),
	    keras.layers.Dense(64, kernel_regularizer=keras.regularizers.l2(0.003), activation=tf.nn.relu),
	    keras.layers.GaussianNoise(0.2),
	    keras.layers.Dense(64, kernel_regularizer=keras.regularizers.l2(0.003), activation=tf.nn.relu),
	    keras.layers.Dropout(0.25),
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

	early_stopping = keras.callbacks.EarlyStopping(monitor='val_acc', patience=5, verbose=1)
	checkpoint = keras.callbacks.ModelCheckpoint("./Models/Nolmyra.h5", monitor='val_acc', verbose=1, save_best_only=True, save_weights_only=False, mode='auto', period=1)

	history = model.fit(train_data, train_labels, epochs=40, batch_size=10, validation_data=(test_images, test_labels), callbacks=[early_stopping, checkpoint] , verbose=1)
	return history

def loadImages(image_list, labels_list, folder, number_of_images):
	for i in range(0,len(image_libraries)):
		loadImageLibrary(image_libraries[i], folder, image_list, i, labels_list, 1, number_of_images)

def test(model, test_images,test_labels):
	print("Start testing...")
	test_loss, test_acc = model.evaluate(test_images, test_labels)
	print('Test accuracy:', test_acc)
	return test_loss, test_acc


def main():
	train_images = []
	train_labels = []
	loadImages(train_images, train_labels, "Train", 200)
	train_images = reshapeArray(train_images)

	test_images = []
	test_labels = []
	loadImages(test_images, test_labels, "Test", 39)
	test_images = reshapeArray(test_images)

	model = createModel()
	history = trainModel(model, train_images, train_labels, test_images, test_labels)
	model.save("./Models/recognizer.h5")

	# Release the memory from the train images
	train_images = []
	train_labels = []

	loss, accuracy = test(model, test_images, test_labels)

	plotter.graphTrainingData(history)

main()
