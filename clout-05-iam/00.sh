#!/bin/bash

NEWBUCKET=
FROMBUCKET=
WEBSERVER=web-server


#######################################
# 00 - Get project info
PROJID=`gcloud config list --format 'value(core.project)' 2>/dev/null`
gcloud config set project $PROJID
SA=web-admin-sa@${PROJID}.iam.gserviceaccount.com

gcloud auth print-access-token --impersonate-service-account=$SA

gcloud config set auth/impersonate_service_account $SA

echo $SA

# 1 - Create a new storage bucket called $NEWBUCKET
gsutil mb  gs://${NEWBUCKET}

# 2 - Copy the startup script deploy-web-server.sh from the storage bucket
gsutil cp gs://${FROMBUCKET}/deploy-web-server.sh gs://${NEWBUCKET}/

# 3 - Add a new firewall rule to the default VCP network that allows Instances containing the tag http-server to respond to web traffic from all addresses.
gcloud compute firewall-rules create allow-http --impersonate-service-account=$SA --allow=tcp:80,tcp:443 --direction=INGRESS --target-tags=http-server

# 4 - Deploy a new virtual machine called WEB_SERVER that is configured to use deploy-web-server.sh as its startup script.
# web-admin-sa@qwiklabs-gcp-01-69e2833e5475.iam.gserviceaccount.com
gcloud compute instances create $WEBSERVER --impersonate-service-account=$SA \
    --machine-type=n1-standard-1 --zone=us-central1-a \
    --tags=http-server \
   --metadata=startup-script-url=https://storage.googleapis.com/${NEWBUCKET}/deploy-web-server.sh




