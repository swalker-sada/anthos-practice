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

# Create a CICD SA
resource "google_service_account" "cicd_sa" {
  account_id   = var.account_id
  display_name = "CICD SA"
  project      = var.project_id
}

# IAM binding to grant cicd sa owner
resource "google_project_iam_member" "cicd_sa_iam_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.cicd_sa.email}"
}

resource "google_service_account_key" "cicd_sa_key" {
  service_account_id = google_service_account.cicd_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "cicd_sa_key_file" {
  content  = base64decode(google_service_account_key.cicd_sa_key.private_key)
  filename = "cicd_sa_key.json"
}

resource "google_storage_bucket_object" "cicd_sa_key_file_object" {
  name   = "cicdgsa/cicd_sa_key.json"
  source = "cicd_sa_key.json"
  bucket = var.project_id
  depends_on = [
    local_file.cicd_sa_key_file
  ]
}
