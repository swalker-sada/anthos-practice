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

