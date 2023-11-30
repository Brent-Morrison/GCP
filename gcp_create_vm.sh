#!/usr/bin/env bash

# https://cloud.google.com/compute/docs/instances/startup-scripts
# https://github.com/GoogleCloudPlatform/compute-gpu-installation
# https://gist.github.com/fabito/965b7d3e32307a5a0497f9f759e8bc83
# https://stackoverflow.com/questions/63854277/is-there-a-way-to-execute-commands-remotely-using-gcloud-compute-ssh-utility
# https://stackoverflow.com/questions/66038905/how-to-run-local-shell-script-on-remote-gcp-machine-via-gcloud-compute

# Variables
printf "\n----- SET VARIABLES\n\n"
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
DELETE=true

# Set the project 
gcloud config set project ${PROJECT_ID}

# Create bucket from local development environment
printf "\n----- COPY FILES TO STORAGE\n\n"
gcloud storage buckets create gs://${BUCKET_NAME} --project=${PROJECT_ID} --location=${LOCATION}

# Upload local file to bucket
gcloud storage cp ${OBJECT_LOCATION} gs://${BUCKET_NAME}/

# Create VM instance
printf "\n----- CREATE VM\n\n"
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
    --shielded-integrity-monitoring \
    --metadata-from-file=startup-script=startup.sh

# Extract output to current directory
# - checks file existence as copy from VM can be delayed
printf "\n----- SAVE RESULTS LOCALLY\n\n"
cd ~/GCP

count=0
file_path=gs://${BUCKET_NAME}/output.csv
while [ $count -lt 10 ]; do
    # Check if file exists in GCP storage
    if [ "$(gsutil -q stat $file_path ; echo $?)" = 0 ]; then
        # Download & exit
        gsutil cp gs://${BUCKET_NAME}/output.csv .
        printf "\n----- DOWNLOAD COMPLETE\n\n"
        break
    fi
    # Increment the counter 
    ((count++)) 
    if [ $count = 10 ]; then printf "\n----- UNABLE TO DOWNLOAD\n\n"; fi
    sleep 10
done


# Delete artifact registry repo & bucket
if $DELETE
then
  printf "\n----- DELETE VM INSTANCE AND BUCKET\n\n"
  gcloud storage rm -q -r gs://${BUCKET_NAME}
  gcloud compute instances delete -q ${INSTANCE_NAME} --zone=${ZONE}
fi

printf "\n----- SCRIPT COMPLETE\n\n"