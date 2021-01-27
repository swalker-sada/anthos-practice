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
touch ${SCRIPT_DIR}/../../../vars.sh
export LOG_FILE=${SCRIPT_DIR}/../../../logs/bootstrap-$(date +%s).log
touch ${LOG_FILE}
exec 2>&1
exec &> >(tee -i ${LOG_FILE})

source ${SCRIPT_DIR}/../scripts/functions.sh

# Set speed
bold=$(tput bold)
normal=$(tput sgr0)

color='\e[1;32m' # green
nc='\e[0m'

echo -e "\n"
title_no_wait "*** BOOTSTRAP ***"
echo -e "\n"

# Pin ASM version, needed for tools.sh script
grep -q "export ASM_VERSION.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "export ASM_VERSION=1.6.8-asm.9" >> ${SCRIPT_DIR}/../../../vars.sh

source ${SCRIPT_DIR}/../scripts/tools.sh

if [[ ! ${GOOGLE_PROJECT} ]]; then
    title_no_wait "You have not defined your project ID in the GOOGLE_PROJECT variable."
    read -p "Please enter your GCP project ID: " GOOGLE_PROJECT
fi
grep -q "export GOOGLE_PROJECT.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "export GOOGLE_PROJECT=${GOOGLE_PROJECT}" >> ${SCRIPT_DIR}/../../../vars.sh
grep -q "gcloud config set project.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "gcloud config set project ${GOOGLE_PROJECT}" >> ${SCRIPT_DIR}/../../../vars.sh

if [[ ! ${GCLOUD_USER} ]]; then
    title_no_wait "You have not defined your username in the GCLOUD_USER variable."
    read -p "Please enter your GCP username: " GCLOUD_USER
fi

title_and_wait "Verifying that you are logged in with the correct user. The user should be ${GCLOUD_USER}."
print_and_execute "gcloud config list account --format=json | jq -r .core.account"
export ACCOUNT=`gcloud config list account --format=json | jq -r .core.account`
if [ ${ACCOUNT} == ${GCLOUD_USER} ]; then
    title_no_wait "You are logged in with the correct user account."
    grep -q "export GCLOUD_USER.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "export GCLOUD_USER=${GCLOUD_USER}" >> ${SCRIPT_DIR}/../../../vars.sh
else
    error_no_wait "You are logged in with user ${ACCOUNT}, which does not match the intended ${GCLOUD_USER} user. Ensure you are logged in with ${GCLOUD_USER} by running 'gcloud auth login' and following the instructions. Exiting script."
    exit 1
fi
echo -e "\n"


if [[ ! ${AWS_ACCESS_KEY_ID} ]]; then
    title_no_wait "You have not defined your AWS Access Key ID in the AWS_ACCESS_KEY_ID variable."
    read -p "Please enter your AWS Access Key ID: " AWS_ACCESS_KEY_ID
fi
grep -q "export AWS_ACCESS_KEY_ID.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> ${SCRIPT_DIR}/../../../vars.sh

if [[ ! ${AWS_SECRET_ACCESS_KEY} ]]; then
    title_no_wait "You have not defined your AWS Secret Access Key in the AWS_SECRET_ACCESS_KEY variable."
    read -p "Please enter your AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
fi
grep -q "export AWS_SECRET_ACCESS_KEY.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> ${SCRIPT_DIR}/../../../vars.sh

# Add WORKDIR to vars
grep -q "export WORKDIR=.*" ${SCRIPT_DIR}/../../../vars.sh || echo -e "export WORKDIR=${WORKDIR}" >> ${SCRIPT_DIR}/../../../vars.sh

source ${SCRIPT_DIR}/../../../vars.sh

title_no_wait "Setting GCP project..."
print_and_execute "gcloud config set project ${GOOGLE_PROJECT}"

if [[ ! $API_ENABLED ]]; then
  title_no_wait "Disable CloudBuild API to force cloudbuild SA creation when re-enabled..."
  print_and_execute "gcloud services disable cloudbuild.googleapis.com --force"
fi

if [[ ! $API_ENABLED ]]; then
  title_no_wait "Enabling APIs..."
  print_and_execute "gcloud services enable cloudresourcemanager.googleapis.com \
  cloudbilling.googleapis.com \
  iam.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  serviceusage.googleapis.com \
  sourcerepo.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  cloudtrace.googleapis.com \
  meshca.googleapis.com \
  meshtelemetry.googleapis.com \
  meshconfig.googleapis.com \
  gkeconnect.googleapis.com \
  gkehub.googleapis.com \
  cloudbuild.googleapis.com \
  servicemanagement.googleapis.com \
  secretmanager.googleapis.com \
  anthos.googleapis.com \
  multiclusteringress.googleapis.com"

  # Number of services enable may not exceed 20 thus splitting into 2 commands
  print_and_execute "gcloud services enable \
  sqladmin.googleapis.com \
  redis.googleapis.com \
  cloudkms.googleapis.com" 
  echo -e "export API_ENABLED=true" >> ${SCRIPT_DIR}/../../../vars.sh
fi

if [[ ! $TF_CLOUDBUILD_SA ]]; then
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

  echo -e "export TF_CLOUDBUILD_SA=true" >> ${SCRIPT_DIR}/../../../vars.sh
fi

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

if [[ $(gcloud alpha builds triggers list | grep push-to-main) ]]; then
    title_no_wait "Build trigger 'push-to-main' already exists."
else
    title_no_wait "Creating cloudbuild trigger for infrastructure deployment..."
    print_and_execute "gcloud alpha builds triggers create cloud-source-repositories \
    --repo='infrastructure' --description='push to main' --branch-pattern='main' \
    --build-config='platform_admins/builds/cloudbuild.yaml'"
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

title_no_wait "Preparing cloudbuild.yaml..."
export AWS_ACCESS_KEY_ID_ENCRYPTED_PASS=$(echo -n "${AWS_ACCESS_KEY_ID}" | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=aws-creds --key=aws-access-id | base64) 
export AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS=$(echo -n "${AWS_SECRET_ACCESS_KEY}" | gcloud kms encrypt --plaintext-file=- --ciphertext-file=- --location=global --keyring=aws-creds --key=aws-secret-access-key | base64)
export AWS_ACCESS_KEY_ID_ENCRYPTED_PASS_NO_SPACES="$(echo -e "${AWS_ACCESS_KEY_ID_ENCRYPTED_PASS}" | tr -d '[:space:]')"
export AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS_NO_SPACES="$(echo -e "${AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS}" | tr -d '[:space:]')"

sed -e s/GOOGLE_PROJECT/$GOOGLE_PROJECT/g ${SCRIPT_DIR}/../builds/cloudbuild-prod.yaml_tmpl > ${SCRIPT_DIR}/../builds/cloudbuild-prod.yaml
sed -i -e s~AWS_ACCESS_KEY_ID_ENCRYPTED_PASS~"${AWS_ACCESS_KEY_ID_ENCRYPTED_PASS_NO_SPACES}"~g ${SCRIPT_DIR}/../builds/cloudbuild-prod.yaml
sed -i -e s~AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS~"${AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS_NO_SPACES}"~g ${SCRIPT_DIR}/../builds/cloudbuild-prod.yaml

sed -e s/GOOGLE_PROJECT/$GOOGLE_PROJECT/g ${SCRIPT_DIR}/../builds/cloudbuild-stage.yaml_tmpl > ${SCRIPT_DIR}/../builds/cloudbuild-stage.yaml
sed -i -e s~AWS_ACCESS_KEY_ID_ENCRYPTED_PASS~"${AWS_ACCESS_KEY_ID_ENCRYPTED_PASS_NO_SPACES}"~g ${SCRIPT_DIR}/../builds/cloudbuild-stage.yaml
sed -i -e s~AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS~"${AWS_SECRET_ACCESS_KEY_ENCRYPTED_PASS_NO_SPACES}"~g ${SCRIPT_DIR}/../builds/cloudbuild-stage.yaml

title_no_wait "Preparing AWS credentials secrets..."
if [[ $(gcloud secrets describe aws-access-key-id &> /dev/null || echo $?) ]]; then
  echo $AWS_ACCESS_KEY_ID | gcloud secrets create aws-access-key-id --data-file=-
else
  title_no_wait "AWS access key ID secret exists."
fi
if [[ $(gcloud secrets describe aws-secret-access-key &> /dev/null || echo $?) ]]; then
  echo $AWS_SECRET_ACCESS_KEY | gcloud secrets create aws-secret-access-key --data-file=-
else
  title_no_wait "AWS secret access key secret exists."
fi

title_no_wait "Preparing terraform backends and remote state files..."

ENVS="prod stage dev"
CLOUDS="gcp aws"

for ENV in ${ENVS}
do
    for CLOUD in ${CLOUDS}
    do
	if [[ ${CLOUD} == "gcp"  ]]; then
	  sed -e s/GOOGLE_PROJECT/${GOOGLE_PROJECT}/ ${SCRIPT_DIR}/../../infrastructure/${ENV}/variables/gcp_vpc_variables.tf_tmpl > \
	  ${SCRIPT_DIR}/../../infrastructure/${ENV}/variables/gcp_vpc_variables.tf  
	  sed -e s/GOOGLE_PROJECT/${GOOGLE_PROJECT}/ \
      ${SCRIPT_DIR}/../../infrastructure/${ENV}/variables/project_variables.tf_tmpl > \
	  ${SCRIPT_DIR}/../../infrastructure/${ENV}/variables/project_variables.tf  
	fi
        declare -a FOLDERS
        unset FOLDERS
        if [[ $(ls -d ${SCRIPT_DIR}/../../infrastructure/${ENV}/${CLOUD}/*/) ]]; then
            export FOLDERS=($(ls -d ${SCRIPT_DIR}/../../infrastructure/${ENV}/${CLOUD}/*/))
        fi
        if [[ ${FOLDERS} ]]; then
            export FOLDERS=("${FOLDERS[@]%/}")
            export FOLDERS=("${FOLDERS[@]##*/}")
            for RESOURCE in ${FOLDERS[@]}
            do
                sed -e s/GOOGLE_PROJECT/${GOOGLE_PROJECT}/ -e s/ENV/${ENV}/ -e s/CLOUD/${CLOUD}/ -e s/RESOURCE/${RESOURCE}/ \
                ${SCRIPT_DIR}/../shared_terraform_modules/templates/backend.tf_tmpl > \
                ${SCRIPT_DIR}/../../infrastructure/${ENV}/backends/${ENV}_${CLOUD}_${RESOURCE}_backend.tf

                sed -e s/GOOGLE_PROJECT/${GOOGLE_PROJECT}/ -e s/ENV/${ENV}/ -e s/CLOUD/${CLOUD}/ -e s/RESOURCE/${RESOURCE}/ \
                ${SCRIPT_DIR}/../shared_terraform_modules/templates/remote_state.tf_tmpl > \
                ${SCRIPT_DIR}/../../infrastructure/${ENV}/states/${ENV}_${CLOUD}_${RESOURCE}_remote_state.tf
            done
        fi
    done
done

title_no_wait "Committing infrastructure terraform to cloud source repo..."
if [ -d ${SCRIPT_DIR}/../../../infra-repo ]; then
    print_and_execute "
    rm -rf ${SCRIPT_DIR}/../../../infra-repo/infrastructure
    rm -rf ${SCRIPT_DIR}/../../../infra-repo/platform_admins
    cp -r ${SCRIPT_DIR}/../../infrastructure ${SCRIPT_DIR}/../../../infra-repo
    cp -r ${SCRIPT_DIR}/../../platform_admins ${SCRIPT_DIR}/../../../infra-repo
    # cp -rf ${SCRIPT_DIR}/../../cloudbuil*.yaml ${SCRIPT_DIR}/../../../infra-repo
    cp -r ${SCRIPT_DIR}/../../Dockerfile ${SCRIPT_DIR}/../../../infra-repo
    cd ${SCRIPT_DIR}/../../../infra-repo
    git add . && git commit -am 'commit'
    git push infra main
    "
else
    print_and_execute "
    mkdir -p ${SCRIPT_DIR}/../../../infra-repo
    cp -r ${SCRIPT_DIR}/../../infrastructure ${SCRIPT_DIR}/../../../infra-repo
    cp -r ${SCRIPT_DIR}/../../platform_admins ${SCRIPT_DIR}/../../../infra-repo
    # cp -rf ${SCRIPT_DIR}/../../cloudbuil*.yaml ${SCRIPT_DIR}/../../../infra-repo
    cp -r ${SCRIPT_DIR}/../../Dockerfile ${SCRIPT_DIR}/../../../infra-repo
    cd ${SCRIPT_DIR}/../../../infra-repo
    git init
    git checkout -b main
    git config --local user.email ${TF_CLOUDBUILD_SA}
    git config --local user.name 'terraform'
    git config --local credential.'https://source.developers.google.com'.helper gcloud.sh
    git remote add infra https://source.developers.google.com/p/$GOOGLE_PROJECT/r/infrastructure
    git add . && git commit -am 'first commit'
    git push infra main
    "
fi
