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

module "asm-prod" {
  source              = "../../../../platform_admins/shared_terraform_modules/gcp/asm/"
  project_id          = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
  gke_net             = var.gke_net
  asm_version         = var.asm_version
  env                 = var.env
  gke_list            = join(",", "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_list}")
  gke_location_list   = join(",", "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_location_list}")
  eks_list            = join(",", "${data.terraform_remote_state.prod_aws_eks.outputs.eks_list}")
  eks_eip_list        = join(",", "${data.terraform_remote_state.prod_aws_vpc.outputs.eip_ids}")
  eks_ingress_ip_list = join(",", "${data.terraform_remote_state.prod_aws_vpc.outputs.eip_public_ips}")
}
