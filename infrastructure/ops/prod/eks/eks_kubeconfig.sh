#!/usr/bin/env bash
#
echo "Copying EKS clusters' kubeconfig files to GCS..."
KUBECONFIG=kubeconfig_eks1:kubeconfig_eks2 kubectl config view --merge --flatten > config
gsutil cp -r kubeconfig_eks1 gs://$PROJECT_ID/kubeconfig/kubeconfig_eks1
gsutil cp -r kubeconfig_eks2 gs://$PROJECT_ID/kubeconfig/kubeconfig_eks2
gsutil cp -r config gs://$PROJECT_ID/kubeconfig/config

# Create KSA and token
kubectl --kubeconfig=kubeconfig_eks1 apply -f ksa.yaml
SECRET_NAME=$(kubectl --kubeconfig=kubeconfig_eks1 get serviceaccount gke-hub-ksa -o jsonpath='{$.secrets[0].name}')
kubectl --kubeconfig=kubeconfig_eks1 get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 -d > eks1-ksa-token.txt

kubectl --kubeconfig=kubeconfig_eks2 apply -f ksa.yaml
SECRET_NAME=$(kubectl --kubeconfig=kubeconfig_eks2 get serviceaccount gke-hub-ksa -o jsonpath='{$.secrets[0].name}')
kubectl --kubeconfig=kubeconfig_eks2 get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 -d > eks2-ksa-token.txt

# Upload the ksa-token to GCS bucket
gsutil cp -r eks1-ksa-token.txt gs://$PROJECT_ID/kubeconfig/eks1-ksa-token.txt
gsutil cp -r eks2-ksa-token.txt gs://$PROJECT_ID/kubeconfig/eks2-ksa-token.txt
