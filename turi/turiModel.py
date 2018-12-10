import turicreate as tc
tc.config.set_num_gpus(0)

# Load the data
data =  tc.SFrame('Nolmyra.sframe')

# Make a train-test split
train_data, test_data = data.random_split(0.8)

# Create a model
model = tc.object_detector.create(train_data)

# Save predictions to an SArray
predictions = model.predict(test_data)
print(predictions)
# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data)
print(metrics)
# Save the model for later use in Turi Create
model.save('Nolmyra.model')

# Export for use in Core ML
model.export_coreml('Nolmyra.mlmodel')
