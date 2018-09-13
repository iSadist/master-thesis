import coremltools

coreml_model = coremltools.converters.keras.convert('recognizer.h5',
	input_names="image",
	image_input_names="image",
	image_scale=1/255.0,
	is_bgr=False)
coreml_model.save('my_model.mlmodel')
