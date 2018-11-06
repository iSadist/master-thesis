import turicreate as tc

# Load the data
data =  tc.SFrame('ig02.sframe')

# Make a train-test split
train_data, test_data = data.random_split(0.8)

# Create a model
model = tc.load_model('mymodel.model')

# Save predictions to an SArray
predictions = model.predict(data)
print(predictions)
# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(data)
#model.export_coreml('MyDetector.mlmodel', include_non_maximum_suppression=False)

print(metrics)
