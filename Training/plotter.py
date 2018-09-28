import tensorflow as tf
from tensorflow import keras
import numpy as np
import matplotlib.pyplot as plt

def graphTrainingData(history):
		acc = history.history['acc']
		val_acc = history.history['val_acc']
		loss = history.history['loss']
		val_loss = history.history['val_loss']

		epochs = range(1, len(acc) + 1)

		plt.plot(epochs, acc, 'bo', label='Training acc')
		plt.plot(epochs, val_acc, 'b', label='Validation acc')
		plt.title('Training and validation accuracy')
		plt.xlabel('Epochs')
		plt.ylabel('Accuracy')

		plt.show()