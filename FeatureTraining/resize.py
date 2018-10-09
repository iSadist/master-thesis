from PIL import Image, ImageFilter, ImageEnhance

image_width = 256
image_height = 256

def create(name, start, end, type):
	for x in range(start,end):
		image = Image.open("./" + name + '/image_' + str(x) + '.jpg')
		image = image.resize((image_width,image_height),Image.LANCZOS)
		artificalImages = []

		artificalImages.append(image)
		num = 1
		for artificialImage in artificalImages:
			artificialImage.save("./data/" + type + "/" + name + "/image_" +str(x) + '.jpg', 'JPEG')
			num += 1

#create('seat', 1,60, 'train')
#create('piece1', 1,60, 'train')
#create('piece2', 1,60, 'train')
#create('unknownObjects', 1,60, 'train')
create('seat', 61,77, 'val')
create('piece1', 61,77, 'val')
create('piece2', 61,77, 'val')
#create('unknownObjects', 61,77, 'val')
