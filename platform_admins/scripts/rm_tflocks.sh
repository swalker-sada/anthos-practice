#!/usr/bin/env bash

# Dev
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/dev/gcp/gke/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/dev/gcp/vpc/default.tflock

# Stage
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/stage/gcp/vpc/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/stage/gcp/gke/default.tflock

gsutil rm gs://${GOOGLE_PROJECT}/tfstate/stage/aws/vpc/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/stage/aws/eks/default.tflock

# Prod
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/vpc/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/gke/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/gitlab/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/hub_gsa/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/repos/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/ssh_key/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/asm/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/kcc/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/gcp/autoneg/default.tflock

gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/aws/vpc/default.tflock
gsutil rm gs://${GOOGLE_PROJECT}/tfstate/prod/aws/eks/default.tflock

