import turicreate as tc
import PIL

# Load the data
train_data = tc.SFrame("Train_Data.sframe")


#Count the classes within the training set
x = train_data['annotations']
seats = 0
piece1 = 0
piece2 = 0
conjoinedPiece1 = 0
conjoinedPiece2 = 0
conjoinedPiece3 = 0

for item in x:
    if len(item) > 0:
         if item[0]['label'] == 'seat':
             seats = seats + 1
         elif item[0]['label'] == 'piece1':
             piece1 = piece1 + 1
         elif item[0]['label'] == 'piece2':
             piece2 = piece2 + 1
         elif item[0]['label'] == 'conjoinedPiece1':
             conjoinedPiece1 = conjoinedPiece1 + 1
         elif item[0]['label'] == 'conjoinedPiece2':
             conjoinedPiece2 = conjoinedPiece2 + 1
         elif item[0]['label'] == 'conjoinedPiece3':
             conjoinedPiece3 = conjoinedPiece3 + 1

print('Training:')
print('seat: {}'.format(seats))
print('piece1: {}'.format(piece1))
print('piece 2: {}'.format(piece2))
print('conjoinedPiece1: {}'.format(conjoinedPiece1))
print('conjoinedPiece2: {}'.format(conjoinedPiece2))
print('conjoinedPiece3: {}'.format(conjoinedPiece3))

#Random split train data to get specific training size

test_data = tc.SFrame("Test_Data.sframe")

#Count the classes within the test set
x = test_data['annotations']
seats = 0
piece1 = 0
piece2 = 0
conjoinedPiece1 = 0
conjoinedPiece2 = 0
conjoinedPiece3 = 0

for item in x:
    if len(item) > 0:
         if item[0]['label'] == 'seat':
             seats = seats + 1
         elif item[0]['label'] == 'piece1':
             piece1 = piece1 + 1
         elif item[0]['label'] == 'piece2':
             piece2 = piece2 + 1
         elif item[0]['label'] == 'conjoinedPiece1':
             conjoinedPiece1 = conjoinedPiece1 + 1
         elif item[0]['label'] == 'conjoinedPiece2':
             conjoinedPiece2 = conjoinedPiece2 + 1
         elif item[0]['label'] == 'conjoinedPiece3':
             conjoinedPiece3 = conjoinedPiece3 + 1

print('Testing:')
print('seat: {}'.format(seats))
print('piece1: {}'.format(piece1))
print('piece 2: {}'.format(piece2))
print('conjoinedPiece1: {}'.format(conjoinedPiece1))
print('conjoinedPiece2: {}'.format(conjoinedPiece2))
print('conjoinedPiece3: {}'.format(conjoinedPiece3))

# Create a model
model = tc.load_model('Nolmyra005.model')

# Save predictions to an SArray
#predictions = model.predict(test_data)

#predictions_stacked = tc.object_detector.util.stack_annotations(predictions)

#image_prediction = tc.object_detector.util.draw_bounding_boxes(test_data['image'], predictions)
#print(predictions_stacked)

#To generate an image with bounding box, use code below
#image_prediction.explore()


# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data,metric='mean_average_precision')
print(metrics)



#model.export_coreml('NolmyraNet.mlmodel', include_non_maximum_suppression=False)
