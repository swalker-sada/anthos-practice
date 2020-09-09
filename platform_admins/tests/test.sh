#!/usr/bin/env bash

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
export GKE1=gke-r1a-prod-1
export EKS1=eks-r1ab-prod-1
export GKE2=gke-r1b-prod-2
export EKS2=eks-r1ab-prod-2

# Verify Pods are ready
is_deployment_ready ${GKE1} app1 httpbin
is_deployment_ready ${GKE1} app1 sleep
is_deployment_ready ${GKE2} app2 httpbin
is_deployment_ready ${GKE2} app2 sleep
is_deployment_ready ${EKS1} app3 httpbin
is_deployment_ready ${EKS1} app3 sleep
is_deployment_ready ${EKS2} app4 httpbin
is_deployment_ready ${EKS2} app4 sleep

# Test connectivity
echo -e "\n"
echo -e "$GKE1 to $GKE2"
kubectl --context ${GKE1} exec -it -n app1 $(kubectl get pod --context ${GKE1} -n app1 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app2:8000/get

echo -e "\n"
echo -e "$GKE1 to $EKS1"
kubectl --context ${GKE1} exec -it -n app1 $(kubectl get pod --context ${GKE1} -n app1 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app3:8000/get

echo -e "\n"
echo -e "$GKE1 to $EKS2"
kubectl --context ${GKE1} exec -it -n app1 $(kubectl get pod --context ${GKE1} -n app1 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app4:8000/get

echo -e "\n"
echo -e "$GKE2 to $GKE1"
kubectl --context ${GKE2} exec -it -n app2 $(kubectl get pod --context ${GKE2} -n app2 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app1:8000/get

echo -e "\n"
echo -e "$GKE2 to $EKS1"
kubectl --context ${GKE2} exec -it -n app2 $(kubectl get pod --context ${GKE2} -n app2 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app3:8000/get

echo -e "\n"
echo -e "$GKE2 to $EKS2"
kubectl --context ${GKE2} exec -it -n app2 $(kubectl get pod --context ${GKE2} -n app2 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app4:8000/get

echo -e "\n"
echo -e "$EKS1 to $GKE1"
kubectl --context ${EKS1} exec -it -n app3 $(kubectl get pod --context ${EKS1} -n app3 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app1:8000/get

echo -e "\n"
echo -e "$EKS1 to $GKE2"
kubectl --context ${EKS1} exec -it -n app3 $(kubectl get pod --context ${EKS1} -n app3 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app2:8000/get

echo -e "\n"
echo -e "$EKS1 to $EKS2"
kubectl --context ${EKS1} exec -it -n app3 $(kubectl get pod --context ${EKS1} -n app3 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app4:8000/get

echo -e "\n"
echo -e "$EKS2 to $GKE1"
kubectl --context ${EKS2} exec -it -n app4 $(kubectl get pod --context ${EKS2} -n app4 | grep sleep | awk '{print $1}') -c sleep -- curl http://httpbin.app1:8000/get

echo -e "\n"
echo -e "$EKS2 to $GKE2"
kubectl --context ${EKS2} exec -it -n app4 $(kubectl get pod --context ${EKS2} -n app4 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app2:8000/get

echo -e "\n"
echo -e "$EKS2 to $EKS1"
kubectl --context ${EKS2} exec -it -n app4 $(kubectl get pod --context ${EKS2} -n app4 | grep sleep | awk '{print $1}') -c sleep -- curl httpbin.app3:8000/get
