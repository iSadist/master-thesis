run:
	python trainer.py

convertToPb:
	cd Models && python keras_converter.py -m ./recognizer.h5 -n 3

convertToCoreML:
	cd Models && python ml_converter.py

convertModel:
	make convertToPb && make convertToCoreML

generate-data:
	rm -rf Images/ArtificialSeat/
	mkdir Images/ArtificialSeat/
	python artificialDataCreator.py

	rm -rf Images/ArtificialPiece1/
	mkdir Images/ArtificialPiece1/
	python artificialDataCreatorPiece1.py

	rm -rf Images/ArtificialPiece2/
	mkdir Images/ArtificialPiece2/
	python artificialDataCreatorPiece2.py

install:
	pip install Pillow --user
	pip install tensorflow --user
	pip install numpy --user
	pip install matplotlib --user
	pip install scikit-learn --user
	pip install tfcoreml --user