#!/bin/bash

source variables.inc


# 4 - Trigger the workflow with an authenticated POST request to the Cloud Run service.
#     You can use the curl command below to achieve this. Substitute the Cloud Run endpoint URL from step 2 into the environment variable and run the curl command.


#  export CLOUD_RUN_ENDPOINT=[Cloud Run Endpoint URL]


curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
    -X POST $CLOUD_RUN_ENDPOINT

