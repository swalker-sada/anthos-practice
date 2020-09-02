#!/usr/bin/env bash

# Get kubeconfig file
export EKS_CLUSTER=$1
gsutil cp -r gs://$PROJECT_ID/kubeconfig/kubeconfig_$EKS_CLUSTER kubeconfig_$EKS_CLUSTER

# Get ConfigManagement Operator YAML
gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml

# Get the SSH private key file
gsutil cp gs://$PROJECT_ID/ssh-key/csr-key csr-key
cat csr-key

# Prep ACM yaml
#export REPO_URL=ssh://$GCLOUD_USER@source.developers.google.com:2022/p/$PROJECT_ID/r/$REPO_NAME
sed -e s/CLUSTER_NAME/${EKS_CLUSTER}/g -e s~REPO_URL~${REPO_URL}~g ./configmanagement.yaml_tmpl > configmanagement.yaml 
cat configmanagement.yaml

# Deploy to cluster
kubectl --kubeconfig=kubeconfig_$EKS_CLUSTER apply -f config-management-operator.yaml
# Create git-creds secret
kubectl --kubeconfig=kubeconfig_$EKS_CLUSTER create secret generic git-creds \
--namespace=config-management-system \
--from-file=ssh=csr-key
# Deploy configmanagement
kubectl --kubeconfig=kubeconfig_$EKS_CLUSTER apply -f configmanagement.yaml

