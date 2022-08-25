#!/bin/bash

BUCKET=


# 0 - gather files
gsutil cp gs://cloud-training/clout/event-driven-functions/source/main.py .
gsutil cp gs://cloud-training/clout/event-driven-functions/source/requirements.txt .

# 00 - Enable Cloud Functions API
gcloud services enable cloudfunctions.googleapis.com cloudbuild.googleapis.com

# 1 - Create Bucket
gsutil mb gs://${BUCKET}


# 2 - Create Cloud Function and deploy to trigger on google.storage.object.finalize for bucket we created
gcloud functions deploy cloud_function --runtime python310 --trigger-resource gs://${BUCKET} --trigger-event google.storage.object.finalize


# 3 - Copy a file to new Bucket
gsutil cp requirements.txt gs://${BUCKET}/

# 4 - Confirm JSON file created
gsutil ls gs://${BUCKET}/cloud_fn_output.json  



