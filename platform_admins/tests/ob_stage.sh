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


export CYAN='\033[1;36m'
export GREEN='\033[1;32m'
export NC='\033[0m' # No Color
function echo_cyan() { echo -e "${CYAN}$@${NC}"; }
function echo_green() { echo -e "${GREEN}$@${NC}"; }

# Define vars
export GKE1=${GKE_STAGE_1}
export EKS1=${EKS_STAGE_1}
export STAGE_NS=ob-stage

# Export a SCRIPT_DIR var and make all links relative to SCRIPT_DIR
export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

kubectl --context=${GKE1} apply -f ${SCRIPT_DIR}/ob/stage/gke1/ob-namespace.yaml
kubectl --context=${EKS1} apply -f ${SCRIPT_DIR}/ob/stage/eks1/ob-namespace.yaml

kubectl --context=${GKE1} -n ${STAGE_NS} apply -f ${SCRIPT_DIR}/ob/stage/gke1
kubectl --context=${EKS1} -n ${STAGE_NS} apply -f ${SCRIPT_DIR}/ob/stage/eks1

is_deployment_ready ${GKE1} ${STAGE_NS} emailservice
is_deployment_ready ${GKE1} ${STAGE_NS} checkoutservice
is_deployment_ready ${GKE1} ${STAGE_NS} frontend

is_deployment_ready ${GKE1} ${STAGE_NS} paymentservice
is_deployment_ready ${GKE1} ${STAGE_NS} productcatalogservice
is_deployment_ready ${GKE1} ${STAGE_NS} currencyservice

is_deployment_ready ${EKS1} ${STAGE_NS} shippingservice
is_deployment_ready ${EKS1} ${STAGE_NS} adservice
is_deployment_ready ${EKS1} ${STAGE_NS} loadgenerator

is_deployment_ready ${EKS1} ${STAGE_NS} cartservice
is_deployment_ready ${EKS1} ${STAGE_NS} recommendationservice

echo -e "\n"
echo_cyan "*** Access Online Boutique app in namespace ${STAGE_NS} by navigating to the following address: ***\n"
kubectl --context=${GKE1} -n istio-system get svc istio-ingressgateway -o jsonpath={.status.loadBalancer.ingress[].ip}
echo -e "\n"
