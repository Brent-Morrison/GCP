#!/usr/bin/env bash

# https://github.com/GoogleCloudPlatform/compute-gpu-installation
# https://gist.github.com/fabito/965b7d3e32307a5a0497f9f759e8bc83

# Variables
PROJECT_ID=cloudstoragepythonuploadtest
INSTANCE_NAME=brent-test-vm
LOCATION=australia-southeast2
ZONE=australia-southeast2-a
BUCKET_NAME=brent_test_bucket
OBJECT_LOCATION=/c/Users/brent/Documents/R/Misc_scripts/m01_preds.csv
DOCKER_REPO=dockerpy
DOCKER_IMAGE=myimage
DOCKER_TAG=tag6
JOB_NAME=test-job

echo "RUNNING"

# Set the project 
gcloud config set project ${PROJECT_ID}

# Create bucket from local development environment
gcloud storage buckets create gs://${BUCKET_NAME} --project=${PROJECT_ID} --location=${LOCATION}

# Upload local file to bucket
gcloud storage cp ${OBJECT_LOCATION} gs://${BUCKET_NAME}/

# Create VM instance
gcloud compute instances create ${INSTANCE_NAME} \
    --project=${PROJECT_ID} \
    --zone=${ZONE} \
    --machine-type=e2-standard-2 \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=240908920150-compute@developer.gserviceaccount.com \
    --scopes "https://www.googleapis.com/auth/cloud-platform" \
    --create-disk=boot=yes,device-name=test-vm-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20231101,size=10 \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring


# Python commands after SSH'ing in
# python3 -c "x='Goodbye'; y=' '; z='world'; print(x+y+z)"
# python3 -c "x=2; y=3; print(x+y)"

# SSH into VM
gcloud compute ssh --zone ${ZONE} ${INSTANCE_NAME}  --project ${PROJECT_ID}
#  ... or this should go into start up script

# Copy Python requirements
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/requirements.txt --output requirements.txt


# Install pip and use to install requirements
curl -sSL https://bootstrap.pypa.io/get-pip.py --output /usr/bin/python3/get-pip.py
python3 get-pip.py
python3 -m pip install -r requirements.txt

# Copy python script & run
curl https://raw.githubusercontent.com/Brent-Morrison/GCP/master/docker_test1/main.py --output main.py
python3 main.py

# Extract output to current directory
echo "SAVE RESULTS LOCALLY"
cd ~/GCP
gsutil cp gs://${BUCKET_NAME}/output.csv .