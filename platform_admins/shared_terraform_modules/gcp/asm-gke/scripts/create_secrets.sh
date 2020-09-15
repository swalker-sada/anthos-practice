#!/bin/bash

# Setup variables
IFS=',' read -r -a CLUSTER_NAMES <<< "${CLUSTERS_STRING}"
IFS=',' read -r -a CLUSTER_TYPES <<< "${REGIONAL_STRING}"
IFS=',' read -r -a CLUSTER_LOCS <<< "${LOCATIONS_STRING}"

ASM_VERSION="1.6.8-asm.9"

# Download ASM to get istioctl
curl -LO https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
rm -rf istio-${ASM_VERSION}-linux-amd64.tar.gz
export PATH=istio-${ASM_VERSION}/bin:$PATH

# check istioctl is in PATH
istioctl version --remote=false

for i in "${!CLUSTER_NAMES[@]}"; do
  # Set cmdline org for region/zone
  CMD_ARG=$([ "${CLUSTER_TYPES[$i]}" = true ] && echo "--region" || echo "--zone")

  # Create kubeconfig context
  gcloud container clusters get-credentials "${CLUSTER_NAMES[$i]}" $CMD_ARG "${CLUSTER_LOCS[$i]}" --project ${PROJECT_ID}

  # Create secret
  istioctl x create-remote-secret --name="${CLUSTER_NAMES[$i]}" > "${CLUSTER_NAMES[$i]}"-kubeconfig-secret.yaml
done

for i in "${!CLUSTER_NAMES[@]}";
do
  for j in "${!CLUSTER_NAMES[@]}";
  do
    if [[ "${CLUSTER_NAMES[$j]}" != "${CLUSTER_NAMES[$i]}" ]]; then
      kubectl apply -f "${CLUSTER_NAMES[$j]}"-kubeconfig-secret.yaml --context=gke_"${PROJECT_ID}"_"${CLUSTER_LOCS[$i]}"_"${CLUSTER_NAMES[$i]}"
    fi
  done
done


