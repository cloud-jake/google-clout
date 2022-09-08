#!/bin/bash

source variables

#############################################################
# 1 - Configure VPC Flow Logs on the test-vpc VPC network.

gcloud compute networks subnets update $SUBNET1 --enable-flow-logs --region=$REGION
gcloud compute networks subnets update $SUBNET2 --enable-flow-logs --region=$REGION



# 2 - Redirect VPC Flow Logs to a BigQuery dataset named flow_logs using a sink and identify the blocked traffic between the source VM ( test-vm ) and destination VM ( service-vm ) in the test-vpc VPC network.

bq --location=$REGION --project_id=${PROJECT} mk --dataset --default_table_expiration 0 $BQ_DATASET

gcloud logging sinks create my-sink bigquery.googleapis.com/projects/${PROJECT}/datasets/${BQ_DATASET} --log-filter="resource.type=gce_subnetwork"


#Add Firewall rule(s) to allow the blocked traffic to flow.

gcloud compute instances add-tags $DESTINATIONVM --zone=$DESTINATIONVM_ZONE --tags=foo


##gcloud compute instances add-tags instance-1 --zone=us-central1-a --tags=foo
##gcloud compute --project=qwiklabs-gcp-02-fab026652c56 firewall-rules create foo2 --direction=INGRESS --priority=100 --network=default --action=ALLOW --rules=tcp:0-65535,udp:0-65535 --source-ranges=0.0.0.0/0 --target-tags=foo --enable-logging

gcloud compute firewall-rules create allow-foo --direction=INGRESS --priority=100 --network=$VPC --action=ALLOW --rules=tcp:0-65535,udp:0-65535 --source-ranges=0.0.0.0/0 --target-tags=foo --enable-logging

#Resolve the traffic flows by implementing precise VPC Firewall rule(s):




#The Firewall Rules must specifically identify individual source and destination VMs by IP-address.

#gcloud compute --project=qwiklabs-gcp-03-d9d09beb151e firewall-rules create allow-http-ssh --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80,tcp:22 --source-ranges=0.0.0.0/0 --target-tags=http-server --enable-logging


#The Firewall Rules must specifically identify the ports and protocols to be allowed. Wild card rules ('Allow All') will not score full points.




