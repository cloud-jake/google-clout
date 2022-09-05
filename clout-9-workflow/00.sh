#!/bin/bash
#    
#    To complete this challenge, you must create a Workflows workflow that is triggered by a Python application which you must deploy to Cloud Run. 
#    You must then trigger the workflow by invoking your Cloud Run application using an HTTP POST.
#

source variables.inc

# WORKFLOW_NAME
# REGION
# Endpoint?
# SERVICE_NAME

gcloud services enable workflows.googleapis.com


# 1 - Create a workflow named workflow_name in the lab region region using the default sample YAML code.
#     The default workflow fetches the current day of the week from a sample API and then passes that to the Wikipedia Search API to fetch a list of Wikipedia articles related to the current day of the week.

git clone https://github.com/GoogleCloudPlatform/workflows-samples.git

gcloud workflows deploy ${WORKFLOW_NAME} --source=workflows-samples/src/quickstart.workflows.yaml --location=${REGION}


# 2 - Deploy the Cloud Run application archive provided for you in the Cloud Storage bucket named gs://cloud-training/clout/trigger-workflow/lab-cloudrun-workflows-main.zip to Cloud Run.
#     This Cloud Run function calls a workflow and displays the outputs.
#     There are three variables in the code that you must set to make the Cloud Run Service trigger your workflow.
#     You must deploy the application to Cloud Run in the lab region region.

gsutil cp gs://cloud-training/clout/trigger-workflow/lab-cloudrun-workflows-main.zip .
unzip lab-cloudrun-workflows-main.zip

    # TODO(developer): Uncomment these lines and replace with your values.
    # project = 'my-project-id'
    # location = 'us-central1'
    # workflow = 'myFirstWorkflow'
    
    # lab-cloudrun-workflows-main/app/main.py

sed -e "s/my-project-id/${PROJECT}/g" lab-cloudrun-workflows-main/app/main.py > tmp1 && mv tmp1 lab-cloudrun-workflows-main/app/main.py
sed -e "s/us-central1/${REGION}/g" lab-cloudrun-workflows-main/app/main.py > tmp2 && mv tmp2 lab-cloudrun-workflows-main/app/main.py
sed -e "s/myFirstWorkflow/${WORKFLOW_NAME}/g" lab-cloudrun-workflows-main/app/main.py > tmp3 && mv tmp3 lab-cloudrun-workflows-main/app/main.py

sed -e "s/# project/project/g" lab-cloudrun-workflows-main/app/main.py > tmp11 && mv tmp11 lab-cloudrun-workflows-main/app/main.py
sed -e "s/# location/location/g" lab-cloudrun-workflows-main/app/main.py > tmp22 && mv tmp22 lab-cloudrun-workflows-main/app/main.py
sed -e "s/# workflow/workflow/g" lab-cloudrun-workflows-main/app/main.py > tmp33 && mv tmp33 lab-cloudrun-workflows-main/app/main.py

cd lab-cloudrun-workflows-main
gcloud builds submit --tag gcr.io/${PROJECT}/${SERVICE_NAME} 

gcloud run deploy ${SERVICE_NAME} --region=${REGION} \
--image gcr.io/${PROJECT}/${SERVICE_NAME} \
--platform managed \
--no-allow-unauthenticated

cd ../

# 3 - Create a new service account named service_account and grant the Workflows Invoker and Cloud Run Invoker roles to it. You must then associate this service account with the Cloud Run application you deployed in step 2 above.

gcloud iam service-accounts create $SERVICE_ACCOUNT \
--description="Cloud Run Service Account" \
--display-name="CRSA"

gcloud projects add-iam-policy-binding $PROJECT \
--member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com" \
--role="roles/run.invoker"

gcloud projects add-iam-policy-binding $PROJECT \
--member="serviceAccount:${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com" \
--role="roles/workflows.invoker"


gcloud run services update ${SERVICE_NAME} --service-account ${SERVICE_ACCOUNT}@${PROJECT}.iam.gserviceaccount.com --region=${REGION}



# 4 - Trigger the workflow with an authenticated POST request to the Cloud Run service.
#     You can use the curl command below to achieve this. Substitute the Cloud Run endpoint URL from step 2 into the environment variable and run the curl command.


#  export CLOUD_RUN_ENDPOINT=[Cloud Run Endpoint URL]


curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
    -X POST $CLOUD_RUN_ENDPOINT
