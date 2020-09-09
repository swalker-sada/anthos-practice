#!/usr/bin/env bash

# Get kubeconfig file
gsutil cp -r gs://$PROJECT_ID/kubeconfig/kubeconfig_$EKS_CLUSTER kubeconfig_$EKS_CLUSTER

# Get ConfigManagement Operator YAML
gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml

# Get the SSH private key file
gsutil cp gs://$PROJECT_ID/ssh-keys/ssh-key-private ssh-key-private

# Prep ACM yaml
#sed -e s/CLUSTER_NAME/${EKS_CLUSTER}/g -e s~REPO_URL~${REPO_URL}~g ./configmanagement.yaml_tmpl > configmanagement.yaml 
#cat configmanagement.yaml
cat <<EOF > configmanagement.yaml
apiVersion: configmanagement.gke.io/v1
kind: ConfigManagement
metadata:
  name: config-management
spec:
  # clusterName is required and must be unique among all managed clusters
  clusterName: $EKS_CLUSTER
  policyController:
    enabled: true
    templateLibraryInstalled: true
  git:
    syncRepo: $REPO_URL
    secretType: ssh
EOF

# Deploy to cluster
kubectl --kubeconfig=kubeconfig_$EKS_CLUSTER apply -f config-management-operator.yaml
# Create git-creds secret
kubectl --kubeconfig=kubeconfig_$EKS_CLUSTER create secret generic git-creds \
--namespace=config-management-system \
--from-file=ssh=ssh-key-private

# Deploy configmanagement
kubectl --kubeconfig=kubeconfig_$EKS_CLUSTER apply -f configmanagement.yaml
