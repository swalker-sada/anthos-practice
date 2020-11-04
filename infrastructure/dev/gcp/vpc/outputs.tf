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

output "network" { value = module.dev_gcp_vpc_01.network }
output "project_id" { value = module.dev_gcp_vpc_01.project_id }
output "network_name" { value = module.dev_gcp_vpc_01.network_name }
output "subnets" { value = module.dev_gcp_vpc_01.subnets }
output "subnets_ips" { value = module.dev_gcp_vpc_01.subnets_ips }
output "subnets_names" { value = module.dev_gcp_vpc_01.subnets_names }
output "subnets_regions" { value = module.dev_gcp_vpc_01.subnets_regions }
output "subnets_secondary_ranges" { value = module.dev_gcp_vpc_01.subnets_secondary_ranges }
