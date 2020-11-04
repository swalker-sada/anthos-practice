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

module "stage_vpc" {
  source = "../../../../platform_admins/shared_terraform_modules/aws/vpc/"

  name              = var.name
  cidr              = var.cidr
  azs               = var.azs
  private_subnets   = var.private_subnets
  public_subnets    = var.public_subnets
  eks1_cluster_name = var.eks1_cluster_name
  eks2_cluster_name = var.eks2_cluster_name
  eip_count         = var.eip_count

}
