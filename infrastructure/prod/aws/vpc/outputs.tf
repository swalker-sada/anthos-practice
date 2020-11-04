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

output "id" { value = "${module.prod_vpc.id}" }
output "name" { value = "${module.prod_vpc.name}" }
output "private_subnets" { value = "${module.prod_vpc.private_subnets}" }
output "public_subnets" { value = "${module.prod_vpc.public_subnets}" }
output "eip_ids" { value = "${module.prod_vpc.eip_ids}" }
output "eip_public_ips" { value = "${module.prod_vpc.eip_public_ips}" }

