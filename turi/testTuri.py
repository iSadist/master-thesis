import turicreate as tc

# Load the data
data =  tc.SFrame('Nolmyra.sframe')

# Make a train-test split
train_data, test_data = data.random_split(0.8)

# Create a model
model = tc.load_model('Nolmyra.model')

# Save predictions to an SArray
#predictions = model.predict(test_data)

#predictions_stacked = tc.object_detector.util.stack_annotations(predictions)
#print(predictions_stacked)

# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data,metric='mean_average_precision')
print(metrics)



#model.export_coreml('NolmyraNet.mlmodel', include_non_maximum_suppression=False)
