run:
	python trainer.py

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