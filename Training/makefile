train:
	python trainer.py

convert:
	cd Models && python convertKerasToCoreML.py

generate-data:
	rm -rf Images/ArtificialSeat/
	rm -rf Images/ArtificialPiece1/
	rm -rf Images/ArtificialPiece2/
	rm -rf Images/ArtificialUnknownObjects/
	rm -rf Images/ArtificialBackgrounds/
	rm -rf Images/ArtificialPiece1Cutouts/
	rm -rf Images/ArtificialPiece2Cutouts/
	rm -rf Images/ArtificialSeatCutouts/
	mkdir Images/ArtificialSeat/
	mkdir Images/ArtificialPiece1/
	mkdir Images/ArtificialPiece2/
	mkdir Images/ArtificialUnknownObjects/
	mkdir Images/ArtificialBackgrounds/
	mkdir Images/ArtificialPiece1Cutouts/
	mkdir Images/ArtificialPiece2Cutouts/
	mkdir Images/ArtificialSeatCutouts/
	python artificialDataCreator.py

setup: 
	make generate-data
	make train
	make convert

install:
	pip install Pillow --user
	pip install tensorflow --user
	pip install keras==2.1.6 --user
	pip install numpy --user
	pip install matplotlib --user
	pip install scikit-learn --user
	pip install tfcoreml --user
