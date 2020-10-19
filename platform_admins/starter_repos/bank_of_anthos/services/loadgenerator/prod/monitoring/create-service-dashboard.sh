#!/usr/bin/env bash

DASHBOARD_JSON_TMPL=$1

# Export a SCRIPT_DIR var and make all links relative to SCRIPT_DIR
export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

# replace project variable
sed -e "s/PROJECT_ID/${PROJECT_ID}/g" -e "s/SERVICE/${DEPLOYMENT}/g" -e "s/ENV/prod/" ${DASHBOARD_JSON_TMPL} > ${SCRIPT_DIR}/${SVC}-service-dashboard.json

# get auth token
# OAUTH_TOKEN=$(gcloud auth application-default print-access-token)
OAUTH_TOKEN=$(gcloud auth print-access-token)

# create dashboard
curl -X POST -H "Authorization: Bearer $OAUTH_TOKEN" -H "Content-Type: application/json" \
  "https://monitoring.googleapis.com/v1/projects/${PROJECT_ID}/dashboards" \
  -d @${SCRIPT_DIR}/${SVC}-service-dashboard.json

# create direct link
echo "https://console.cloud.google.com/monitoring/dashboards/custom/servicesdash?cloudshell=false&project=${PROJECT_ID}"
