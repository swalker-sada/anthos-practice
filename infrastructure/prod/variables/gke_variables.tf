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

#START:gke1
variable "gke1_subnet_name" {
  type    = string
  default = "us-west2/prod-gcp-vpc-01-us-west2-subnet-01"
}

variable "gke1_region" {
  type    = string
  default = "us-west2"
}

variable "gke1_suffix" {
  type    = number
  default = 1
}

variable "gke1_zone" {
  type    = string
  default = "a"
}
#END:gke1

#START:gke2
variable "gke2_subnet_name" {
  type    = string
  default = "us-west2/prod-gcp-vpc-01-us-west2-subnet-01"
}
variable "gke2_region" {
  type    = string
  default = "us-west2"
}

variable "gke2_suffix" {
  type    = number
  default = 2
}

variable "gke2_zone" {
  type    = string
  default = "b"
}

variable "env" {
  type    = string
  default = "prod"
}
#END:gke2

variable "config-repo" {
  type = string
  default = "config"
}
