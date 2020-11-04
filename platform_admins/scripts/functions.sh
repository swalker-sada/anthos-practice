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

title_no_wait () {
    echo "${bold}# ${@}${normal}"
}

title_and_wait () {
    export CYAN='\033[1;36m'
    export YELLOW="\e[38;5;226m"
    export NC='\e[0m'
    echo "${bold}# ${@}"
    echo -e "${YELLOW}--> Press ENTER to continue...${NC}"
    read -p ''
}

print_and_execute () {

    SPEED=290
    GREEN='\e[1;32m' # green
    NC='\e[0m'

    printf "${GREEN}\$ ${@}${NC}" | pv -qL $SPEED;
    printf "\n"
    eval "$@" ;
}

nopv_and_execute () {

    SPEED=290
    GREEN='\e[1;32m' # green
    NC='\e[0m'

    printf "${GREEN}\$ ${@}${NC}";
    printf "\n"
    eval "$@" ;
}

error_no_wait () {
    RED='\e[1;91m' # red
    NC='\e[0m'
    printf "${RED}# ${@}${NC}"
    printf "\n"
}

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


export -f print_and_execute
export -f title_no_wait
export -f title_and_wait
export -f nopv_and_execute
export -f error_no_wait
export -f is_deployment_ready
export -f get_svc_ingress_ip
