#!/usr/bin/env bash

# replace project variable
sed -i 's/PROJECT_ID/'${GOOGLE_PROJECT}'/g' \
  services-dashboard-prod.json

# get auth token
OAUTH_TOKEN=$(gcloud auth application-default print-access-token)

# create dashboard
curl -X POST -H "Authorization: Bearer $OAUTH_TOKEN" -H "Content-Type: application/json" \
  "https://monitoring.googleapis.com/v1/projects/${GOOGLE_PROJECT}/dashboards" \
  -d @services-dashboard-prod.json

# create direct link
echo "https://console.cloud.google.com/monitoring/dashboards/custom/servicesdash?cloudshell=false&project=${GOOGLE_PROJECT}"