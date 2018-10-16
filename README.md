# master-thesis - Object Recognition in AR
This repository contains the code, the results and documents used for our master thesis project in Engineering. 
The end result is a furniture setup guide for iOS that utilizes Augmented Reality, Object Detection and Object Recognition. 
For further in depth explanation about the project and its goal, read the report in Documents/Report. 

## Setup Training
To train and generate the CoreML model for the network, using our model built from scratch, enter the Trainer directory. 
First you need to install the following dependencies: 
* Pillow 
* tensorflow 
* keras version 2.1.6
* numpy
* matplotlib
* scikit-learn 
* tfcoreml

These can all be installed by running 
```make
make install
```

To then scale the images and also generate artificiall data, run:
```make
make generate-data
```

After generating the data, you can train a keras model with the following command:
```make
make train
```

One then has to convert the keras .h5 model to a .mlmodel file, which is then useable in the Xcode project. This is done by running:
```make
make convert
```
To run the three aforementioned commands in one go, just write:
```make
make setup
```

## Setup Transfer Learning
To try out the transfer learning method, enter the FeatureTraining.
First you need to run the python script *resize.py* which scales the original images to correct image size.
Then you can train the net by running *transferLearning.py*, which will generate a .h5 file. Currently no direct way to convert this to a .mlmodel file. At the moment, you have to make use of the *convertKerasToCoreML.py* script in Trainer/Model folder.

## Xcode project and setup
To be able to compile the project xcode, you have to have a .mlmodel file named *FurnitureNet.mlmodel* in the folder Trainer/Model.

A UML Class diagram showing the flow of the project can be seen bellow.
![UML Diagram of the clases within the xcode project](https://github.com/iSadist/master-thesis/blob/master/Documents/UML/ClassDiagram1.jpg?raw=true)

## Documents
Further interesting links, the report and other goodie documents can be fold in the Documents folder.

## Authors
Created by Jan Svensson(*iSadist*) and Jonatan Atles(*Oden-Allfader*)
