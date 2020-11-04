/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#START:eks_prod_1
module "eks_prod_1" {
  source           = "../../../../platform_admins/shared_terraform_modules/aws/eks/"
  eks_cluster_name = var.eks1_cluster_name
  vpc_id           = data.terraform_remote_state.prod_aws_vpc.outputs.id
  private_subnets  = data.terraform_remote_state.prod_aws_vpc.outputs.private_subnets
  project_id       = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
  env              = var.env
  repo_url         = "git@gitlab.endpoints.${data.terraform_remote_state.prod_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/${var.config-repo}.git"
}
#END:eks_prod_1

#START:eks_prod_2
module "eks_prod_2" {
  source           = "../../../../platform_admins/shared_terraform_modules/aws/eks/"
  eks_cluster_name = var.eks2_cluster_name
  vpc_id           = data.terraform_remote_state.prod_aws_vpc.outputs.id
  private_subnets  = data.terraform_remote_state.prod_aws_vpc.outputs.private_subnets
  project_id       = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
  env              = var.env
  repo_url         = "git@gitlab.endpoints.${data.terraform_remote_state.prod_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/${var.config-repo}.git"
}
#END:eks_prod_2

###MARKER###
