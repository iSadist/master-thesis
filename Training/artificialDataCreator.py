from PIL import Image, ImageFilter, ImageEnhance

image_width = 200
image_height = 150

def create(name, number_of_images):
	for x in range(1,number_of_images):
		image = Image.open('./Images/' + name + '/image_' + str(x) + '.jpg')
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
		artificalImages.append(ImageEnhance.Brightness(image).enhance(0.7))
		artificalImages.append(ImageEnhance.Brightness(image_90).enhance(1.3))
		artificalImages.append(ImageEnhance.Brightness(image_270).enhance(0.4))
		artificalImages.append(ImageEnhance.Brightness(image_180.transpose(Image.FLIP_LEFT_RIGHT)).enhance(1.5))
		artificalImages.append(ImageEnhance.Contrast(image).enhance(1.4))
		artificalImages.append(ImageEnhance.Contrast(image_180).enhance(0.7))
		artificalImages.append(ImageEnhance.Color(image).enhance(0.5))
		artificalImages.append(ImageEnhance.Color(image.transpose(Image.FLIP_LEFT_RIGHT)).enhance(0.3))
		artificalImages.append(ImageEnhance.Color(image_270).enhance(1.6))
		artificalImages.append(ImageEnhance.Sharpness(image).enhance(0.0))
		artificalImages.append(ImageEnhance.Sharpness(image_180).enhance(2.0))
		artificalImages.append(image.filter(ImageFilter.GaussianBlur(1)))
		artificalImages.append(image_90.filter(ImageFilter.MinFilter(3)))

		num = 1
		for artificialImage in artificalImages:
			artificialImage.save("./Images/Artificial" + name + "/image_" + str(x) + "-" + str(num) + '.jpg', 'JPEG')
			num += 1

create('Seat', 77)
create('Piece1', 77)
create('Piece2', 77)
create('UnknownObjects', 77)
