#!/bin/bash

source variables.inc

# Initializes APIS, sets up the Google Cloud Deploy pipeline
# bail if PROJECT_ID is not set
if [[ -z "${PROJECT_ID}" ]]; then
  echo "The value of PROJECT_ID is not set. Be sure to run export PROJECT_ID=YOUR-PROJECT first"
  return
fi

# sets the current project for gcloud
gcloud config set project $PROJECT_ID

# Enables various APIs you'll need
gcloud services enable container.googleapis.com cloudbuild.googleapis.com \
artifactregistry.googleapis.com clouddeploy.googleapis.com \
cloudresourcemanager.googleapis.com sourcerepo.googleapis.com


# 1A - Create a build trigger that excutes the build defined in the cloudbuild.yaml file that is in the root of the pop-kustomize repository in Cloud Source Repository for the project.

#gcloud beta builds triggers create cloud-source-repositories --repo=${REPO} --branch-pattern='.*' --build-config=cloudbuild.yaml --service-account=${SA}

gcloud beta builds triggers create cloud-source-repositories --repo=$REPO --branch-pattern="^master$" --build-config=cloudbuild.yaml  --require-approval


#gcloud beta builds triggers create cloud-source-repositories \
#    --repo=$REPO \
#    --branch-pattern=BRANCH_PATTERN \ # or --tag-pattern=TAG_PATTERN
#    --build-config=BUILD_CONFIG_FILE \
#    --service-account=SERVICE_ACCOUNT \
#    --require-approval

# 1B - Add the Cloud Deploy Releaser (roles/clouddeploy.releaser) and Service Account User (roles/iam.serviceAccountUser)  roles to the Cloud Build service account.
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SA \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$SA \
    --role="roles/clouddeploy.releaser"

# 2 - Clone
# clone repo locall
gcloud source repos clone $REPO

cd $REPO

# 2A - Edit and modify both the cloudbuild.yamland clouddeploy.yaml files as follows:
#      Change all instances of the placeholder text project-id-here in both files to the lab Project ID: Project_ID
#      Change all instances of the placeholder text region-here in both files to the lab region : Default Region

sed -e "s/project-id-here/${PROJECT_ID}/g" clouddeploy.yaml > tmp && mv tmp clouddeploy.yaml
sed -e "s/project-id-here/${PROJECT_ID}/g" cloudbuild.yaml > tmp && mv tmp cloudbuild.yaml

sed -e "s/region-here/${REGION}/g" clouddeploy.yaml > tmp && mv tmp clouddeploy.yaml
sed -e "s/region-here/${REGION}/g" cloudbuild.yaml > tmp && mv tmp cloudbuild.yaml

# To address logging error for SA, append this to the options: section of cloudbuild.yaml:
IS_LOGGING=`grep logging cloudbuild.yaml`

if [[ -z "${IS_LOGGING}" ]]; then
  echo "  logging: CLOUD_LOGGING_ONLY" >> cloudbuild.yaml
fi


# 2B - Create the Cloud Deploy pipeline for the lab using the updated clouddeploy.yaml
gcloud deploy apply --file clouddeploy.yaml --region=$REGION --project=$PROJECT_ID

echo "Steps 1 & 2 Complete....."

# 3A - Create a docker format repository in the Artifact Registry named pop-stats to store container images for this pipeline.
# creates the Artifact Registry repo
gcloud artifacts repositories create pop-stats --location=$REGION --repository-format=docker

# 3B - Commit the updated yaml files as a change to the application in your local clone of the pop-kustomize git repository and then push those updates to the Cloud Source Repository.

echo "Commit the updated yaml files as a change to the application in your local clone of the pop-kustomize git repository and then push those updates to the Cloud Source Repository."
