export PROJECT_ID=""
export REGION=""

export REPO="pop-kustomize"
export SA=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")@cloudbuild.gserviceaccount.com

