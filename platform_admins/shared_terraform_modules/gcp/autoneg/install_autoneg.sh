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


# Exit on any error
set -e

# Create bash arrays from lists
IFS=',' read -r -a GKE_LIST <<< "${GKE_LIST_STRING}"
IFS=',' read -r -a GKE_LOC <<< "${GKE_LOC_STRING}"

# Clone autoneg repo
git clone https://github.com/GoogleCloudPlatform/gke-autoneg-controller.git

# Get all GKE clusters' kubeconfig files
for IDX in ${!GKE_LIST[@]}
do
    gcloud container clusters get-credentials ${GKE_LIST[IDX]} --zone ${GKE_LOC[IDX]} --project ${PROJECT_ID}
    kubectl apply -f gke-autoneg-controller/deploy/autoneg.yaml
    # Annotate the service account for workload identity
    kubectl annotate sa -n autoneg-system default \
      iam.gke.io/gcp-service-account=${AUTONEG_SA}@${PROJECT_ID}.iam.gserviceaccount.com --overwrite
done
