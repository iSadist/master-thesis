import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from sklearn.utils import shuffle

image_width = 800
image_height = 600
number_of_color_channels = 3

training_batch_size = 60
image_libraries = ["Seat", "Piece1", "Piece2"]

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
	print("Adding image " + filename)
	image = Image.open(filename)
	image_list.append(list(image.getdata()))
	label_list.append(label)
	return

def reshapeArray(oldArray):
	print("Reshaping...")
	npArray = np.array(oldArray)
	reshapedArray = npArray.reshape((len(oldArray), image_width, image_height, number_of_color_channels))
	return reshapedArray

def createModel():
	# Create the neural network
	model = keras.Sequential([
		keras.layers.Conv2D(16, kernel_size=(4, 4), strides=(4, 4), input_shape=(image_width, image_height, number_of_color_channels)),
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
	    keras.layers.Dense(3, activation=tf.nn.softmax) # The number of nodes must be the same as the number of possibilities
	])

	model.compile(optimizer=keras.optimizers.Adam(),
	              loss='sparse_categorical_crossentropy',
	              metrics=['accuracy'])
	model.summary()
	return model

def trainModel(model, train_data, train_labels):
	print("Starting training...")
	model.fit(train_images, train_labels, epochs=20)

def loadTrainImages(image_list, labels_list):
	for i in xrange(1,len(image_libraries)):
		loadImageLibrary(image_libraries[i-1], image_list, i-1, labels_list, 1, training_batch_size)

def loadTestImages(image_list, labels_list):
	for i in xrange(1,len(image_libraries)):
		loadImageLibrary(image_libraries[i-1], image_list, i-1, labels_list, training_batch_size + 1, 77)

def test():
	print("Start testing...")
	loadTestImages(test_images, test_labels)
	test_images = reshapeArray(test_images)
	test_loss, test_acc = model.evaluate(test_images, test_labels)
	print('Test accuracy:', test_acc)

def main():
	train_images = []
	train_labels = []

	test_images = []
	test_labels = []

	loadTrainImages(train_images, train_labels)
	train_images = reshapeArray(train_images)
	# train_images, train_labels = shuffle(train_images, train_labels)

	model = createModel()

	trainModel(model, train_images, train_labels)
	test()
	model.save("./Models/recognizer.h5")

main()
