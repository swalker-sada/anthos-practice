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


# Setup variables
IFS=',' read -r -a CLUSTER_NAMES <<< "${CLUSTERS_STRING}"
IFS=',' read -r -a CLUSTER_TYPES <<< "${REGIONAL_STRING}"
IFS=',' read -r -a CLUSTER_LOCS <<< "${LOCATIONS_STRING}"

# Download ASM to get istioctl
curl -LO https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
rm -rf istio-${ASM_VERSION}-linux-amd64.tar.gz
export PATH=istio-${ASM_VERSION}/bin:$PATH

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


