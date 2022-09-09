#!/bin/bash

source variables.inc

# APINAME
# SERVER

PROJECT=$(gcloud config get-value project 2> /dev/null)
REGION=`gcloud compute instances list  --format "get(zone)" | awk -F/ '{print $NF}' | awk -F "-" '{print $1 "-" $2 }'`
ZONE=`gcloud compute instances list  --format "get(zone)" | awk -F/ '{print $NF}'`
SERVER=`gcloud compute instances list  --format "get(name)" | awk -F/ '{print $NF}'`
SA=$(gcloud projects describe $PROJECT --format="value(projectNumber)")-compute@developer.gserviceaccount.com


# 4 - Create an API Key and make an authenticated API request via HTTP to the service using an API key.
# gcloud alpha services api-keys create --api-target=service=echo-api.endpoints.${PROJECT}.cloud.goog

#    You can use the curl command below to make a request that the service can parse if your containers have been configured correctly. Substitute the external IP address of the lab server and the API key into the code below and run it in Cloud Shell.

## Need to run this manually 
#export ENDPOINTS_KEY=`gcloud alpha services api-keys create --api-target=service=echo-api.endpoints.${PROJECT}.cloud.goog`


export EXTERNAL_IP=`gcloud compute instances describe ${SERVER} --zone=${ZONE} --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`

curl --request POST --header "content-type:application/json" --data '{"message":"hello world"}'  "http://${EXTERNAL_IP}:80/echo?key=${ENDPOINTS_KEY}"





