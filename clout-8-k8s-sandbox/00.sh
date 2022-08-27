#!/bin/bash

# Docs: https://cloud.google.com/kubernetes-engine/docs/how-to/sandbox-pods#gcloud_1

# Get variables
source variables.inc

# Define Cluster
#CLUSTER=`kubectl config view --minify -o jsonpath='{.clusters[].name}'`

CLUSTER=`gcloud container clusters list | grep NAME | awk -F " " '{print $2 }'`
ZONE=`gcloud container clusters list | grep LOCATION | awk -F " " '{print $2 }'`

gcloud container clusters get-credentials ${CLUSTER} --zone=${ZONE}

# Update deployment files with variables
sed -e "s/regular-app/${DEPLOYMENTV1}/g" sandbox-metadata-test.yaml > tmp1 && mv tmp1 v1.yaml
sed -e "s/regular-app/${DEPLOYMENTV2}/g" sandbox-metadata-test-v2.yaml > tmp2 && mv tmp2 v2.yaml
sed -e "s/regular-app/${DEPLOYMENTV3}/g" sandbox-metadata-test-v3.yaml > tmp3 && mv tmp3 v3.yaml


# 1 - Deploy the first version of the sample application, using the deployment manifest provided in the appendix below to the default pool.
#     Make sure the deployment and the container names are called $DEPLOYMENTV1 .
#     This application should be deployed to the default node pool.
#     This pod in this deployment should be able access cluster metadata and will have the ability to use raw network sockets for example with the ping command. You can find detailed commands that you can use to test these capabilities in the appendix.

kubectl create  -f v1.yaml


# 2 - Create a new GKE single node node pool.

#     Call the new node pool $NODEPOOL .
#     Enable workload isolation using GKE Sandbox for this node pool.
#     The machine type for this cluster should always be $MACHINETYPE .

gcloud container node-pools create ${NODEPOOL} \
  --cluster=${CLUSTER} \
  --machine-type=${MACHINETYPE} \
  --image-type=cos_containerd \
  --sandbox type=gvisor \
  --zone=${ZONE}

# 3 - Deploy a second version of the sample application to the new sandbox-enabled node pool but do not enable sandbox mode for this second deployment. This second deployment emulates a standard workload deployed to a sandbox capable node.
#     Make sure the deployment and the container names are called $DEPLOYMENTV2 .
#     You can add node affinity and toleration configuration settings to the deployment manifest to deploy the pod to the correct node.
#     This pod in this second deployment should not be able to access cluster metadata because it is running on a node that is configured to support sandboxed workloads. However, as it can still use raw network sockets, the ping command can still be used to test connectivity.

kubectl create -f v2.yaml


# 4 - Deploy the third version of the sample application to the new sandbox-enabled node pool and enable sandbox mode.
#     Make sure the deployment and the container names are called $DEPLOYMENTV3 .
#     You will need to configure the correct runtimeClassName for the container.
#     The pod in this final deployment should not be able to access cluster metadata because it is running on a node that is configured to support sandboxed workloads. As it is now also running in full sandbox mode it cannot use raw network sockets and the ping command will be blocked if you try to use it.

kubectl create -f v3.yaml




