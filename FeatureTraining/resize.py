from PIL import Image, ImageFilter, ImageEnhance

image_width = 256
image_height = 256
start = 1
middle = 130
end = 154
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

create('seat', start, middle, 'train')
create('piece1', start ,middle , 'train')
create('piece2', start, middle, 'train')
create('unknownObjects', start,middle, 'train')
create('seat', middle,end, 'val')
create('piece1', middle,end, 'val')
create('piece2', middle,end, 'val')
create('unknownObjects', middle,end, 'val')
