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
export GKE1=${GKE_PROD_1}
export EKS1=${EKS_PROD_1}
export GKE2=${GKE_PROD_2}
export EKS2=${EKS_PROD_2}

# Export a SCRIPT_DIR var and make all links relative to SCRIPT_DIR
export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

kubectl --context=${GKE1} apply -f ${SCRIPT_DIR}/ob/gke1/ob-namespace.yaml
kubectl --context=${GKE2} apply -f ${SCRIPT_DIR}/ob/gke2/ob-namespace.yaml
kubectl --context=${EKS1} apply -f ${SCRIPT_DIR}/ob/eks1/ob-namespace.yaml
kubectl --context=${EKS2} apply -f ${SCRIPT_DIR}/ob/eks2/ob-namespace.yaml

kubectl --context=${GKE1} -n ob apply -f ${SCRIPT_DIR}/ob/gke1
kubectl --context=${GKE2} -n ob apply -f ${SCRIPT_DIR}/ob/gke2
kubectl --context=${EKS1} -n ob apply -f ${SCRIPT_DIR}/ob/eks1
kubectl --context=${EKS2} -n ob apply -f ${SCRIPT_DIR}/ob/eks2

is_deployment_ready ${GKE1} ob emailservice
is_deployment_ready ${GKE1} ob checkoutservice
is_deployment_ready ${GKE1} ob frontend

is_deployment_ready ${GKE2} ob paymentservice
is_deployment_ready ${GKE2} ob productcatalogservice
is_deployment_ready ${GKE2} ob currencyservice

is_deployment_ready ${EKS1} ob shippingservice
is_deployment_ready ${EKS1} ob adservice
is_deployment_ready ${EKS1} ob loadgenerator

is_deployment_ready ${EKS2} ob cartservice
is_deployment_ready ${EKS2} ob recommendationservice

kubectl --context=${GKE1} -n istio-system get svc
