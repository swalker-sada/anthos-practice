#!/usr/bin/env bash

# Create arrays from inputed strings
IFS=',' read -r -a GKE_LIST <<< "${GKE_LIST_STRING}"
IFS=',' read -r -a GKE_LOC <<< "${GKE_LOC_STRING}"
IFS=',' read -r -a EKS_LIST <<< "${EKS_LIST_STRING}"
IFS=',' read -r -a EKS_INGRESS_IPS <<< "${EKS_INGRESS_IPS_STRING}"
IFS=',' read -r -a EKS_EIP_LIST <<< "${EKS_EIP_LIST_STRING}"


##### CREATE GKE YAMLs
# Start the YAML file
for GKE in ${GKE_LIST[@]}
do
    echo -e "Building file for $GKE..."
    echo -e "${HEADER}" > asm_$GKE.yaml

    echo -e "${GKE_COMPONENT}" | sed -e s/ENV/$ENV/g >> asm_$GKE.yaml

    # Add values
    echo -e "${GCP_VALUES}" | sed -e s/GKE/$GKE/g -e s/GCP_NET/$GKE_NET/g >> asm_$GKE.yaml

    # Add registries
    for GKE_NAME in ${GKE_LIST[@]}
    do
       echo -e "$GCP_REGISTRY" | sed -e s/GKE/$GKE_NAME/g >> asm_$GKE.yaml
    done

    # Add GCP bottom
    echo -e "$GATEWAYS_REGISTRY" >> asm_$GKE.yaml

    # Add EKS cluster sections
    for IDX in ${!EKS_LIST[@]}
    do
        let INGRESS_IP_IDX="($IDX + 1) * 2 - 2"
        echo -e "${EKS_REMOTE_NETWORK}" | sed -e s/EKS/${EKS_LIST[IDX]}/g -e \
        s/ISTIOINGRESS_IP/${EKS_INGRESS_IPS[INGRESS_IP_IDX]}/g >> asm_$GKE.yaml
    done
done

##### CREATE EKS YAMLs
# Start the YAML file
for EKS_IDX in ${!EKS_LIST[@]}
do
    echo -e "Building file for ${EKS_LIST[EKS_IDX]}..."
    echo -e "${HEADER}" > asm_${EKS_LIST[EKS_IDX]}.yaml

    # Add istio ingress gateway annotations to get EIPs
    let EIP_IDX_1="($EKS_IDX + 1) * 2 - 2"
    let EIP_IDX_2="($EKS_IDX + 1) * 2 - 1"

    # echo -e "for ${EKS_LIST[EKS_IDX]}, the first EIP index is $EIP_IDX_1"
    # echo -e "for ${EKS_LIST[EKS_IDX]}, the second EIP index is $EIP_IDX_2"

    echo -e "${EKS_COMPONENT}" | sed -e s/EIP1/${EKS_EIP_LIST[EIP_IDX_1]}/g -e s/EIP2/${EKS_EIP_LIST[EIP_IDX_2]}/g >> asm_${EKS_LIST[EKS_IDX]}.yaml

    # Add meshconfig
    echo -e "${EKS_MESHCONFIG}" | sed -e s/EKS/${EKS_LIST[EKS_IDX]}/g -e s/PROJECT_ID/$PROJECT_ID/g -e s/CLUSTER_LOCATION/us-west1/g >> asm_${EKS_LIST[EKS_IDX]}.yaml

    # Add values
    echo -e "${EKS_VALUES}" | sed -e s/EKS/${EKS_LIST[EKS_IDX]}/g -e s/GCP_NET/$GKE_NET/g >> asm_${EKS_LIST[EKS_IDX]}.yaml

    # Add registries
    for GKE_NAME in ${GKE_LIST[@]}
    do
        echo -e "${GCP_REGISTRY}" | sed -e s/GKE/$GKE_NAME/g >> asm_${EKS_LIST[EKS_IDX]}.yaml
    done

    # Add GCP bottom
    echo -e "${GATEWAYS_REGISTRY}" >> asm_${EKS_LIST[EKS_IDX]}.yaml

    # Add EKS cluster sections
    for IDX in ${!EKS_LIST[@]}
    do
        if [[ $EKS_IDX == $IDX ]]; then
            echo -e "Building network patch for ${EKS_LIST[EKS_IDX]} and small IDX is $IDX"
            echo -e "${EKS_SELF_NETWORK}" | sed -e s/EKS/${EKS_LIST[IDX]}/g \
            >> asm_${EKS_LIST[EKS_IDX]}.yaml
        else
            echo -e "Building network patch for ${EKS_LIST[EKS_IDX]} and small IDX is $IDX"
            let INGRESS_IP_IDX="($IDX + 1) * 2 - 2"
            echo -e "${EKS_REMOTE_NETWORK}" | sed -e s/EKS/${EKS_LIST[IDX]}/g -e \
            s/ISTIOINGRESS_IP/${EKS_INGRESS_IPS[INGRESS_IP_IDX]}/g \
            >> asm_${EKS_LIST[EKS_IDX]}.yaml
        fi
    done
done

for GKE in ${GKE_LIST[@]}
do
    echo -e "\n######### $GKE YAML ###########\n"
    cat asm_$GKE.yaml
done

for EKS in ${EKS_LIST[@]}
do
    echo -e "\n######### $EKS YAML ###########\n"
    cat asm_$EKS.yaml
done

