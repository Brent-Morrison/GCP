#!/usr/bin/env bash

# https://cloud.google.com/compute/docs/containers/deploying-containers

# Variables
PROJECT_ID=cloudstoragepythonuploadtest
LOCATION=australia-southeast2
BUCKET_NAME=brent_test_bucket
OBJECT_LOCATION=/c/Users/brent/Documents/R/Misc_scripts/docker_test.csv
DOCKER_REPO=dockerpy
DOCKER_IMAGE=myimage
DOCKER_TAG=tag1
JOB_NAME=test-job

# Set the project 
gcloud config set project ${PROJECT_ID}

# Create bucket from local development environment
gcloud storage buckets create gs://${BUCKET_NAME} --project=${PROJECT_ID} --location=${LOCATION}

# Upload local file to bucket
gcloud storage cp ${OBJECT_LOCATION} gs://${BUCKET_NAME}/

# Create artifact repository for Docker in GCP
gcloud artifacts repositories create ${DOCKER_REPO} \
--repository-format=docker \
--location=${LOCATION} \
--description="Docker python test"

# Build the docker image 
# -must cd to folder containing dockerfile
# -must have docker desktop open
cd GCP/docker_test1
docker image build --tag ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG} .

# Run locally
docker run --rm -it ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG}

# Push docker image from local machine to GCP artifact registry
gcloud auth activate-service-account cloudstoragepy@cloudstoragepythonuploadtest.iam.gserviceaccount.com \
--key-file=/home/brent/GCP/cloudstoragepythonuploadtest-aab4aa8c67eb.json
gcloud auth configure-docker ${LOCATION}-docker.pkg.dev
docker push ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG}

# Deploy image with GCP Run (https://cloud.google.com/run/docs/create-jobs)
gcloud beta run jobs deploy ${JOB_NAME} --image ${LOCATION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG} --region ${LOCATION}

# Run job
gcloud beta run jobs execute ${JOB_NAME} --region ${LOCATION}

# Inspect output
#xxxxx

# Delete artifact registry repo & bucket
gcloud artifacts repositories delete ${DOCKER_REPO} --location=${LOCATION} --async
gcloud storage rm --recursive gs://${BUCKET_NAME}