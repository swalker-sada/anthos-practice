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

variable "project_id" {
  type = string
}

variable "account_id" {
  type = string
}

# gke_list is a comma separated string that gets re-formatted  in the bash script
variable "gke_list" {
  type = string
}

# gke_location_list is a comma separated string that gets re-formatted  in the bash script
variable "gke_location_list" {
  type = string
}
