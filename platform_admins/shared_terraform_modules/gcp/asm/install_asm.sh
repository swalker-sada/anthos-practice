#!/usr/bin/env bash

# Exit on any error
set -e

# Functions
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

# Get all EKS clusters' kubeconfig files
for IDX in ${!GKE_LIST[@]}
do
    gcloud container clusters get-credentials ${GKE_LIST[IDX]} --zone ${GKE_LOC[IDX]} --project ${PROJECT_ID}
done

DEFAULT_KUBECONFIG=${HOME}/.kube/config

for EKS in ${EKS_LIST[@]}
do
    gsutil cp -r gs://$PROJECT_ID/kubeconfig/kubeconfig_${EKS} .
    KUBECONFIG=${DEFAULT_KUBECONFIG}:kubeconfig_${EKS} kubectl config view --flatten --merge > /tmp/kubeconfig
    cp /tmp/kubeconfig ${DEFAULT_KUBECONFIG}
done

cat ${DEFAULT_KUBECONFIG}
export KUBECONFIG=${DEFAULT_KUBECONFIG}

# install asm and process secrets
processEKS() {
    EKS=${1}
    exec 1> >(sed "s/^/${EKS} SO: /")
    exec 2> >(sed "s/^/${EKS} SE: /" >&2)
    kubectl --context=eks_${EKS} get po --all-namespaces
    kubectl --context=eks_${EKS} apply -f istio-system.yaml
    kubectl --context=eks_${EKS} apply -f cacerts.yaml
    istioctl --context=eks_${EKS} install -f asm_${EKS}.yaml
    kubectl --context=eks_${EKS} apply -f cluster_aware_gateway.yaml
    istioctl x create-remote-secret --context=eks_${EKS} --name ${EKS} > kubeconfig_secret_${EKS}.yaml
}

processGKE() {
    IDX=${1}
    exec 1> >(sed "s/^/${IDX} SO: /")
    exec 2> >(sed "s/^/${IDX} SE: /" >&2)
    kubectl --context=eks_${EKS} get po --all-namespaces
    GKE_CTX=gke_${PROJECT_ID}_${GKE_LOC[IDX]}_${GKE_LIST[IDX]}
    kubectl --context=${GKE_CTX} apply -f istio-system.yaml
    kubectl --context=${GKE_CTX} apply -f cacerts.yaml
    istioctl --context=${GKE_CTX} install -f asm_${GKE_LIST[IDX]}.yaml
    kubectl --context=${GKE_CTX} apply -f cluster_aware_gateway.yaml
    istioctl x create-remote-secret --context=${GKE_CTX} --name ${GKE_LIST[IDX]} > kubeconfig_secret_${GKE_LIST[IDX]}.yaml
}

for EKS in ${EKS_LIST[@]}
do
    processEKS ${EKS} &
done

# Get GKE credentials
for IDX in ${!GKE_LIST[@]}
do
    processGKE ${IDX} &
done

# wait for all background jobs to finish
wait < <(jobs -p)

# Create cross-cluster service discovery
for EKS in ${EKS_LIST[@]}
do
    echo -e "##### Kube DNS configmap for ${EKS}... #####\n"
    COREDNS_IP=$(kubectl --context=eks_${EKS} get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})
    echo -e "${EKS_COREDNS_CONFIGMAP}" | sed -e s/COREDNS_IP/$COREDNS_IP/g >> eks_coredns_configmap_${EKS}.yaml
    kubectl --context=eks_${EKS} apply -f eks_coredns_configmap_${EKS}.yaml

    echo -e "##### Secrets for ${EKS}... #####\n"
    for EKS_SECRET in ${EKS_LIST[@]}
    do
        if [[ ! $EKS == $EKS_SECRET ]]; then
            echo -e "Creating kubeconfig secret in cluster ${EKS_SECRET} for ${EKS}..."
            kubectl --context=eks_${EKS_SECRET} apply -f kubeconfig_secret_${EKS}.yaml
        fi
    done
    for GKE_SECRET_IDX in ${!GKE_LIST[@]}
    do
        echo -e "Creating kubeconfig secret in cluster ${GKE_LIST[GKE_SECRET_IDX]} for ${EKS}..."
        GKE_CTX=gke_${PROJECT_ID}_${GKE_LOC[GKE_SECRET_IDX]}_${GKE_LIST[GKE_SECRET_IDX]}
        kubectl --context=${GKE_CTX} apply -f kubeconfig_secret_${EKS}.yaml
    done
done

for IDX in ${!GKE_LIST[@]}
do
    echo -e "##### KubeDNS configmap for ${GKE_LIST[IDX]}... #####\n"
    GKE_CTX=gke_${PROJECT_ID}_${GKE_LOC[IDX]}_${GKE_LIST[IDX]}
    COREDNS_IP=$(kubectl --context=${GKE_CTX} get svc -n istio-system istiocoredns -o jsonpath={.spec.clusterIP})
    echo -e "${GKE_KUBEDNS_CONFIGMAP}" | sed -e s/COREDNS_IP/$COREDNS_IP/g >> gke_kubedns_configmap_${GKE_CTX}.yaml
    kubectl --context=${GKE_CTX} apply -f gke_kubedns_configmap_${GKE_CTX}.yaml

    echo -e "##### Secrets for ${GKE_LIST[IDX]}... #####\n"
    for EKS_SECRET in ${EKS_LIST[@]}
    do
        echo -e "Creating kubeconfig secret in cluster ${EKS_SECRET} for ${GKE_LIST[IDX]}..."
        kubectl --context=eks_${EKS_SECRET} apply -f \
          kubeconfig_secret_${GKE_LIST[IDX]}.yaml
    done
    for GKE_SECRET_IDX in ${!GKE_LIST[@]}
    do
        if [[ ! ${GKE_LIST[IDX]} == ${GKE_LIST[GKE_SECRET_IDX]} ]]; then
            echo -e "Creating kubeconfig secret in cluster ${GKE_LIST[GKE_SECRET_IDX]} for ${GKE_LIST[IDX]}..."
            GKE_CTX=gke_${PROJECT_ID}_${GKE_LOC[GKE_SECRET_IDX]}_${GKE_LIST[GKE_SECRET_IDX]}
            kubectl --context=${GKE_CTX} apply -f \
              kubeconfig_secret_${GKE_LIST[IDX]}.yaml
        fi
    done
done
