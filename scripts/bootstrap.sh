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
mkdir -p ${SCRIPT_DIR}/../../logs
export LOG_FILE=${SCRIPT_DIR}/../../logs/bootstrap-$(date +%s).log
touch ${LOG_FILE}
exec 2>&1
exec &> >(tee -i ${LOG_FILE})

source ${SCRIPT_DIR}/../scripts/functions.sh
source ${SCRIPT_DIR}/../scripts/vars.sh

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
title_no_wait "*** BOOTSTRAP ***"
echo -e "\n"

source ${SCRIPT_DIR}/../scripts/tools.sh

if [[ ! ${GOOGLE_PROJECT} ]]; then
    title_no_wait "You have not defined your project ID in the GOOGLE_PROJECT variable."
    exit 1
fi

title_no_wait "Enabling APIs..."
print_and_execute "gcloud services enable cloudresourcemanager.googleapis.com \
cloudbilling.googleapis.com \
iam.googleapis.com \
compute.googleapis.com \
container.googleapis.com \
serviceusage.googleapis.com \
sourcerepo.googleapis.com \
cloudbuild.googleapis.com \
servicemanagement.googleapis.com \
anthos.googleapis.com"

title_no_wait "Getting Cloudbuild Service Account..."
print_and_execute "export TF_CLOUDBUILD_SA=$(gcloud projects describe $GOOGLE_PROJECT --format='value(projectNumber)')@cloudbuild.gserviceaccount.com"

title_no_wait "Giving Cloudbuild SA project owner role"
print_and_execute "gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT} \
--member serviceAccount:${TF_CLOUDBUILD_SA} \
--role roles/owner"

title_no_wait "Giving Cloudbuild SA cluster admin role"
print_and_execute "gcloud projects add-iam-policy-binding ${GOOGLE_PROJECT} \
--member serviceAccount:${TF_CLOUDBUILD_SA} \
--role roles/container.admin"

if [[ $(gsutil ls | grep "gs://${GOOGLE_PROJECT}/") ]]; then
    title_no_wait "Bucket gs://${GOOGLE_PROJECT} already exists."
else    
    title_no_wait "Creating a GCS bucket for terraform shared states..."
    print_and_execute "gsutil mb -p ${GOOGLE_PROJECT} gs://${GOOGLE_PROJECT}"
fi

if [[ $(gsutil versioning get gs://$GOOGLE_PROJECT | grep Enabled) ]]; then
    title_no_wait "Versioning already enabled on bucket gs://${GOOGLE_PROJECT}"
else
    title_no_wait "Enabling versioning on the GCS bucket..."
    print_and_execute "gsutil versioning set on gs://${GOOGLE_PROJECT}"
fi

if [[ $(gcloud source repos list | grep infrastructure) ]]; then
    title_no_wait "Source repo 'infrastructure' already exists"
else
    title_no_wait "Creating infrastructure CSR repo..."
    print_and_execute "gcloud source repos create infrastructure"
fi

if [[ $(gcloud alpha builds triggers list | grep push-to-master) ]]; then
    title_no_wait "Build trigger 'push-to-master' already exists."
else
    title_no_wait "Creating cloudbuild trigger for infrastructure deployment..."
    print_and_execute "gcloud alpha builds triggers create cloud-source-repositories \
    --repo='infrastructure' --description='push to master' --branch-pattern='master' \
    --build-config='cloudbuild.yaml'"
fi

title_no_wait "Setting default project and credentials..."
print_and_execute "export GOOGLE_PROJECT=${GOOGLE_PROJECT}"

title_no_wait "Creating KMS keyring for AWS credentials..."
if [[ $(gcloud kms keyrings describe aws-creds --location global &> /dev/null || echo $?) ]]; then
  gcloud kms keyrings create aws-creds --location global
else
  title_no_wait "KMS keyring aws-creds already created."
fi

title_no_wait "Creating KMS key aws-access-id..."
if [[ $(gcloud kms keys describe aws-access-id --location=global --keyring=aws-creds &> /dev/null || echo $?) ]]; then
  gcloud kms keys create aws-access-id \
      --location global --keyring aws-creds \
      --purpose encryption
else
  title_no_wait "KMS key aws-access-id already created."
fi

title_no_wait "Creating KMS key aws-secret-access-key..."
if [[ $(gcloud kms keys describe aws-secret-access-key --location=global --keyring=aws-creds &> /dev/null || echo $?) ]]; then
  gcloud kms keys create aws-secret-access-key \
      --location global --keyring aws-creds \
      --purpose encryption
else
  title_no_wait "KMS key aws-secret-access-key already created."
fi

title_no_wait "Preparing bootstrap.sh script..."
export AWS_ACCESS_KEY_ID_ENCRYPTED_PASS=$(echo -n "${AWS_ACCESS_KEY_ID}" | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=aws-creds --key=aws-access-id | base64) 
export AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS=$(echo -n "${AWS_SECRET_ACCESS_KEY}" | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=aws-creds --key=aws-secret-access-key | base64)
export AWS_ACCESS_KEY_ID_ENCRYPTED_PASS_NO_SPACES="$(echo -e "${AWS_ACCESS_KEY_ID_ENCRYPTED_PASS}" | tr -d '[:space:]')"
export AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS_NO_SPACES="$(echo -e "${AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS}" | tr -d '[:space:]')"
sed -e s/GOOGLE_PROJECT/$GOOGLE_PROJECT/g ${SCRIPT_DIR}/../infrastructure/cloudbuild.yaml_tmpl > ${SCRIPT_DIR}/../infrastructure/cloudbuild.yaml
sed -i -e s~AWS_ACCESS_KEY_ID_ENCRYPTED_PASS~"${AWS_ACCESS_KEY_ID_ENCRYPTED_PASS_NO_SPACES}"~g ${SCRIPT_DIR}/../infrastructure/cloudbuild.yaml
sed -i -e s~AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS~"${AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS_NO_SPACES}"~g ${SCRIPT_DIR}/../infrastructure/cloudbuild.yaml

title_no_wait "Create ACM SSH key pair for CSR Repo..."
# Check if there is already a csr key present
if [[ $(gsutil ls gs://$GOOGLE_PROJECT/ssh-key &> /dev/null || echo $?) ]]; then
  title_no_wait "Creating SSH key pair..."
  # Create an SSH key pair
  ssh-keygen -t rsa -b 4096 \
  -C "${USER}@qwiklabs.net" \
  -N '' \
  -f csr-key
  # Copy to GCS bucket
  gsutil cp -r csr-key gs://$GOOGLE_PROJECT/ssh-key/csr-key
  gsutil cp -r csr-key.pub gs://$GOOGLE_PROJECT/ssh-key/csr-key.pub
  # Move key pair to the acm folder
  mv csr-key* ${SCRIPT_DIR}/../infrastructure/ops/prod/acm
else
  title_no_wait "SSH Key pairs already exist."
  # Copy from GCS bucket
  gsutil cp -r gs://$GOOGLE_PROJECT/ssh-key/csr-key csr-key
  gsutil cp -r gs://$GOOGLE_PROJECT/ssh-key/csr-key.pub csr-key.pub
  # Move to acm folder
  cp csr-key* ${SCRIPT_DIR}/../infrastructure/ops/prod/acm
  cp csr-key.pub ${SCRIPT_DIR}/../infrastructure/ops/prod/repos/acm-key.pub
fi

title_no_wait "Preparing terraform backends and shared states files..."
# Define an array of GCP resources
declare -a folders
folders=(
    'network/prod/vpc'
    'ops/prod/gke'
    'ops/prod/eks'
    'ops/prod/acm'
    'ops/prod/gitlab'
    'ops/prod/asm'
    'ops/prod/repos'
    )

# Build backends and shared states for each GCP prod resource
for idx in ${!folders[@]}
do
    # Extract the resource name from the folder
    resource=$(echo ${folders[idx]} | grep -oP '([^\/]+$)')
    environ=$(echo ${folders[idx]} | cut -d'/' -f2)
    
    # Create backends
    sed -e s/GOOGLE_PROJECT/${GOOGLE_PROJECT}/ -e s/ENV/${environ}/ -e s/RESOURCE/${resource}/ \
    ${SCRIPT_DIR}/../infrastructure/templates/backend.tf_tmpl > ${SCRIPT_DIR}/../infrastructure/${folders[idx]}/backend.tf

    # Create shared states for every resource
    sed -e s/GOOGLE_PROJECT/${GOOGLE_PROJECT}/ -e s/ENV/${environ}/ -e s/RESOURCE/${resource}/ \
    ${SCRIPT_DIR}/../infrastructure/templates/shared_state.tf_tmpl > ${SCRIPT_DIR}/../infrastructure/gcp/${environ}/shared_states/shared_state_${resource}.tf

    # Create vars from terraform.tfvars_tmpl files
    tfvar_tmpl_file=${SCRIPT_DIR}/../infrastructure/${folders[idx]}/terraform.tfvars_tmpl
    if [ -f "$tfvar_tmpl_file" ]; then
        envsubst < ${SCRIPT_DIR}/../infrastructure/${folders[idx]}/terraform.tfvars_tmpl \
        > ${SCRIPT_DIR}/../infrastructure/${folders[idx]}/terraform.tfvars
    fi

    # Create vars from variables.auto.tfvars_tmpl files
    auto_tfvar_tmpl_file=${SCRIPT_DIR}/../infrastructure/${folders[idx]}/variables.auto.tfvars_tmpl
    if [ -f "$auto_tfvar_tmpl_file" ]; then
        envsubst < ${SCRIPT_DIR}/../infrastructure/${folders[idx]}/variables.auto.tfvars_tmpl \
        > ${SCRIPT_DIR}/../infrastructure/${folders[idx]}/variables.auto.tfvars
    fi

done

title_no_wait "Committing infrastructure terraform to cloud source repo..."
if [ -d ${SCRIPT_DIR}/../../infra-repo ]; then
    print_and_execute "
    cp -r ${SCRIPT_DIR}/../infrastructure/* ${SCRIPT_DIR}/../../infra-repo
    cd ${SCRIPT_DIR}/../../infra-repo
    git add . && git commit -am 'commit'
    git push infra master
    "
else
    print_and_execute "
    mkdir -p ${SCRIPT_DIR}/../../infra-repo
    cp -r ${SCRIPT_DIR}/../infrastructure/* ${SCRIPT_DIR}/../../infra-repo
    cd ${SCRIPT_DIR}/../../infra-repo
    git init
    git config --local user.email ${TF_CLOUDBUILD_SA}
    git config --local user.name 'terraform'
    git config --local credential.'https://source.developers.google.com'.helper gcloud.sh
    git remote add infra https://source.developers.google.com/p/$GOOGLE_PROJECT/r/infrastructure
    git add . && git commit -am 'first commit'
    git push infra master
    "
fi
