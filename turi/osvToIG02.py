import turicreate as tc
import os

images_directory = 'images' # Change if applicable
csv_path = 'out.csv' # assumes CSV column format is image,id,name,xMin,xMax,yMin,yMax
csv_sf = tc.SFrame.read_csv(csv_path)
print("1.")
print(csv_sf)
def row_to_bbox_coordinates(row):
    """
    Takes a row and returns a dictionary representing bounding
    box coordinates:  (center_x, center_y, width, height)  e.g. {'x': 100, 'y': 120, 'width': 80, 'height': 120}
    """
    return {'x': row['xMin'] + (row['xMax'] - row['xMin'])/2,
            'width': (row['xMax'] - row['xMin']),
            'y': row['yMin'] + (row['yMax'] - row['yMin'])/2,
            'height': (row['yMax'] - row['yMin'])}

print("2.")
csv_sf['coordinates'] = csv_sf.apply(row_to_bbox_coordinates)
print(csv_sf)

# delete no longer needed columns
del csv_sf['id'], csv_sf['xMin'], csv_sf['xMax'], csv_sf['yMin'], csv_sf['yMax']
print(csv_sf)

# rename columns
csv_sf = csv_sf.rename({'name': 'label'})
print(csv_sf)
csv_sf = csv_sf.rename({'image': 'name'})
print(csv_sf)

# Load all images in random order
sf_images = tc.image_analysis.load_images(images_directory, recursive=True,
    random_order=True)

# Split path to get filename
info = sf_images['path'].apply(lambda path: os.path.basename(path).split('/')[:1])

# Rename columns to 'name'
info = info.unpack().rename({'X.0': 'name'})

# Add to our main SFrame
sf_images = sf_images.add_columns(info)

# Original path no longer needed
del sf_images['path']

# Combine label and coordinates into a bounding box dictionary
csv_sf = csv_sf.pack_columns(['label', 'coordinates'], new_column_name='bbox', dtype=dict)

# Combine bounding boxes of the same 'name' into lists
sf_annotations = csv_sf.groupby('name',
    {'annotations': tc.aggregate.CONCAT('bbox')})

# Join annotations with the images. Note, some images do not have annotations,
# but we still want to keep them in the dataset. This is why it is important to
# a LEFT join.
sf = sf_images.join(sf_annotations, on='name', how='left')

# The LEFT join fills missing matches with None, so we replace these with empty
# lists instead using fillna.
sf['annotations'] = sf['annotations'].fillna([])

# Save SFrame
sf.save('ig02.sframe')
