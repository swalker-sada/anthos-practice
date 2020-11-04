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


# Define is_deployment_ready func
is_deployment_ready() {
kubectl --context $1 -n $2 get deploy $3 &> /dev/null
    export exit_code=$?
    while [ ! " ${exit_code} " -eq 0 ]
        do
            sleep 5
            echo -e "Waiting for deployment $3 in cluster $1 to be created..."
            kubectl --context $1 -n $2 get deploy $3 &> /dev/null
            export exit_code=$?
        done
    echo -e "Deployment $3 in cluster $1 created."

    # Once deployment is created, check for deployment status.availableReplicas is greater than 0
    export availableReplicas=$(kubectl --context $1 -n $2 get deploy $3 -o json | jq -r '.status.availableReplicas')
    while [[ " ${availableReplicas} " == " null " ]]
        do
            sleep 5
            echo -e "Waiting for deployment $3 in cluster $1 to become ready..."
            export availableReplicas=$(kubectl --context $1 -n $2 get deploy $3 -o json | jq -r '.status.availableReplicas')
        done

    echo -e "$3 in cluster $1 is ready with replicas ${availableReplicas}."
    return ${availableReplicas}
}

# Define vars
export GKE1=gke1
export EKS1=eks1
export GKE2=gke2
export EKS2=eks2

# Clone repo
mkdir -p ~/asm-test && cd ~/asm-test
if [ -d "$HOME/asm-test/istio-${ASM_VERSION}" ]; then
  echo "Repo already present."
else
  curl -LO https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
  tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
  rm -rf istio-${ASM_VERSION}-linux-amd64.tar.gz
fi

# Create namespace
cat > namespace-sample.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: sample
  labels:
    istio-injection: enabled
EOF

kubectl --context=${GKE1} apply -f namespace-sample.yaml
kubectl --context=${GKE2} apply -f namespace-sample.yaml
kubectl --context=${EKS1} apply -f namespace-sample.yaml
kubectl --context=${EKS2} apply -f namespace-sample.yaml

# Deploy helloworld and sleep
kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l app=helloworld -n sample --context=${GKE1}
kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l version=v1 -n sample --context=${GKE1}

kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l app=helloworld -n sample --context=${GKE2}
kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l version=v2 -n sample --context=${GKE2}

kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l app=helloworld -n sample --context=${EKS1}
kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l version=v1 -n sample --context=${EKS1}

kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l app=helloworld -n sample --context=${EKS2}
kubectl create -f $HOME/asm-test/istio-${ASM_VERSION}/samples/helloworld/helloworld.yaml -l version=v2 -n sample --context=${EKS2}

kubectl apply -f $HOME/asm-test/istio-${ASM_VERSION}/samples/sleep/sleep.yaml -n sample --context=${GKE1}
kubectl apply -f $HOME/asm-test/istio-${ASM_VERSION}/samples/sleep/sleep.yaml -n sample --context=${GKE2}
kubectl apply -f $HOME/asm-test/istio-${ASM_VERSION}/samples/sleep/sleep.yaml -n sample --context=${EKS1}
kubectl apply -f $HOME/asm-test/istio-${ASM_VERSION}/samples/sleep/sleep.yaml -n sample --context=${EKS2}

is_deployment_ready ${GKE1} sample helloworld-v1
is_deployment_ready ${GKE1} sample sleep
is_deployment_ready ${GKE2} sample helloworld-v2
is_deployment_ready ${GKE2} sample sleep
is_deployment_ready ${EKS1} sample helloworld-v1
is_deployment_ready ${EKS1} sample sleep
is_deployment_ready ${EKS2} sample helloworld-v2
is_deployment_ready ${EKS2} sample sleep

# Get Pods
kubectl --context=${GKE1} -n sample get pods | grep helloworld
kubectl --context=${GKE2} -n sample get pods | grep helloworld
kubectl --context=${EKS1} -n sample get pods | grep helloworld
kubectl --context=${EKS2} -n sample get pods | grep helloworld
