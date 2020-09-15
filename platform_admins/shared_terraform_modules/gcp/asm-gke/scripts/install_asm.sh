#!/bin/bash
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

# set -e

# Functions
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

# Setup variables
IFS=',' read -r -a CLUSTER_NAMES <<< "${CLUSTERS_STRING}"
IFS=',' read -r -a CLUSTER_TYPES <<< "${REGIONAL_STRING}"
IFS=',' read -r -a CLUSTER_LOCS <<< "${LOCATIONS_STRING}"
ASM_VERSION="1.6.8-asm.9"
ENVIRON_PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')

# Download ASM to get istioctl
curl -LO https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
rm -rf istio-${ASM_VERSION}-linux-amd64.tar.gz
export PATH=istio-${ASM_VERSION}/bin:$PATH

# Enable APIs
gcloud services enable \
    --project=${PROJECT_ID} \
    container.googleapis.com \
    compute.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com \
    cloudtrace.googleapis.com \
    meshca.googleapis.com \
    meshtelemetry.googleapis.com \
    meshconfig.googleapis.com \
    iamcredentials.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    cloudresourcemanager.googleapis.com

for i in "${!CLUSTER_NAMES[@]}";
do
  # Set up envioronment
  gcloud config set project "${PROJECT_ID}"

  # Set credentials and permissions
  # Initialize project for ASM
  curl --request POST \
  --header "Authorization: Bearer $(gcloud auth print-access-token)" \
  --data '' \
  "https://meshconfig.googleapis.com/v1alpha1/projects/${PROJECT_ID}:initialize"

  # Get GKE credentials
  CMD_ARG=$([ "${CLUSTER_TYPES[$i]}" = true ] && echo "--region" || echo "--zone")
  gcloud container clusters get-credentials "${CLUSTER_NAMES[$i]}" $CMD_ARG "${CLUSTER_LOCS[$i]}" --project ${PROJECT_ID}
  GKE_CTX=gke_${PROJECT_ID}_${CLUSTER_LOCS[$i]}_${CLUSTER_NAMES[$i]}

  # Download ASM package for istio-operator and other resource configuration files
  kpt pkg get https://github.com/GoogleCloudPlatform/anthos-service-mesh-packages.git/asm@"${ASM_VERSION}" "${CLUSTER_NAMES[$i]}"

  # Prepare config files
  kpt cfg set "${CLUSTER_NAMES[$i]}"/ gcloud.core.project "${PROJECT_ID}"
  kpt cfg set "${CLUSTER_NAMES[$i]}"/ gcloud.container.cluster "${CLUSTER_NAMES[$i]}"
  kpt cfg set "${CLUSTER_NAMES[$i]}"/ gcloud.compute.location "${CLUSTER_LOCS[$i]}"
  kpt cfg set "${CLUSTER_NAMES[$i]}"/ gcloud.project.environProjectNumber ${ENVIRON_PROJECT_NUMBER}
  kpt cfg set "${CLUSTER_NAMES[$i]}"/ anthos.servicemesh.profile asm-gcp
  kpt cfg list-setters "${CLUSTER_NAMES[$i]}"/

  # Gatekeeper causes issues if not ready
  # Check if ACM is installed and wait for it to be ready
  IS_ACM_INSTALLED=$(kubectl --context ${GKE_CTX} get ns | grep gatekeeper-system)
  if [[ ${IS_ACM_INSTALLED} ]]; then
    is_deployment_ready ${GKE_CTX} gatekeeper-system gatekeeper-controller-manager
  fi

  # Install ASM
  istioctl install -f "${CLUSTER_NAMES[$i]}"/cluster/istio-operator.yaml

  # Install canonical-service controllers to enable ASM UI
  kubectl --context=${GKE_CTX} apply -f "${CLUSTER_NAMES[$i]}"/canonical-service/controller.yaml

done
