train:
	python trainer.py

convert:
	cd Models && python convertKerasToCoreML.py

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

	rm -rf Images/ArtificialUnknownObjects/
	mkdir Images/ArtificialUnknownObjects/
	python artificialDataCreatorUnknown.py

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
