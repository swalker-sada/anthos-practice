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

module "dev_gcp_vpc_01" {
  source       = "../../../../platform_admins/shared_terraform_modules/gcp/vpc/"
  project_id   = var.project_id
  network_name = var.network_name
  subnets      = var.subnets
}

# create firewall rules to allow-all inernally and SSH from external
module "dev-net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = module.dev_gcp_vpc_01.project_id
  network                 = module.dev_gcp_vpc_01.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/8"]
  internal_allow = [
    { "protocol" : "all" },
  ]
}
