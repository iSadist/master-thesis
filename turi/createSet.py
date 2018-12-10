import turicreate as tc

#use sframe containing all images
data = tc.SFrame('Nolmyra2.sframe')

train_set, test_set = data.random_split(0.8)

train_set.save("Train_Data.sframe")
test_set.save("Test_Data.sframe")
