#!/usr/bin/env bash
#
echo "Copying EKS clusters' kubeconfig files to GCS..."
gsutil cp -r kubeconfig_eks1 gs://$PROJECT_ID/kubeconfig/kubeconfig_eks1
gsutil cp -r kubeconfig_eks2 gs://$PROJECT_ID/kubeconfig/kubeconfig_eks2
gsutil ls gs://$PROJECT_ID/kubeconfig
