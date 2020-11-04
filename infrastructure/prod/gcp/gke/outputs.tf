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

#[START:gke_prod_1]
output "gke_prod_1_name" { value = "${module.gke_prod_1.name}" }
output "gke_prod_1_location" { value = "${module.gke_prod_1.location}" }
output "gke_prod_1_endpoint" { value = "${module.gke_prod_1.endpoint}" }
#[END:gke_prod_1]

#[START:gke_prod_2]
output "gke_prod_2_name" { value = "${module.gke_prod_2.name}" }
output "gke_prod_2_location" { value = "${module.gke_prod_2.location}" }
output "gke_prod_2_endpoint" { value = "${module.gke_prod_2.endpoint}" }
#[END:gke_prod_2]

output "gke_list" {
  value = [
    #[START:gke_prod_1]
    "${module.gke_prod_1.name}",
    #[END:gke_prod_1]
    #[START:gke_prod_2]
    "${module.gke_prod_2.name}",
    #[END:gke_prod_2]
  ]
}

output "gke_location_list" {
  value = [
    #[START:gke_prod_1]
    "${module.gke_prod_1.location}",
    #[END:gke_prod_1]
    #[START:gke_prod_2]
    "${module.gke_prod_2.location}",
    #[END:gke_prod_2]
  ]
}

###MARKER###
