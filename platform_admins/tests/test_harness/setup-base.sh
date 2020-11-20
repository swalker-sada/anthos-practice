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

echo "${GCP_CICD_SA_KEY}" | base64 -d > ${CI_PROJECT_DIR}/cicd-sa-key.json
cat ${CI_PROJECT_DIR}/cicd-sa-key.json
gcloud auth activate-service-account cicd-sa@${PROJECT_ID}.iam.gserviceaccount.com --key-file=${CI_PROJECT_DIR}/cicd-sa-key.json --project=${PROJECT_ID}
gcloud config set project ${PROJECT_ID}
# Set terraform creds
export GOOGLE_PROJECT=${PROJECT_ID}
export GOOGLE_CREDENTIALS=$(cat ${CI_PROJECT_DIR}/cicd-sa-key.json)
export AWS_ACCESS_KEY_ID=$(gcloud secrets versions access 1 --secret=aws-access-key-id)
export AWS_SECRET_ACCESS_KEY=$(gcloud secrets versions access 1 --secret=aws-secret-access-key)