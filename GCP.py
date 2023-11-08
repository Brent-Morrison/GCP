# https://github.com/googleapis/python-storage/tree/main/samples/snippets
import os
from google.cloud import storage

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "cloudstoragepythonuploadtest-aab4aa8c67eb.json"

bucket_name = "brent_test_bucket"
#bucket = storage_client.bucket(bucket_name)
#bucket.location = "US" # AUSTRALIA-SOUTHEAST2
#bucket = storage_client.create_bucket(bucket)

def create_bucket_class_location(bucket_name):
    """
    Create a new bucket
    """
    # bucket_name = "your-new-bucket-name"

    storage_client = storage.Client()

    bucket = storage_client.bucket(bucket_name)
    new_bucket = storage_client.create_bucket(bucket, location="AUSTRALIA-SOUTHEAST2")

    print(
        "Created bucket {} in {} with storage class {}".format(
            new_bucket.name, new_bucket.location, new_bucket.storage_class
        )
    )
    return new_bucket

create_bucket_class_location(bucket_name)

# --------------

storage_client = storage.Client()
vars(storage_client.get_bucket(bucket_name))

# --------------

def upload_blob_to_bucket(source_file, blob_name, bucket_name):
    try:
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        blob.upload_from_filename(source_file)
        return True
    except Exception as e:
        print(e)
        return False
    
source_file = '/c/Users/brent/Documents/R/Misc_scripts/m01_preds.csv'
upload_blob_to_bucket(source_file, "test_csv", bucket_name)
