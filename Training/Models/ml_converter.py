import tfcoreml as tf_converter
tf_converter.convert(tf_model_path = 'output_graph.pb',
                     mlmodel_path = 'furniture_parts.mlmodel',
                     output_feature_names = ['k2tfout_0', 'k2tfout_1', 'k2tfout_2'],
                     input_name_shape_dict = {'input:0' : [1, 227, 227, 3]})