#!/usr/bin/env bash

# https://cloud.google.com/compute/docs/containers/deploying-containers

# Variables
PROJECT_ID=cloudstoragepythonuploadtest
LOCATION=australia-southeast2
BUCKET_NAME=brent_test_bucket
OBJECT_LOCATION=/c/Users/brent/Documents/R/Misc_scripts/docker_test.csv
DOCKER_REPO=dockerpy
DOCKER_IMAGE=myimage
DOCKER_TAG=tag4
JOB_NAME=test-job

echo "PRELIMINARY: SET PROJECT, CREDENTIALS & ACTIVATE SERVICE ACCOUNT"

# Set the project 
gcloud config set project ${PROJECT_ID}

# Activate service account
gcloud auth activate-service-account cloudstoragepy@cloudstoragepythonuploadtest.iam.gserviceaccount.com \
--key-file=cloudstoragepythonuploadtest-aab4aa8c67eb.json

# Create bucket from local development environment
gcloud storage buckets create gs://${BUCKET_NAME} --project=${PROJECT_ID} --location=${LOCATION}

# Upload local file to bucket
gcloud storage cp ${OBJECT_LOCATION} gs://${BUCKET_NAME}/

# Create artifact repository for Docker in GCP
echo "CREATE ARTIFACT REPO"
gcloud artifacts repositories create ${DOCKER_REPO} \
--repository-format=docker \
--location=${LOCATION} \
--description="Docker python test"

# Build the docker image 
# -must cd to folder containing dockerfile
# -must have docker desktop open
echo "BUILD DOCKER IMAGE"
cd docker_test1
docker image build --tag ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG} .

# Run locally
# https://cloud.google.com/run/docs/testing/local#docker-with-google-cloud-access
# https://medium.com/google-cloud/use-google-cloud-user-credentials-when-testing-containers-locally-acb57cd4e4da
# https://stackoverflow.com/questions/57137863/set-google-application-credentials-in-docker

echo "RUN DOCKER IMAGE LOCALLY"
cd ..

# Credentials to env variable for use in container
export GOOGLE_APPLICATION_CREDENTIALS="/home/brent/GCP/cloudstoragepythonuploadtest-aab4aa8c67eb.json"

# Run
docker run --rm -it ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG} \
--env GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS \
--volume $GOOGLE_APPLICATION_CREDENTIALS:$GOOGLE_APPLICATION_CREDENTIALS:ro

# Push docker image from local machine to GCP artifact registry
echo "PUSH DOCKER IMAGE TO CLOUD"
gcloud auth configure-docker ${LOCATION}-docker.pkg.dev
docker push ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG}

# Deploy image with GCP Run (https://cloud.google.com/run/docs/create-jobs)
echo "DEPLOY DOCKER IMAGE"
gcloud beta run jobs deploy ${JOB_NAME} --image ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG} --region ${LOCATION}

# Run job
echo "RUN DOCKER IMAGE"
gcloud beta run jobs execute ${JOB_NAME} --region ${LOCATION}

# Inspect output
#xxxxx

# Delete artifact registry repo & bucket
echo "DELETE REPO AND BUCKET"
gcloud artifacts repositories delete ${DOCKER_REPO} --location=${LOCATION} --async
gcloud storage rm --recursive gs://${BUCKET_NAME}