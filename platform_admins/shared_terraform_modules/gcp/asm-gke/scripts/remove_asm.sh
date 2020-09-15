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

#!/bin/bash
set -e

# Setup variables
IFS=',' read -r -a CLUSTER_NAMES <<< "${CLUSTERS_STRING}"
IFS=',' read -r -a CLUSTER_TYPES <<< "${REGIONAL_STRING}"
IFS=',' read -r -a CLUSTER_LOCS <<< "${LOCATIONS_STRING}"

for i in "${!CLUSTER_NAMES[@]}"; do

  # Set cmdline org for region/zone
  CMD_ARG=$([ "${CLUSTER_TYPES[$i]}" = true ] && echo "--region" || echo "--zone")
  gcloud container clusters get-credentials ${CLUSTER_NAME} ${CMD_ARG} ${CLUSTER_LOCATION} --project ${PROJECT_ID}

  kubectl --context=gke_"${PROJECT_ID}"_"${CLUSTER_LOCATION}"_"${CLUSTER_NAME}" delete ns istio-system
  kubectl --context=gke_"${PROJECT_ID}"_"${CLUSTER_LOCATION}"_"${CLUSTER_NAME}" delete ns asm-system

done
