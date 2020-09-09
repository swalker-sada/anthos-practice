#!/usr/bin/env bash

# Define vars
export GKE1=gke1
export EKS1=eks1
export GKE2=gke2
export EKS2=eks2

# Clear app-n namespaces
kubectl --context=${GKE1} delete ns app1
kubectl --context=${GKE1} delete ns app2
kubectl --context=${GKE1} delete ns app3
kubectl --context=${GKE1} delete ns app4

kubectl --context=${GKE2} delete ns app1
kubectl --context=${GKE2} delete ns app2
kubectl --context=${GKE2} delete ns app3
kubectl --context=${GKE2} delete ns app4

kubectl --context=${EKS1} delete ns app1
kubectl --context=${EKS1} delete ns app2
kubectl --context=${EKS1} delete ns app3
kubectl --context=${EKS1} delete ns app4

kubectl --context=${EKS2} delete ns app1
kubectl --context=${EKS2} delete ns app2
kubectl --context=${EKS2} delete ns app3
kubectl --context=${EKS2} delete ns app4

# Clear sample
kubectl --context=${GKE1} delete ns sample
kubectl --context=${GKE2} delete ns sample
kubectl --context=${EKS1} delete ns sample
kubectl --context=${EKS2} delete ns sample

