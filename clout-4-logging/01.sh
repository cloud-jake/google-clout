#!/bin/bash

# Define variables

LOGGING=LogMetric
CRASHING=CrashMetric
CrashAlert=

# resource.type "k8s_container" and resource.labels.pod_name including "logging-" or "crashing-"

gcloud logging metrics create $LOGGING --description="Logging App" --log-filter='resource.type="k8s_container" AND resource.labels.pod_name=~"logging-"'
gcloud logging metrics create $CRASHING --description="Crashing App" --log-filter='resource.type="k8s_container" AND resource.labels.pod_name=~"crashing-"'
