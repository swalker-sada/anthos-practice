#!/usr/bin/env bash
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

# Get GKE and EKS cluster details
cd ${CI_PROJECT_DIR}/tf
sed -e s/PROJECT_ID/${PROJECT_ID}/ prod_aws_eks_remote_state.tf_tmpl > prod_aws_eks_remote_state.tf
sed -e s/PROJECT_ID/${PROJECT_ID}/ prod_gcp_gke_remote_state.tf_tmpl > prod_gcp_gke_remote_state.tf
sed -e s/PROJECT_ID/${PROJECT_ID}/ stage_aws_eks_remote_state.tf_tmpl > stage_aws_eks_remote_state.tf
sed -e s/PROJECT_ID/${PROJECT_ID}/ stage_gcp_gke_remote_state.tf_tmpl > stage_gcp_gke_remote_state.tf
sed -e s/PROJECT_ID/${PROJECT_ID}/ dev_gcp_gke_remote_state.tf_tmpl > dev_gcp_gke_remote_state.tf
terraform init
terraform plan -out terraform.tfplan
terraform apply -input=false -lock=false terraform.tfplan
export GKE_PROD_1_NAME=$(terraform output gke_prod_1_name)
export GKE_PROD_1_LOCATION=$(terraform output gke_prod_1_location)
export GKE_PROD_2_NAME=$(terraform output gke_prod_2_name)
export GKE_PROD_2_LOCATION=$(terraform output gke_prod_2_location)
export EKS_PROD_1_NAME=$(terraform output eks_prod_1_name)
export EKS_PROD_2_NAME=$(terraform output eks_prod_2_name)
export GKE_STAGE_1_NAME=$(terraform output gke_stage_1_name)
export GKE_STAGE_1_LOCATION=$(terraform output gke_stage_1_location)
export EKS_STAGE_1_NAME=$(terraform output eks_stage_1_name)
export GKE_DEV_1_NAME=$(terraform output gke_dev_1_name)
export GKE_DEV_1_LOCATION=$(terraform output gke_dev_1_location)
export GKE_DEV_2_NAME=$(terraform output gke_dev_2_name)
export GKE_DEV_2_LOCATION=$(terraform output gke_dev_2_location)
cd ${CI_PROJECT_DIR}

### Unable to use gitlab dotenv, because it has a max of 10 variables, so manually managing
echo "GKE_PROD_1_NAME=${GKE_PROD_1_NAME}" > ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_PROD_1_LOCATION=${GKE_PROD_1_LOCATION}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_PROD_2_NAME=${GKE_PROD_2_NAME}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_PROD_2_LOCATION=${GKE_PROD_2_LOCATION}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "EKS_PROD_1_NAME=${EKS_PROD_1_NAME}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "EKS_PROD_2_NAME=${EKS_PROD_2_NAME}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_STAGE_1_NAME=${GKE_STAGE_1_NAME}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_STAGE_1_LOCATION=${GKE_STAGE_1_LOCATION}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "EKS_STAGE_1_NAME=${EKS_STAGE_1_NAME}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_DEV_1_NAME=${GKE_DEV_1_NAME}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_DEV_1_LOCATION=${GKE_DEV_1_LOCATION}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_DEV_2_NAME=${GKE_DEV_2_NAME}" >> ${CI_PROJECT_DIR}/cluster_variables.env
echo "GKE_DEV_2_LOCATION=${GKE_DEV_2_LOCATION}" >> ${CI_PROJECT_DIR}/cluster_variables.env