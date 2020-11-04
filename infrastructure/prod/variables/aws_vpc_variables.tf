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

variable "name" { default = "aws-vpc-prod" }
variable "cidr" { default = "10.100.0.0/16" }
variable "azs" { default = ["us-west-2a", "us-west-2b"] }
# EKS requires minimum two AZs and 2 subnets
# https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
variable "private_subnets" { default = [
  "10.100.1.0/24", "10.100.2.0/24"
] }
variable "public_subnets" { default = [
  "10.100.3.0/24", "10.100.4.0/24"
] }

variable "eip_count" { default = 4 }
