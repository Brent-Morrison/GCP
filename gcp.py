# https://github.com/googleapis/python-storage/tree/main/samples/snippets
import os
import io
from google.cloud import storage


# Authenticatation file to environment variable
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "cloudstoragepythonuploadtest-aab4aa8c67eb.json"

# --------------

def create_bucket_class_location(bucket_name):
    """
    Create a new bucket
    """

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    new_bucket = storage_client.create_bucket(bucket, location="AUSTRALIA-SOUTHEAST2")

    return new_bucket

bucket_name = "brent_test_bucket"
create_bucket_class_location(bucket_name)


# --------------

def upload_blob_to_bucket(source_file, blob_name, bucket_name):
    try:
        storage_client = storage.Client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        blob.upload_from_filename(source_file)
        return True
    except Exception as e:
        print(e)
        return False
  
source_file = '/c/Users/brent/Documents/R/Misc_scripts/m01_preds.csv'
upload_blob_to_bucket(source_file, "test_csv", bucket_name)


# --------------
# https://stackoverflow.com/a/67363270

import pandas as pd
def gcp_csv_to_df(bucket_name, source_file_name):
    """
    File extension is NOT required for parameter "source_file_name"
    """

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(source_file_name)
    data = blob.download_as_bytes()
    df = pd.read_csv(io.BytesIO(data))
    
    return df

df = gcp_csv_to_df("brent_test_bucket", "test_csv")

# --------------
# https://github.com/googleapis/python-storage/blob/main/samples/snippets/storage_fileio_pandas.py

def write_df_gcs_csv(df, bucket_name, blob_name):
    """
    Use pandas to interact with GCS using file-like IO
    File extension IS required for parameter "blob_name"
    """
    # The ID of your GCS bucket
    # bucket_name = "your-bucket-name"

    # The ID of your new GCS object
    # blob_name = "storage-object-name"

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(blob_name)

    with blob.open("w") as f:
        f.write(df.to_csv(index=False))

    print(f"Wrote csv with pandas with name {blob_name} from bucket {bucket_name}.")

new_df = df[['lower','upper']].copy() #pd.DataFrame({'a': [1, 2, 3], 'b': [4, 5, 6]})
write_df_gcs_csv(new_df, "brent_test_bucket", "write_test1.csv")