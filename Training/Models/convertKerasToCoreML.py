import coremltools

coreml_model = coremltools.converters.keras.convert('recognizer.h5',
	input_names="image",
	image_input_names="image",
	image_scale=1,
	is_bgr=False,
	class_labels = ['Unknown', 'Seat', 'Piece 1', "Piece 2"])
coreml_model.save('Furniture.mlmodel')
