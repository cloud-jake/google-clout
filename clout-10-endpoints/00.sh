#!/bin/bash
#
#  Resources here:  https://cloud.google.com/endpoints/docs/openapi/get-started-compute-engine-docker
#

source variables.inc

# APINAME

PROJECT=$(gcloud config get-value project 2> /dev/null)
REGION=`gcloud compute instances list  --format "get(zone)" | awk -F/ '{print $NF}' | awk -F "-" '{print $1 "-" $2 }'`
ZONE=`gcloud compute instances list  --format "get(zone)" | awk -F/ '{print $NF}'`
SERVER=`gcloud compute instances list  --format "get(name)" | awk -F/ '{print $NF}'`
SA=$(gcloud projects describe $PROJECT --format="value(projectNumber)")-compute@developer.gserviceaccount.com


# 0 - Before you start download the Open API sample configuration YAML file.
gsutil cp gs://cloud-training/clout/cloud-endpoints-api/openapi.yaml .


# 00 - Enable Services

gcloud services enable servicemanagement.googleapis.com
gcloud services enable servicecontrol.googleapis.com
gcloud services enable endpoints.googleapis.com


# 1 - Edit the file openapi.yaml file to set the correct parameters for this lab and then use that to deploy the Cloud Endpoints service.

#    Edit the host: property to include the Project ID for the lab $PROJECT .
#    Change the title property to change the name of the Endpoints API service from Endpoints Example to $APINAME .

sed -e "s/YOUR-PROJECT-ID/${PROJECT}/g" openapi.yaml > tmp1 && mv tmp1 openapi.yaml
sed -e "s/Endpoints Example/${APINAME}/g" openapi.yaml > tmp2 && mv tmp2 openapi.yaml

sed -e "s/SERVICE_NAME/echo-api.endpoints.${PROJECT}.cloud.goog/g" 03.sh > tmp3 && mv tmp3 03.sh

gcloud endpoints services deploy openapi.yaml


# 2 - Enable the Cloud Endpoints Service API name and bind the default Compute Engine service account to the role Service Management/Service Controller.


gcloud services enable echo-api.endpoints.${PROJECT}.cloud.goog

gcloud projects add-iam-policy-binding $PROJECT \
--member="serviceAccount:${SA}" \
--role="roles/servicemanagement.serviceController"

##################3

echo "Connect to GCE server ${TESTNAME} and run:"

cat 03.sh

gcloud compute ssh --zone $ZONE $SERVER   --project $PROJECT



