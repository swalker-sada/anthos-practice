#!/usr/bin/env bash

# Copyright 2019 Google LLC
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


# Verify that the scripts are being run from Linux and not Mac
if [[ $OSTYPE != "linux-gnu" ]]; then
    echo "ERROR: This script and consecutive set up scripts have only been tested on Linux. Currently, only Linux (debian) is supported. Please run in Cloud Shell or in a VM running Linux".
    exit;
fi

# Export a SCRIPT_DIR var and make all links relative to SCRIPT_DIR
export SCRIPT_DIR=$(dirname $(readlink -f $0 2>/dev/null) 2>/dev/null || echo "${PWD}/$(dirname $0)")

# Create a logs folder and file and send stdout and stderr to console and log file
mkdir -p ${SCRIPT_DIR}/../../../logs
touch ${HOME}/.gcp-workshop.bash
export LOG_FILE=${SCRIPT_DIR}/../../../logs/tools-$(date +%s).log
touch ${LOG_FILE}
exec 2>&1
exec &> >(tee -i ${LOG_FILE})

source ${SCRIPT_DIR}/../scripts/functions.sh
source ${SCRIPT_DIR}/../../../vars.sh

# Tools

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
title_no_wait "*** TOOLS ***"
echo -e "\n"
title_no_wait "Download kustomize cli, pv and kubectl krew plugin tools."
nopv_and_execute "mkdir -p ${HOME}/bin && cd ${HOME}/bin"
export KUSTOMIZE_FILEPATH="${HOME}/bin/kustomize"
if [ -f ${KUSTOMIZE_FILEPATH} ]; then
    title_no_wait "kustomize is already installed and in the ${KUSTOMIZE_FILEPATH} folder."
else
    nopv_and_execute "curl -s \"https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh\"  | bash"
fi
export PATH=$PATH:${HOME}/bin:${HOME}/.local/bin
grep -q "export PATH=.*${HOME}/bin.*" ${HOME}/.gcp-workshop.bash || echo "export PATH=$PATH:${HOME}/bin:${HOME}/.local/bin" >> ${HOME}/.gcp-workshop.bash
echo -e "\n"

export PV_INSTALLED=`which pv`
if [ -z ${PV_INSTALLED} ]; then
    nopv_and_execute "sudo apt-get update && sudo apt-get -y install pv"
    nopv_and_execute "sudo mv /usr/bin/pv ${HOME}/bin/pv"
else
    title_no_wait "pv is already installed and in the ${PV_INSTALLED} folder."
fi

export KREW_FILEPATH="${HOME}/.krew"
if [ -d ${KREW_FILEPATH} ]; then
    title_no_wait "kubectl krew is already installed and in the ${KREW_FILEPATH} folder."
else
    nopv_and_execute "
    (
    set -x; cd \"$(mktemp -d)\" &&
    curl -fsSLO \"https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}\" &&
    tar zxvf krew.tar.gz &&
    ./krew-\"$(uname | tr '[:upper:]' '[:lower:]')_amd64\"  install --manifest=krew.yaml --archive=krew.tar.gz &&
    ./krew-\"$(uname | tr '[:upper:]' '[:lower:]')_amd64\" update
    )
    "
    export PATH="${PATH}:${HOME}/.krew/bin"
    grep -q "export PATH=.*\${HOME}/.krew/bin" ${HOME}/.gcp-workshop.bash || echo -e "export PATH="${PATH}:${HOME}/.krew/bin"" >> ~/.gcp-workshop.bash
    kubectl krew install ctx
    kubectl krew install ns
fi

# AWS CLI and Authenticator
title_no_wait "Installing aws cli..."
export AWS_INSTALLED=`which aws`
if [[ ${AWS_INSTALLED} ]]; then
  title_no_wait "aws cli is already installed."
else
  curl -O https://bootstrap.pypa.io/get-pip.py
  sudo apt update && sudo apt-get install -y python3-distutils 

  python3 get-pip.py --user
  pip3 install awscli --upgrade --user
  rm -rf get-pip.py
  aws --version
fi

title_no_wait "Installing aws-iam-authenticator..."
export AWS_AUTHENTICATOR_INSTALLED=`which aws-iam-authenticator`
if [[ ${AWS_AUTHENTICATOR_INSTALLED} ]]; then
  title_no_wait "aws-iam-authenticator is already installed."
else
  curl -o ${HOME}/.local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-08-04/bin/linux/amd64/aws-iam-authenticator
  chmod +x ${HOME}/.local/bin/aws-iam-authenticator
  aws-iam-authenticator help
fi

title_no_wait "Installing kubectl_aliases..."
export KUBE_ALIAS=$(cat $HOME/.gcp-workshop.bash | grep kubectl_alias)
if [[ -z $KUBE_ALIAS ]]; then
  wget -O $HOME/.kubectl_aliases https://raw.githubusercontent.com/ahmetb/kubectl-alias/master/.kubectl_aliases
  echo -e "[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases" >> ~/.gcp-workshop.bash
else
  title_no_wait "kubectl_aliases already installed!"
fi

title_no_wait "Enabling kubectl autocompletion..."
grep -q "kubectl completion bash" ${HOME}/.gcp-workshop.bash || echo 'source <(kubectl completion bash)' >> ${HOME}/.gcp-workshop.bash 

title_no_wait "Installing istioctl..."
if [[ ! ${ASM_VERSION} ]]; then
  read -p "Enter ASM version: " ASM_VERSION
fi
grep -q "export ASM_VERSION.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "export ASM_VERSION=${ASM_VERSION}" >> ${SCRIPT_DIR}/../../../vars.sh


export ISTIOCTL_INSTALLED=`which istioctl`
if [[ ${ISTIOCTL_INSTALLED} ]]; then
  title_no_wait "istioctl is already installed."
else
  wget -O $HOME/istio-${ASM_VERSION}-linux-amd64.tar.gz https://storage.googleapis.com/gke-release/asm/istio-${ASM_VERSION}-linux-amd64.tar.gz
  tar -C $HOME -xzf $HOME/istio-${ASM_VERSION}-linux-amd64.tar.gz
  rm -rf $HOME/istio-${ASM_VERSION}-linux-amd64.tar.gz
  mv $HOME/istio-${ASM_VERSION}/bin/istioctl $HOME/.local/bin/istioctl
fi

export NOMOS_INSTALLED=`which nomos`
if [[ ${NOMOS_INSTALLED} ]]; then
  title_no_wait "nomos is already installed."
else
  gsutil cp gs://config-management-release/released/latest/linux_amd64/nomos $HOME/.local/bin/nomos
  chmod +x $HOME/.local/bin/nomos
fi

title_no_wait "Creating custom shell prompt file..."
print_and_execute "cp ${SCRIPT_DIR}/../scripts/krompt.bash ${HOME}/.krompt.bash"
grep -q ".krompt.bash" ${HOME}/.gcp-workshop.bash || (echo "source ${HOME}/.krompt.bash" >> ${HOME}/.gcp-workshop.bash)

grep -q "vars.sh" ${HOME}/.gcp-workshop.bash || (echo -e "source ${SCRIPT_DIR}/../../../vars.sh" >> ${HOME}/.gcp-workshop.bash)
grep -q ".gcp-workshop.bash" ${HOME}/.bashrc || (echo "source ${HOME}/.gcp-workshop.bash" >> ${HOME}/.bashrc)
