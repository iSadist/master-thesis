train:
	python trainer.py

convert:
	cd Models && python convertKerasToCoreML.py

generate-data:
	rm -rf Images/Train/ArtificialSeat/
	rm -rf Images/Train/ArtificialPiece1/
	rm -rf Images/Train/ArtificialPiece2/
	rm -rf Images/Train/ArtificialUnknownObjects/
	rm -rf Images/Test/ArtificialSeat/
	rm -rf Images/Test/ArtificialPiece1/
	rm -rf Images/Test/ArtificialPiece2/
	rm -rf Images/Test/ArtificialUnknownObjects/
	mkdir Images/Train/ArtificialSeat/
	mkdir Images/Train/ArtificialPiece1/
	mkdir Images/Train/ArtificialPiece2/
	mkdir Images/Train/ArtificialUnknownObjects/
	mkdir Images/Test/ArtificialSeat/
	mkdir Images/Test/ArtificialPiece1/
	mkdir Images/Test/ArtificialPiece2/
	mkdir Images/Test/ArtificialUnknownObjects/
	python artificialDataCreator.py

setup: 
	make generate-data
	make train
	make convert

install:
	pip install Pillow --user
	pip install tensorflow==1.5.0 --user
	pip install keras==2.1.3 --user
	pip install numpy --user
	pip install matplotlib --user
	pip install scikit-learn --user
	pip install tfcoreml --user
