#!/usr/bin/env bash

gcloud container clusters get-credentials gitlab --zone us-central1 --project ${PROJECT_ID}
echo ${GITLAB_HOSTNAME} > gitlab_creds.txt
kubectl get secret gitlab-gitlab-initial-root-password -o go-template='{{ .data.password }}' | base64 -d >> gitlab_creds.txt
gsutil cp -r gitlab_creds.txt gs://${PROJECT_ID}/gitlab/gitlab_creds.txt
