import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from sklearn.utils import shuffle

image_width = 800
image_height = 600

training_batch_size = 60

# # Load test image dataset from tensorflow
# fashion_mnist = keras.datasets.fashion_mnist
# (train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

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
	image_list.append(list(image.getdata(0)))
	label_list.append(label)
	return

# Create the neural network
model = keras.Sequential([
	keras.layers.Conv2D(16, kernel_size=(4, 4), strides=(4, 4), input_shape=(image_width, image_height, 1)),
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



# Load images from datasets

train_images = []
train_labels = []

loadImageLibrary('Seat', train_images, 0, train_labels, 1, training_batch_size)
loadImageLibrary('Piece1', train_images, 1, train_labels, 1, training_batch_size)
loadImageLibrary('Piece2', train_images, 2, train_labels, 1, training_batch_size)

print("Importing images complete!")
print("--------------------------------")
print("Reshaping to fit train images...")

train_images = np.array(train_images).reshape(len(train_images), image_width, image_height, 1)

train_images, train_labels = shuffle(train_images, train_labels)

print("Reshaping complete!")
print("Starting training...")

model.fit(train_images, train_labels, epochs=50)

print("Training complete!")

print("Starting testing...")

test_images = []
test_labels = []

loadImageLibrary('Seat', test_images, 0, test_labels, training_batch_size + 1, 77)
loadImageLibrary('Piece1', test_images, 1, test_labels, training_batch_size + 1, 77)
loadImageLibrary('Piece2', test_images, 2, test_labels, training_batch_size + 1, 77)

test_images = np.array(test_images).reshape(len(test_images), image_width, image_height, 1)

# Evaluate the model
test_loss, test_acc = model.evaluate(test_images, test_labels)
print('Test accuracy:', test_acc)

model.save("recognizer.h5")
