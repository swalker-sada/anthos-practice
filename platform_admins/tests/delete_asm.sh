#!/usr/bin/env bash

# Define vars
export GKE1=gke1
export EKS1=eks1
export GKE2=gke2
export EKS2=eks2

# Delete istio-system namespace
kubectl --context ${GKE1} delete ns istio-system
kubectl --context ${GKE2} delete ns istio-system
kubectl --context ${EKS1} delete ns istio-system
kubectl --context ${EKS2} delete ns istio-system
