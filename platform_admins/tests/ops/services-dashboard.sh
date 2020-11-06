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

# Export a SCRIPT_DIR var and make all links relative to SCRIPT_DIR
export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

DASHBOARD_JSON_TMPL=$1

# replace project variable
sed -e 's/PROJECT_ID/'${GOOGLE_PROJECT}'/g' \
  ${DASHBOARD_JSON_TMPL} > ${SCRIPT_DIR}/services-dashboard-prod.json

DASHBOARD_JSON=${SCRIPT_DIR}/services-dashboard-prod.json

# get auth token
# OAUTH_TOKEN=$(gcloud auth application-default print-access-token)
OAUTH_TOKEN=$(gcloud auth print-access-token)

# create dashboard
curl -X POST -H "Authorization: Bearer $OAUTH_TOKEN" -H "Content-Type: application/json" \
  "https://monitoring.googleapis.com/v1/projects/${GOOGLE_PROJECT}/dashboards" \
  -d @${DASHBOARD_JSON}

# create direct link
echo "https://console.cloud.google.com/monitoring/dashboards/custom/servicesdash?cloudshell=false&project=${GOOGLE_PROJECT}"
