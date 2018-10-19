from PIL import Image, ImageFilter, ImageEnhance
from sklearn.utils import shuffle

image_width = 256
image_height = 256

def create(name, folder, number_of_images):
	image_numbers = range(1,number_of_images + 1)
	image_numbers = shuffle(image_numbers)

	for x in range(1, len(image_numbers) + 1):
		image = Image.open('./Images/' + folder + '/' + name + '/image_' + str(image_numbers[x-1]) + '.jpg')
		image = image.resize((image_width,image_height),Image.LANCZOS)

		image_90 = image.rotate(90)
		image_180 = image.rotate(180)
		image_270 = image.rotate(270)
		artificalImages = []

		artificalImages.append(image)
		artificalImages.append(image_90)
		artificalImages.append(image_180)
		artificalImages.append(image_270)
		artificalImages.append(image.transpose(Image.FLIP_LEFT_RIGHT))
		artificalImages.append(ImageEnhance.Brightness(image_90).enhance(1.3))
		artificalImages.append(ImageEnhance.Brightness(image_180.transpose(Image.FLIP_LEFT_RIGHT)).enhance(1.5))
		artificalImages.append(ImageEnhance.Contrast(image).enhance(1.4))
		artificalImages.append(ImageEnhance.Contrast(image_180).enhance(0.7))
		artificalImages.append(ImageEnhance.Color(image).enhance(0.5))
		artificalImages.append(ImageEnhance.Color(image.transpose(Image.FLIP_LEFT_RIGHT)).enhance(0.3))
		artificalImages.append(ImageEnhance.Color(image_270).enhance(1.6))

		num = 1
		for artificialImage in artificalImages:
			artificialImage.save("./Images/" + folder + "/Artificial" + name + "/image_" + str(x) + "-" + str(num) + '.jpg', 'JPEG')
			num += 1

create('Seat', 'Train', 200)
create('Piece1', 'Train', 200)
create('Piece2', 'Train', 200)
create('UnknownObjects', 'Train', 200)

create('Seat', 'Test', 39)
create('Piece1', 'Test', 39)
create('Piece2', 'Test', 39)
create('UnknownObjects', 'Test', 39)
