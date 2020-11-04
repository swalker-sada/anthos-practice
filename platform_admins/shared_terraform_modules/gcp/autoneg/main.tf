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

# Create a autoneg SA to be able to dynamically set NEGs as backends to GCLB backend services
resource "google_service_account" "autoneg_sa" {
  account_id   = var.account_id
  display_name = "Autogen SA"
  project      = var.project_id
}

resource "google_service_account_iam_binding" "autoneg-sa-workload-identity" {
  service_account_id = google_service_account.autoneg_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[autoneg-system/default]",
  ]
}

# Create a custom role for autoneg SA
resource "google_project_iam_custom_role" "autoneg-custom-iam-role" {
  role_id     = "autoneg"
  project    = var.project_id
  title       = "Autoneg Custom Role"
  permissions = ["compute.backendServices.get", "compute.backendServices.update", "compute.networkEndpointGroups.use", "compute.healthChecks.useReadOnly"]
}

# IAM binding to grant autoneg sa custom role `autoneg`
resource "google_project_iam_member" "autoneg-custom-iam-role" {
  project = var.project_id
  role    = google_project_iam_custom_role.autoneg-custom-iam-role.name
  member  = "serviceAccount:${google_service_account.autoneg_sa.email}"
}

resource "null_resource" "autoneg" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/install_autoneg.sh"
    environment = {
      PROJECT_ID       = var.project_id
      GKE_LIST_STRING  = var.gke_list
      GKE_LOC_STRING   = var.gke_location_list
      # GKE_NAME         = var.gke_name
      # GKE_LOC          = var.gke_location
      AUTONEG_SA       = var.account_id
    }
  }

  triggers = {
    script_sha1      = sha1(file("${path.module}/install_autoneg.sh")),
  }
  depends_on = [
    google_project_iam_member.autoneg-custom-iam-role,
    google_service_account_iam_binding.autoneg-sa-workload-identity
  ]
}
