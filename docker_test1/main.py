"""
import random

messages = [
    "You're great!",
    "Happiness is a choice.",
    "The refs cheated",
    "You're pretty good at programming",
    "Live, love, laugh",
    "Think positively and positive things will happen."
]

print(random.choice(messages))
"""

import io
#import os
from google.cloud import storage
import pandas as pd
#import numpy as np

def gcp_csv_to_df(bucket_name, source_file_name):
    """
    File extension is NOT required for parameter "source_file_name" ?????
    """

    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(source_file_name)
    data = blob.download_as_bytes()
    df = pd.read_csv(io.BytesIO(data))
    
    return df

df = gcp_csv_to_df("brent_test_bucket", "m01_preds.csv")


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

new_df = df[['lower','upper']].copy() 

write_df_gcs_csv(new_df, "brent_test_bucket", "write_test1.csv")