#!/bin/bash

MYSOURCEIP=
MYTCP=
MYUDP=



source variables

# Delete allow all rule
gcloud compute firewall-rules delete allow-foo

# Create Specific FW Rules
gcloud compute firewall-rules create allow-mytcp --direction=INGRESS --priority=1 --network=$VPC --action=ALLOW --rules=tcp:${MYTCP} --source-ranges=${MYSOURCEIP}/32 --target-tags=foo --enable-logging

gcloud compute firewall-rules create allow-myudp --direction=INGRESS --priority=1 --network=$VPC --action=ALLOW --rules=udp:${MYUDP} --source-ranges=${MYSOURCEIP}/32 --target-tags=foo --enable-logging
