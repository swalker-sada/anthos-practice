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
export GKE1=${GKE_PROD_1}
export EKS1=${EKS_PROD_1}
export GKE2=${GKE_PROD_2}
export EKS2=${EKS_PROD_2}

# Create namespaces
mkdir -p ~/asm-test && cd ~/asm-test
cat > 03_namespace-app1.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app1
  labels:
    istio-injection: enabled
EOF

cat > 03_namespace-app2.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app2
  labels:
    istio-injection: enabled
EOF

cat > 03_namespace-app3.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app3
  labels:
    istio-injection: enabled
EOF

cat > 03_namespace-app4.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: app4
  labels:
    istio-injection: enabled
EOF

# Download httpbin and sleep YAMLs
wget -O 04_app-httpbin.yaml https://gitlab.com/ameer00/istioplayground/raw/master/policy1/httpbin-ns.yaml
wget -O 04_app-sleep.yaml https://gitlab.com/ameer00/istioplayground/raw/master/policy1/sleep-ns.yaml
wget -O 04_app-helloworld.yaml https://raw.githubusercontent.com/istio/istio/release-1.3/samples/helloworld/helloworld.yaml
wget -O 05_app-httpbin-svc.yaml https://gitlab.com/ameer00/istioplayground/raw/master/policy1/httpbin-service-ns.yaml

# Create manifests
sed s/"namespace: default"/"namespace: app1"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app1.yaml
sed s/"namespace: default"/"namespace: app2"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app2.yaml
sed s/"namespace: default"/"namespace: app3"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app3.yaml
sed s/"namespace: default"/"namespace: app4"/g 04_app-httpbin.yaml | tee 04_app-httpbin-in-app4.yaml

sed s/"namespace: default"/"namespace: app1"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app1.yaml
sed s/"namespace: default"/"namespace: app2"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app2.yaml
sed s/"namespace: default"/"namespace: app3"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app3.yaml
sed s/"namespace: default"/"namespace: app4"/g 04_app-sleep.yaml | tee 04_app-sleep-in-app4.yaml

sed s/"namespace: default"/"namespace: app1"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app1.yaml
sed s/"namespace: default"/"namespace: app2"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app2.yaml
sed s/"namespace: default"/"namespace: app3"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app3.yaml
sed s/"namespace: default"/"namespace: app4"/g 05_app-httpbin-svc.yaml | tee 05_app-httpbin-svc-in-app4.yaml

# Deploy namespaces
kubectl --context=${GKE1} apply -f 03_namespace-app1.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app1.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app1.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app1.yaml

kubectl --context=${GKE1} apply -f 03_namespace-app2.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app2.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app2.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app2.yaml

kubectl --context=${GKE1} apply -f 03_namespace-app3.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app3.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app3.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app3.yaml

kubectl --context=${GKE1} apply -f 03_namespace-app4.yaml
kubectl --context=${GKE2} apply -f 03_namespace-app4.yaml
kubectl --context=${EKS1} apply -f 03_namespace-app4.yaml
kubectl --context=${EKS2} apply -f 03_namespace-app4.yaml

# Deploy httpbin services in all clusters
kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app1.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app1.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app1.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app1.yaml

kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app2.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app2.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app2.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app2.yaml

kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app3.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app3.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app3.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app3.yaml

kubectl --context=${GKE1} apply -f 05_app-httpbin-svc-in-app4.yaml
kubectl --context=${GKE2} apply -f 05_app-httpbin-svc-in-app4.yaml
kubectl --context=${EKS1} apply -f 05_app-httpbin-svc-in-app4.yaml
kubectl --context=${EKS2} apply -f 05_app-httpbin-svc-in-app4.yaml

# Deploy httpbin deployments
kubectl --context=${GKE1} apply -f 04_app-httpbin-in-app1.yaml
kubectl --context=${GKE2} apply -f 04_app-httpbin-in-app2.yaml
kubectl --context=${EKS1} apply -f 04_app-httpbin-in-app3.yaml
kubectl --context=${EKS2} apply -f 04_app-httpbin-in-app4.yaml

# Deploy sleep
kubectl --context=${GKE1} apply -f 04_app-sleep-in-app1.yaml
kubectl --context=${GKE2} apply -f 04_app-sleep-in-app2.yaml
kubectl --context=${EKS1} apply -f 04_app-sleep-in-app3.yaml
kubectl --context=${EKS2} apply -f 04_app-sleep-in-app4.yaml

