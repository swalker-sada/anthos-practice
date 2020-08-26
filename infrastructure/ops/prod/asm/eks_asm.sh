#!/usr/bin/env bash

# Define cluster
export EKS_CLUSTER=$1

# Get the kubeconfig for eks cluster
gsutil cp -r gs://$PROJECT_ID/kubeconfig/kubeconfig_$EKS_CLUSTER ./kubeconfig_$EKS_CLUSTER

# Get ASM
curl -LO https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
export PATH=$PWD/istio-${ASM_VERSION}/bin:$PATH

# Create istio-system namespace and deploy ASM
kubectl --kubeconfig=./kubeconfig_$EKS_CLUSTER apply -f istio-system.yaml
istioctl --kubeconfig=./kubeconfig_$EKS_CLUSTER install --set profile=asm-multicloud
