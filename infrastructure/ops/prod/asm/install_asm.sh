#!/usr/bin/env bash

# Define vars
export ASM_DIR=istio-${ASM_VERSION}
export GCP_NETWORK=gcp-vpc
export AWS_NETWORK=aws-vpc

# Get ASM distro
wget https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
export PATH=istio-${ASM_VERSION}/bin:$PATH
ls -l istio-${ASM_VERSION}/samples/certs

# Get kubeconfig for all clusters
gsutil cp -r gs://$PROJECT_ID/kubeconfig/config config
export KUBECONFIG=./config
gcloud container clusters get-credentials ${GKE1} --zone ${GKE1_LOCATION} --project ${PROJECT_ID}
gcloud container clusters get-credentials ${GKE2} --zone ${GKE2_LOCATION} --project ${PROJECT_ID}

kubectl config rename-context eks_${EKS1} ${EKS1}
kubectl config rename-context eks_${EKS2} ${EKS2}
kubectl config rename-context gke_${PROJECT_ID}_${GKE1_LOCATION}_${GKE1} ${GKE1}
kubectl config rename-context gke_${PROJECT_ID}_${GKE2_LOCATION}_${GKE2} ${GKE2}

# Create istio-system namespace and certs
kubectl create namespace istio-system --dry-run -o yaml > istio-system.yaml
kubectl create secret generic cacerts -n istio-system \
--from-file=${ASM_DIR}/samples/certs/ca-cert.pem \
--from-file=${ASM_DIR}/samples/certs/ca-key.pem \
--from-file=${ASM_DIR}/samples/certs/root-cert.pem \
--from-file=${ASM_DIR}/samples/certs/cert-chain.pem --dry-run -o yaml > cacerts.yaml

kubectl --context ${GKE1} apply -f istio-system.yaml
kubectl --context ${GKE2} apply -f istio-system.yaml
kubectl --context ${EKS1} apply -f istio-system.yaml
kubectl --context ${EKS2} apply -f istio-system.yaml


kubectl --context ${GKE1} apply -f cacerts.yaml
kubectl --context ${GKE2} apply -f cacerts.yaml
kubectl --context ${EKS1} apply -f cacerts.yaml
kubectl --context ${EKS2} apply -f cacerts.yaml

# Create istiooperator resources for the EKS clusters
envsubst < eks1-cluster-asm.yaml_tmpl > eks1-cluster-asm.yaml
envsubst < eks2-cluster-asm.yaml_tmpl > eks2-cluster-asm.yaml

# Deploy the istiooperator resource on the EKS clusters
istioctl --context=${EKS1} manifest apply -f eks1-cluster-asm.yaml
istioctl --context=${EKS2} manifest apply -f eks2-cluster-asm.yaml

# Get the Istio ingress gateway IP addresses from both EKS clusters
export EKS1_ISTIOINGRESS_HOSTNAME=$(kubectl --context ${EKS1} -n istio-system get svc istio-ingressgateway -ojson | jq -r '.status.loadBalancer.ingress[].hostname')
export EKS1_ISTIOINGRESS_IP=$(nslookup ${EKS1_ISTIOINGRESS_HOSTNAME} | grep Address | awk 'END {print $2}')
echo -e "EKS1_ISTIOINGRESS_IP is ${EKS1_ISTIOINGRESS_IP}"
export EKS2_ISTIOINGRESS_HOSTNAME=$(kubectl --context ${EKS2} -n istio-system get svc istio-ingressgateway -ojson | jq -r '.status.loadBalancer.ingress[].hostname')
export EKS2_ISTIOINGRESS_IP=$(nslookup ${EKS2_ISTIOINGRESS_HOSTNAME} | grep Address | awk 'END {print $2}')
echo -e "EKS2_ISTIOINGRESS_IP is ${EKS2_ISTIOINGRESS_IP}"

# Create the istiooperator resource for the GKE clusters 
envsubst < gke1-cluster-asm.yaml_tmpl > gke1-cluster-asm.yaml
envsubst < gke2-cluster-asm.yaml_tmpl > gke2-cluster-asm.yaml

cat gke1-cluster-asm.yaml
cat gke2-cluster-asm.yaml

# Deploy the istiooperator resource on the GKE clusters
istioctl --context=${GKE1} manifest apply -f gke1-cluster-asm.yaml
istioctl --context=${GKE2} manifest apply -f gke2-cluster-asm.yaml

# Create the cluster aware gateways for cross cluster routing via istio-ingressgateways
kubectl --context=${EKS1} apply -f cluster-aware-gateway.yaml
kubectl --context=${EKS2} apply -f cluster-aware-gateway.yaml
kubectl --context=${GKE1} apply -f cluster-aware-gateway.yaml
kubectl --context=${GKE2} apply -f cluster-aware-gateway.yaml

# Create cross cluster service discovery secrets
istioctl x create-remote-secret --context=${GKE1} --name ${GKE1} > gke1-kubeconfig.yaml
istioctl x create-remote-secret --context=${GKE2} --name ${GKE2} > gke2-kubeconfig.yaml
istioctl x create-remote-secret --context=${EKS1} --name ${EKS1} > eks1-kubeconfig.yaml
istioctl x create-remote-secret --context=${EKS2} --name ${EKS2} > eks2-kubeconfig.yaml

kubectl --context=${GKE1} apply -f gke2-kubeconfig.yaml
kubectl --context=${GKE1} apply -f eks1-kubeconfig.yaml
kubectl --context=${GKE1} apply -f eks2-kubeconfig.yaml

kubectl --context=${GKE2} apply -f gke1-kubeconfig.yaml
kubectl --context=${GKE2} apply -f eks1-kubeconfig.yaml
kubectl --context=${GKE2} apply -f eks2-kubeconfig.yaml

kubectl --context=${EKS1} apply -f gke1-kubeconfig.yaml
kubectl --context=${EKS1} apply -f gke2-kubeconfig.yaml
kubectl --context=${EKS1} apply -f eks2-kubeconfig.yaml

kubectl --context=${EKS2} apply -f gke1-kubeconfig.yaml
kubectl --context=${EKS2} apply -f gke2-kubeconfig.yaml
kubectl --context=${EKS2} apply -f eks1-kubeconfig.yaml
