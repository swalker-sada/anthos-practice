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


# Download KCC
gsutil cp gs://cnrm/latest/release-bundle.tar.gz release-bundle.tar.gz
tar zxvf release-bundle.tar.gz

# Set PROJECT_ID
sed -i.bak s/'${PROJECT_ID?}'/${PROJECT_ID}/ install-bundle-workload-identity/0-cnrm-system.yaml

# Get konfig for GKE PROD 1 cluster
gcloud container clusters get-credentials ${GKE_NAME} --zone ${GKE_LOC} --project ${PROJECT_ID}

# Apply the manifest to GKE PROD 1 cluster
kubectl apply -f install-bundle-workload-identity/

# Wait for pods to be Ready
kubectl wait -n cnrm-system --for=condition=Ready pod --all

# Create and annotate a namespace for GCP project resources
# Set the overwrite flag to make it idempotent
kubectl annotate namespace cnrm-system cnrm.cloud.google.com/project-id=${PROJECT_ID} --overwrite

# Enable workload identity for the cnrm-system namespace and cnrm-controller-manager KSA
gcloud iam service-accounts add-iam-policy-binding cnrm-system@"${PROJECT_ID}".iam.gserviceaccount.com \
        --project ${PROJECT_ID} \
        --role roles/iam.workloadIdentityUser \
        --member "serviceAccount:${PROJECT_ID}.svc.id.goog[cnrm-system/cnrm-controller-manager]"
