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

module "vpc" {
  source = "terraform-google-modules/network/google"

  project_id   = var.project_id
  network_name = var.network_name
  routing_mode = "GLOBAL"

  subnets = [
    for subnet in var.subnets : {
      subnet_name   = subnet.subnet_name
      subnet_ip     = subnet.subnet_ip
      subnet_region = subnet.subnet_region
    }
  ]

  secondary_ranges = {
    for subnet in var.subnets :
    subnet.subnet_name => subnet.secondary_ranges
  }
}
