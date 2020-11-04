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

# GKE Stage 1
module "gke_stage_1" {
  source             = "../../../../platform_admins/shared_terraform_modules/gcp/gke/"
  subnet             = data.terraform_remote_state.stage_gcp_vpc.outputs.subnets["${var.gke1_subnet_name}"]
  suffix             = var.gke1_suffix
  zone               = var.gke1_zone
  env                = var.env
  acm_ssh_auth_key   = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
  acm_sync_repo      = "git@gitlab.endpoints.${data.terraform_remote_state.stage_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/${var.config-repo}.git"
  hub_sa_private_key = data.terraform_remote_state.prod_gcp_hub_gsa.outputs.private_key
}
