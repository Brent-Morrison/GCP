#!/usr/bin/env bash

# Variables
PROJECT_ID=cloudstoragepythonuploadtest
INSTANCE_NAME=brent-test-vm
LOCATION=australia-southeast2-a

gcloud compute instances create ${INSTANCE_NAME} \
    --project=${PROJECT_ID} \
    --zone=${LOCATION} \
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