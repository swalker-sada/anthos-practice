#!/usr/bin/env bash

# Functions
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

get_svc_ingress_ip() { 
    export ingress=$(kubectl --context $1 -n istio-system get svc $2 -o json | jq -r '.status.loadBalancer.ingress[].hostname')
export ingress_ip=$(nslookup ${ingress} | grep Address | awk 'END {print $2}')
        while [[ ${ingress_ip} == *"127."*  ]]
            do 
                sleep 5
                echo -e "Waiting for service $2 in cluster $1 to get an IP address..."
                export ingress=$(kubectl --context $1 -n istio-system get svc $2 -o json | jq -r '.status.loadBalancer.ingress[].hostname')
                export ingress_ip=$(nslookup ${ingress} | grep Address | awk 'END {print $2}')
            done
        echo -e "$2 in cluster $1 has an ip address of ${ingress_ip}."
}

# Create bash arrays from lists
IFS=',' read -r -a GKE_LIST <<< "${GKE_LIST_STRING}"
IFS=',' read -r -a GKE_LOC <<< "${GKE_LOC_STRING}"
IFS=',' read -r -a EKS_LIST <<< "${EKS_LIST_STRING}"
IFS=',' read -r -a EKS_INGRESS_IPS <<< "${EKS_INGRESS_IPS_STRING}"
IFS=',' read -r -a EKS_EIP_LIST <<< "${EKS_EIP_LIST_STRING}"
ASM_DIR=istio-${ASM_VERSION}

# Get ASM
wget https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
tar xzf istio-${ASM_VERSION}-linux-amd64.tar.gz
rm -rf istio-${ASM_VERSION}-linux-amd64.tar.gz
export PATH=istio-${ASM_VERSION}/bin:$PATH
ls -l istio-${ASM_VERSION}/samples/certs

# Create istio-system namespace and certs
kubectl create namespace istio-system --dry-run -o yaml > istio-system.yaml
kubectl create secret generic cacerts -n istio-system \
--from-file=${ASM_DIR}/samples/certs/ca-cert.pem \
--from-file=${ASM_DIR}/samples/certs/ca-key.pem \
--from-file=${ASM_DIR}/samples/certs/root-cert.pem \
--from-file=${ASM_DIR}/samples/certs/cert-chain.pem --dry-run -o yaml > cacerts.yaml

echo -e "${CLUSTER_AWARE_GATEWAY}" > cluster_aware_gateway.yaml
cat cluster_aware_gateway.yaml

# Get Kubeconfigs, check if ACM Policy Controller is deployed and wait for ACM to be Ready and deploy ASM
# Get all EKS clusters' kubeconfig files
for EKS in ${EKS_LIST[@]}
do
    gsutil cp -r gs://$PROJECT_ID/kubeconfig/kubeconfig_$EKS .
    export KUBECONFIG=kubeconfig_$EKS
    IS_ACM_INSTALLED=$(kubectl --kubeconfig=kubeconfig_$EKS get ns | grep gatekeeper-system)
    if [[ ${IS_ACM_INSTALLED} ]]; then
        is_deployment_ready eks_${EKS} gatekeeper-system gatekeeper-controller-manager
    fi
    kubectl --context=eks_${EKS} apply -f istio-system.yaml
    kubectl --context=eks_${EKS} apply -f cacerts.yaml
    istioctl --context=eks_${EKS} manifest apply -f asm_${EKS}.yaml
    kubectl --context=eks_${EKS} apply -f cluster_aware_gateway.yaml
    istioctl x create-remote-secret --context=eks_${EKS} --name ${EKS} > kubeconfig_secret_${EKS}.yaml
done

touch kubeconfig_gke
export KUBECONFIG=kubeconfig_gke
# Get GKE credentials
for IDX in ${!GKE_LIST[@]}
do
    gcloud container clusters get-credentials ${GKE_LIST[IDX]} --zone ${GKE_LOC[IDX]} --project ${PROJECT_ID}
    GKE_CTX=gke_${PROJECT_ID}_${GKE_LOC[IDX]}_${GKE_LIST[IDX]}
    IS_ACM_INSTALLED=$(kubectl --context=$GKE_CTX get ns | grep gatekeeper-system)
    if [[ ${IS_ACM_INSTALLED} ]]; then
        is_deployment_ready ${GKE_CTX} gatekeeper-system gatekeeper-controller-manager
    fi
    kubectl --context=${GKE_CTX} apply -f istio-system.yaml
    kubectl --context=${GKE_CTX} apply -f cacerts.yaml
    istioctl --context=${GKE_CTX} manifest apply -f asm_${GKE_LIST[IDX]}.yaml
    kubectl --context=${GKE_CTX} apply -f cluster_aware_gateway.yaml
    istioctl x create-remote-secret --context=${GKE_CTX} --name ${GKE_LIST[IDX]} > kubeconfig_secret_${GKE_LIST[IDX]}.yaml
done

# Create cross-cluster service discovery
for EKS in ${EKS_LIST[@]}
do
    echo -e "##### Secrets for ${EKS}... #####\n"
    for EKS_SECRET in ${EKS_LIST[@]}
    do
        if [[ ! $EKS == $EKS_SECRET ]]; then
            echo -e "Creating kubeconfig secret in cluster ${EKS_SECRET} for ${EKS}..."
            kubectl --kubeconfig=kubeconfig_${EKS_SECRET} --context=eks_${EKS_SECRET} apply -f kubeconfig_secret_${EKS}.yaml
        fi
    done
    for GKE_SECRET_IDX in ${!GKE_LIST[@]}
    do
        echo -e "Creating kubeconfig secret in cluster ${GKE_LIST[GKE_SECRET_IDX]} for ${EKS}..."
        GKE_CTX=gke_${PROJECT_ID}_${GKE_LOC[GKE_SECRET_IDX]}_${GKE_LIST[GKE_SECRET_IDX]}
        kubectl --kubeconfig=kubeconfig_gke --context=${GKE_CTX} apply -f kubeconfig_secret_${EKS}.yaml
    done
done

for IDX in ${!GKE_LIST[@]}
do
    echo -e "##### Secrets for ${GKE_LIST[IDX]}... #####\n"
    for EKS_SECRET in ${EKS_LIST[@]}
    do
        echo -e "Creating kubeconfig secret in cluster ${EKS_SECRET} for ${GKE_LIST[IDX]}..."
        kubectl --kubeconfig=kubeconfig_${EKS_SECRET} --context=eks_${EKS_SECRET} apply -f \
        kubeconfig_secret_${GKE_LIST[IDX]}.yaml
    done
    for GKE_SECRET_IDX in ${!GKE_LIST[@]}
    do
        if [[ ! ${GKE_LIST[IDX]} == ${GKE_LIST[GKE_SECRET_IDX]} ]]; then
            echo -e "Creating kubeconfig secret in cluster ${GKE_LIST[GKE_SECRET_IDX]} for ${GKE_LIST[IDX]}..."
            GKE_CTX=gke_${PROJECT_ID}_${GKE_LOC[GKE_SECRET_IDX]}_${GKE_LIST[GKE_SECRET_IDX]}
            kubectl --kubeconfig=kubeconfig_gke --context=${GKE_CTX} apply -f \
            kubeconfig_secret_${GKE_LIST[IDX]}.yaml
        fi
    done
done
