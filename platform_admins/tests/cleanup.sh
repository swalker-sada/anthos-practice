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

export DEV_NS=ob-dev
export STAGE_NS=ob-stage
export PROD_NS=ob-prod

for CLUSTER in ${GKE_DEV_1} ${GKE_DEV_2}
do
  kubectl delete ns ${DEV_NS} --context ${CLUSTER}
done

for CLUSTER in ${GKE_STAGE_1} ${EKS_STAGE_1}
do
  kubectl delete ns ${STAGE_NS} --context ${CLUSTER}
done

for CLUSTER in ${GKE_PROD_1} ${GKE_PROD_2} ${EKS_PROD_1} ${EKS_PROD_2}
do
  kubectl delete ns ${PROD_NS} --context ${CLUSTER}
done
