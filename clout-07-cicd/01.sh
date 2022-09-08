#!/bin/bash

source variables.inc

# Commit the updated yaml files as a change to the application in your local clone of the pop-kustomize git repository and then push those updates to the Cloud Source Repository.

git config --global user.email "foo@goo.com"
git config --global user.name "Your Name"

cd $REPO 

git add cloudbuild.yaml
git add clouddeploy.yaml

git commit -m "First files using Cloud Source Repositories" *.yaml 

git push origin master
