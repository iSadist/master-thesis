from PIL import Image, ImageFilter, ImageEnhance

for x in xrange(2253,2424):
	image = Image.open('./Images/Piece1/IMG_' + str(x) + '.jpg')
	artificalImages = []

	artificalImages.append(image.rotate(45))
	artificalImages.append(image.rotate(90))
	artificalImages.append(image.rotate(-45))
	artificalImages.append(image.rotate(-90))
	artificalImages.append(ImageEnhance.Brightness(image).enhance(0.8))
	artificalImages.append(ImageEnhance.Brightness(image).enhance(1.2))
	artificalImages.append(ImageEnhance.Contrast(image).enhance(1.4))
	artificalImages.append(ImageEnhance.Contrast(image).enhance(0.7))
	artificalImages.append(ImageEnhance.Color(image).enhance(0.5))
	artificalImages.append(ImageEnhance.Color(image).enhance(1.6))
	artificalImages.append(ImageEnhance.Sharpness(image).enhance(0.0))
	artificalImages.append(ImageEnhance.Sharpness(image).enhance(2.0))

	num = 1
	for artificialImage in artificalImages:
		artificialImage.save("./Images/ArtificialPiece1/IMG_" + str(x) + "-" + str(num) + '.jpg', 'JPEG')
		num += 1
		pass
	pass