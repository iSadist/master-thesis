import turicreate as tc
tc.config.set_num_gpus(0)

# Load the data

train_data = tc.SFrame("Train_Data.sframe")

#Random split train data to get specific training size
train_data, unused_data = train_data.random_split(1.0)


test_data = tc.SFrame("Test_Data.sframe")

# Create a model
model = tc.object_detector.create(train_data)

# Save predictions to an SArray
predictions = model.predict(test_data)
print(predictions)
# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data,metric='mean_average_precision')
print(metrics)
# Save the model for later use in Turi Create
model.save('Nolmyra3.model')

# Export for use in Core ML
model.export_coreml('Nolmyra3.mlmodel', include_non_maximum_suppression=False)
