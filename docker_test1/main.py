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
import os
from google.cloud import storage
import pandas as pd
import numpy as np

# Authenticatation file to environment variable
# (how to do this in container on GCP)
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "cloudstoragepythonuploadtest-aab4aa8c67eb.json"


storage_client = storage.Client()
bucket = storage_client.bucket("brent_test_bucket")
blob = bucket.blob("docker_test.csv")
data = blob.download_as_bytes()
df = pd.read_csv(io.BytesIO(data), header=None, names=["Col1"])
messages = df['Col1'].tolist()

print(np.random.choice(messages))