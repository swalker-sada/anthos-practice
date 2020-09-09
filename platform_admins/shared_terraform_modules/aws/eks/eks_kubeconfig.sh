#!/usr/bin/env bash
#
echo "Copying EKS clusters' kubeconfig files to GCS..."
gsutil cp -r kubeconfig_$EKS gs://$PROJECT_ID/kubeconfig/kubeconfig_$EKS

# Create KSA and token
kubectl --kubeconfig=kubeconfig_$EKS apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gke-hub-ksa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gke-hub-ksa-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: gke-hub-ksa
  namespace: default
EOF

SECRET_NAME=$(kubectl --kubeconfig=kubeconfig_$EKS get serviceaccount gke-hub-ksa -o jsonpath='{$.secrets[0].name}')
kubectl --kubeconfig=kubeconfig_$EKS get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 -d > $EKS-ksa-token.txt

# Upload the ksa-token to GCS bucket
gsutil cp -r $EKS-ksa-token.txt gs://$PROJECT_ID/kubeconfig/$EKS-ksa-token.txt

# Get Anthos Hub GSA credentials file
gsutil cp -r gs://${PROJECT_ID}/hubgsa/gke_hub_sa_key.json .

# Register the EKS cluster
gcloud container hub memberships register ${EKS} --project=${PROJECT_ID} --context=eks_${EKS} --kubeconfig=kubeconfig_${EKS} --service-account-key-file=gke_hub_sa_key.json

# Add labels to the registered cluster
gcloud container hub memberships update ${EKS} --update-labels environ=${ENV},infra=aws
