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


DASHBOARD=$1

# replace project variable
sed 's/PROJECT_ID/'${GOOGLE_PROJECT}'/g' \
  ${DASHBOARD}.json_tmpl \
  > ${DASHBOARD}.json

# get auth token
# OAUTH_TOKEN=$(gcloud auth application-default print-access-token)
OAUTH_TOKEN=$(gcloud auth print-access-token)

# create dashboard
curl -X POST -H "Authorization: Bearer $OAUTH_TOKEN" -H "Content-Type: application/json" \
  "https://monitoring.googleapis.com/v1/projects/${GOOGLE_PROJECT}/dashboards" \
  -d @${DASHBOARD}.json

# create direct link
echo "https://console.cloud.google.com/monitoring/dashboards/custom/servicesdash?cloudshell=false&project=${GOOGLE_PROJECT}"
