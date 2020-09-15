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

locals {
    project_id               = var.project_id
    regional_string  = join(",", [for cluster in var.clusters : cluster.regional])
    clusters_string = join(",", [for cluster in var.clusters : cluster.name])
    locations_string = join(",", [for cluster in var.clusters : cluster.location])
}

resource "null_resource" "asm-gke" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/scripts/install_asm.sh"
    environment = {
      PROJECT_ID       = local.project_id
      REGIONAL_STRING  = local.regional_string
      CLUSTERS_STRING  = local.clusters_string
      LOCATIONS_STRING = local.locations_string
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/remove_asm.sh"
    environment = {
      PROJECT_ID       = self.triggers.project_id
      REGIONAL_STRING  = self.triggers.regional_string
      CLUSTERS_STRING  = self.triggers.clusters_string
      LOCATIONS_STRING = self.triggers.locations_string
    }
  }

  triggers = {
    script_sha1 = sha1(file("${path.module}/scripts/install_asm.sh")),
    script_sha2 = sha1(file("${path.module}/scripts/remove_asm.sh")),
    project_id = local.project_id,
    regional_string  = local.regional_string
    clusters_string = local.clusters_string
    locations_string = local.locations_string
  }
}

resource "null_resource" "create_secrets_cross_discovery" {
  depends_on = [
    null_resource.asm-gke
  ]

  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/scripts/create_secrets.sh"
    environment = {
      PROJECT_ID       = local.project_id
      REGIONAL_STRING  = local.regional_string
      CLUSTERS_STRING = local.clusters_string
      LOCATIONS_STRING = local.locations_string
    }
  }

  triggers = {
    script_sha1 = sha1(file("${path.module}/scripts/create_secrets.sh")),
  }
}
