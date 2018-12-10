import turicreate as tc
import PIL

# Load the data
train_data = tc.SFrame("Train_Data.sframe")

#Random split train data to get specific training size
train_data, unused_data = train_data.random_split(0.05)

test_data = tc.SFrame("Test_Data.sframe")

# Create a model
model = tc.load_model('Nolmyra.model')

# Save predictions to an SArray
predictions = model.predict(test_data)

predictions_stacked = tc.object_detector.util.stack_annotations(predictions)

image_prediction = tc.object_detector.util.draw_bounding_boxes(test_data['image'], predictions)
#print(predictions_stacked)

#To generate an image with bounding box, use code below
#image_prediction[0].show()


# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data,metric='mean_average_precision')
print(metrics)



#model.export_coreml('NolmyraNet.mlmodel', include_non_maximum_suppression=False)
