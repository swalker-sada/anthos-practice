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


# Define vars
export GKE1=gke1
export EKS1=eks1
export GKE2=gke2
export EKS2=eks2

# Clear app-n namespaces
kubectl --context=${GKE1} delete ns app1
kubectl --context=${GKE1} delete ns app2
kubectl --context=${GKE1} delete ns app3
kubectl --context=${GKE1} delete ns app4

kubectl --context=${GKE2} delete ns app1
kubectl --context=${GKE2} delete ns app2
kubectl --context=${GKE2} delete ns app3
kubectl --context=${GKE2} delete ns app4

kubectl --context=${EKS1} delete ns app1
kubectl --context=${EKS1} delete ns app2
kubectl --context=${EKS1} delete ns app3
kubectl --context=${EKS1} delete ns app4

kubectl --context=${EKS2} delete ns app1
kubectl --context=${EKS2} delete ns app2
kubectl --context=${EKS2} delete ns app3
kubectl --context=${EKS2} delete ns app4

# Clear sample
kubectl --context=${GKE1} delete ns sample
kubectl --context=${GKE2} delete ns sample
kubectl --context=${EKS1} delete ns sample
kubectl --context=${EKS2} delete ns sample

