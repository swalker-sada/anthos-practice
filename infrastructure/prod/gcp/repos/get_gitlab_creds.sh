#!/usr/bin/env bash

gcloud container clusters get-credentials gitlab --zone us-central1 --project ${PROJECT_ID}
GITLAB_CREDS=$(kubectl get secret gitlab-gitlab-initial-root-password -o go-template='{{ .data.password }}' | base64 -d)
echo -n "{\"gitlab_creds\":\"${GITLAB_CREDS}\"}"
