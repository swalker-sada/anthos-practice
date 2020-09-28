#!/usr/bin/env bash

DASHBOARD_JSON=$1

# replace project variable
sed -i 's/PROJECT_ID/'${GOOGLE_PROJECT}'/g' \
  ${DASHBOARD_JSON}

# get auth token
OAUTH_TOKEN=$(gcloud auth application-default print-access-token)

# create dashboard
curl -X POST -H "Authorization: Bearer $OAUTH_TOKEN" -H "Content-Type: application/json" \
  "https://monitoring.googleapis.com/v1/projects/${GOOGLE_PROJECT}/dashboards" \
  -d @${DASHBOARD_JSON}

# create direct link
echo "https://console.cloud.google.com/monitoring/dashboards/custom/servicesdash?cloudshell=false&project=${GOOGLE_PROJECT}"