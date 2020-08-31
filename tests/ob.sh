#!/usr/bin/env bash

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

# Clone repo with OB manifests
mkdir -p ~/asm-test && cd ~/asm-test
if [ -d "$HOME/asm-test/istio-multicluster-gke" ]; then
  echo "Repo already present."
else
  git clone https://github.com/GoogleCloudPlatform/istio-multicluster-gke.git ~/asm-test/istio-multicluster-gke
fi

# Create namespace
cat > namespace-ob.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: ob
  labels:
    istio-injection: enabled
EOF

kubectl --context=${GKE1} apply -f namespace-ob.yaml
kubectl --context=${EKS1} apply -f namespace-ob.yaml

# Deploy ob
kubectl --context ${GKE1} --namespace ob apply -f ${HOME}/asm-test/istio-multicluster-gke/anthos-multicloud/online-boutique/control
kubectl --context ${EKS1} --namespace ob apply -f ${HOME}/asm-test/istio-multicluster-gke/anthos-multicloud/online-boutique/onprem

# Wait until all Pods are ready
is_deployment_ready ${GKE1} ob frontend
is_deployment_ready ${GKE1} ob checkoutservice
is_deployment_ready ${GKE1} ob adservice
is_deployment_ready ${GKE1} ob currencyservice
is_deployment_ready ${GKE1} ob emailservice
is_deployment_ready ${GKE1} ob paymentservice
is_deployment_ready ${GKE1} ob productcatalogservice
is_deployment_ready ${GKE1} ob shippingservice
is_deployment_ready ${EKS1} ob cartservice
is_deployment_ready ${EKS1} ob recommendationservice
is_deployment_ready ${EKS1} ob loadgenerator

# Get GKE1 istio ingress IP
export INGRESS_IP=$(kubectl --context ${GKE1} --namespace istio-system get svc istio-ingressgateway -o jsonpath={.status.loadBalancer.ingress..ip})
echo -e "\n"
echo -e "Navigate to the following IP address: \n${INGRESS_IP}\n"
