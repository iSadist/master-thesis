from PIL import Image, ImageFilter, ImageEnhance

for x in xrange(1,77):
	image = Image.open('./Images/Seat/image_' + str(x) + '.jpg')
	image = image.resize((800,600),Image.LANCZOS)

	image_90 = image.transpose(Image.ROTATE_90).resize((800,600),Image.LANCZOS)
	image_180 = image.transpose(Image.ROTATE_180)
	image_270 = image.transpose(Image.ROTATE_270).resize((800,600),Image.LANCZOS)
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
		artificialImage.save("./Images/ArtificialSeat/image_" + str(x) + "-" + str(num) + '.jpg', 'JPEG')
		num += 1
		pass
	pass
