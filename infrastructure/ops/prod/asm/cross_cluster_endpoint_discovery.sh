#!/usr/bin/env bash

# Download ASM to get istioctl
curl -LO https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
export PATH=$PWD/istio-${ASM_VERSION}/bin:${PATH}

# check istioctl is in PATH
# istioctl version --remote=false
$PWD/istio-${ASM_VERSION}/bin/istioctl version --remote=false

# Create kubeconfig file
gcloud container clusters get-credentials ${GKE1} --zone ${GKE1_LOCATION} --project ${PROJECT_ID}
gcloud container clusters get-credentials ${GKE2} --zone ${GKE2_LOCATION} --project ${PROJECT_ID}

# Export cluster contexts
export GKE1_CTX=gke_${PROJECT_ID}_${GKE1_LOCATION}_${GKE1}
export GKE2_CTX=gke_${PROJECT_ID}_${GKE2_LOCATION}_${GKE2}

# Create cross cluster endpoint discovery secrets
istioctl x create-remote-secret --context=${GKE1_CTX} --name=${GKE1} > gke1-kubeconfig-secret.yaml
istioctl x create-remote-secret --context=${GKE2_CTX} --name=${GKE2} > gke2-kubeconfig-secret.yaml

# Configure secrets on all clusters
## Cluster 1
kubectl apply -f gke2-kubeconfig-secret.yaml --context=${GKE1_CTX}
## Cluster 2
kubectl apply -f gke1-kubeconfig-secret.yaml --context=${GKE2_CTX}

