#!/usr/bin/env bash

# Upload Gitlab name and password to GCS bucket
gcloud container clusters get-credentials gitlab --zone us-central1 --project ${PROJECT_ID}

# Add label to cluster
gcloud container clusters update gitlab --region us-central1 --update-labels infra=gcp

echo ${GITLAB_HOSTNAME} > gitlab_creds.txt
kubectl get secret gitlab-gitlab-initial-root-password -o go-template='{{ .data.password }}' | base64 -d >> gitlab_creds.txt
gsutil cp -r gitlab_creds.txt gs://${PROJECT_ID}/gitlab/gitlab_creds.txt

# Create a personal access token with the root password
export GITLAB_CREDS=$(kubectl get secret gitlab-gitlab-initial-root-password -o go-template='{{ .data.password }}' | base64 -d)
export WEBSERVICE_POD=$(kubectl get pods -l=app=webservice -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $WEBSERVICE_POD -c webservice -- /bin/bash -c "
    cd /srv/gitlab;
    bin/rails r \"
    token_digest = Gitlab::CryptoHelper.sha256 \\\"${GITLAB_CREDS}\\\";
    token=PersonalAccessToken.create!(name: \\\"Anthos Platform Installer\\\", scopes: [:api], user: User.where(id: 1).first, token_digest: token_digest);
    token.save!
    \";
    " > /dev/null 2>&1 || true

