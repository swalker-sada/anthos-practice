#!/usr/bin/env bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Define is_deployment_ready func
is_deployment_ready() {
kubectl --context $1 -n $2 get deploy $3 &> /dev/null
    export exit_code=$?
    while [ ! " ${exit_code} " -eq 0 ]
        do
            sleep 5
            echo -e "Waiting for deployment $3 in cluster $1 to be created..."
            kubectl --context $1 -n $2 get deploy $3 &> /dev/null
            export exit_code=$?
        done
    echo -e "Deployment $3 in cluster $1 created."

    # Once deployment is created, check for deployment status.availableReplicas is greater than 0
    export availableReplicas=$(kubectl --context $1 -n $2 get deploy $3 -o json | jq -r '.status.availableReplicas')
    while [[ " ${availableReplicas} " == " null " ]]
        do
            sleep 5
            echo -e "Waiting for deployment $3 in cluster $1 to become ready..."
            export availableReplicas=$(kubectl --context $1 -n $2 get deploy $3 -o json | jq -r '.status.availableReplicas')
        done

    echo -e "$3 in cluster $1 is ready with replicas ${availableReplicas}."
    return ${availableReplicas}
}

export CYAN='\033[1;36m'
export GREEN='\033[1;32m'
export NC='\033[0m' # No Color
function echo_cyan() { echo -e "${CYAN}$@${NC}"; }
function echo_green() { echo -e "${GREEN}$@${NC}"; }

# Define vars
export GKE1=${GKE_PROD_1}
export EKS1=${EKS_PROD_1}
export GKE2=${GKE_PROD_2}
export EKS2=${EKS_PROD_2}
export GSA=cloud-ops@${GOOGLE_PROJECT}.iam.gserviceaccount.com
export KSA=default
export PROD_NS=ob-prod

# Export a SCRIPT_DIR var and make all links relative to SCRIPT_DIR
export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

## Stage 1: Preparation
# Retrieve & replace asm rev label 
ASM_REV_LABEL=$(kubectl get deploy -n istio-system -l app=istiod -o jsonpath={.items[*].metadata.labels.'istio\.io\/rev'})

sed -e "s/ASM_REV_LABEL/${ASM_REV_LABEL}/" ${SCRIPT_DIR}/ob/prod/gke1/ob-namespace-patch.yaml_tmpl > ${SCRIPT_DIR}/ob/prod/gke1/ob-namespace-patch.yaml
sed -e "s/ASM_REV_LABEL/${ASM_REV_LABEL}/" ${SCRIPT_DIR}/ob/prod/gke2/ob-namespace-patch.yaml_tmpl > ${SCRIPT_DIR}/ob/prod/gke2/ob-namespace-patch.yaml
sed -e "s/ASM_REV_LABEL/${ASM_REV_LABEL}/" ${SCRIPT_DIR}/ob/prod/eks1/ob-namespace-patch.yaml_tmpl > ${SCRIPT_DIR}/ob/prod/eks1/ob-namespace-patch.yaml
sed -e "s/ASM_REV_LABEL/${ASM_REV_LABEL}/" ${SCRIPT_DIR}/ob/prod/eks2/ob-namespace-patch.yaml_tmpl > ${SCRIPT_DIR}/ob/prod/eks2/ob-namespace-patch.yaml

# Create Cloud-Ops GSA secret YAML
kubectl create secret generic cloud-ops-sa --from-file=application_default_credentials.json=${WORKDIR}/cloudopsgsa/cloud_ops_sa_key.json --dry-run=client -oyaml > ${SCRIPT_DIR}/ob/prod/eks1/cloud-ops-sa-secret.yaml
kubectl create secret generic cloud-ops-sa --from-file=application_default_credentials.json=${WORKDIR}/cloudopsgsa/cloud_ops_sa_key.json --dry-run=client -oyaml > ${SCRIPT_DIR}/ob/prod/eks2/cloud-ops-sa-secret.yaml

# Workload Identity for Cloud-Ops GSA/KSA Mapping
sed -e "s/GSA/${GSA}/" ${SCRIPT_DIR}/ob/prod/gke1/default-ksa-patch.yaml_tmpl > ${SCRIPT_DIR}/ob/prod/gke1/default-ksa-patch.yaml
sed -e "s/GSA/${GSA}/" ${SCRIPT_DIR}/ob/prod/gke2/default-ksa-patch.yaml_tmpl > ${SCRIPT_DIR}/ob/prod/gke2/default-ksa-patch.yaml

gcloud iam service-accounts add-iam-policy-binding $GSA \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:${GOOGLE_PROJECT}.svc.id.goog[${PROD_NS}/$KSA]"

## Stage 2: Deploy
echo -e "\n"
echo_cyan "*** Deploying Online Boutique app to ${GKE1} cluster... ***\n"
kubectl --context=${GKE1} apply -k ${SCRIPT_DIR}/ob/prod/gke1
echo -e "\n"
echo_cyan "*** Deploying Online Boutique app to ${GKE2} cluster... ***\n"
kubectl --context=${GKE2} apply -k ${SCRIPT_DIR}/ob/prod/gke2
echo -e "\n"
echo_cyan "*** Deploying Online Boutique app to ${EKS1} cluster... ***\n"
kubectl --context=${EKS1} apply -k ${SCRIPT_DIR}/ob/prod/eks1
echo -e "\n"
echo_cyan "*** Deploying Online Boutique app to ${EKS2} cluster... ***\n"
kubectl --context=${EKS2} apply -k ${SCRIPT_DIR}/ob/prod/eks2

## Stage 3: Validation
echo -e "\n"
echo_cyan "*** Verifying all Deployments are Ready in all clusters... ***\n"
is_deployment_ready ${GKE1} ${PROD_NS} emailservice
is_deployment_ready ${GKE1} ${PROD_NS} checkoutservice
is_deployment_ready ${GKE1} ${PROD_NS} frontend

is_deployment_ready ${GKE2} ${PROD_NS} paymentservice
is_deployment_ready ${GKE2} ${PROD_NS} productcatalogservice
is_deployment_ready ${GKE2} ${PROD_NS} currencyservice

is_deployment_ready ${EKS1} ${PROD_NS} shippingservice
is_deployment_ready ${EKS1} ${PROD_NS} adservice
is_deployment_ready ${EKS1} ${PROD_NS} loadgenerator

is_deployment_ready ${EKS2} ${PROD_NS} cartservice
is_deployment_ready ${EKS2} ${PROD_NS} recommendationservice

echo -e "\n"
echo_cyan "*** Access Online Boutique app in namespace ${PROD_NS} by navigating to the following address: ***\n"
kubectl --context=${GKE1} -n istio-system get svc istio-ingressgateway -o jsonpath={.status.loadBalancer.ingress[].ip}
echo -e "\n"
