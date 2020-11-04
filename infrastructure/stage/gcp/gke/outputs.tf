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

output "gke_stage_1_name" { value = "${module.gke_stage_1.name}" }
output "gke_stage_1_location" { value = "${module.gke_stage_1.location}" }
output "gke_stage_1_endpoint" { value = "${module.gke_stage_1.endpoint}" }

output "gke_list" { value = ["${module.gke_stage_1.name}"] }
output "gke_location_list" { value = ["${module.gke_stage_1.location}"] }
