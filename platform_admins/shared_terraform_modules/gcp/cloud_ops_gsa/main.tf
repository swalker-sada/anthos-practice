# Create a Cloud Ops SA to be able to register attached clusters
resource "google_service_account" "cloud_ops_sa" {
  account_id   = var.account_id
  display_name = "Cloud Ops SA"
  project      = var.project_id
}

# IAM binding to grant cloud ops service account log writing.
resource "google_project_iam_member" "cloud_ops_sa_logwriter" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_ops_sa.email}"
}

# IAM binding to grant cloud ops service account metric writing.
resource "google_project_iam_member" "cloud_ops_sa_metricwriter" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_ops_sa.email}"
}

# IAM binding to grant cloud ops service account monitoring viewer.
resource "google_project_iam_member" "cloud_ops_sa_monitoringviewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.cloud_ops_sa.email}"
}

resource "google_service_account_key" "cloud_ops_sa_key" {
  service_account_id = google_service_account.cloud_ops_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "cloud_ops_sa_key_file" {
  content  = base64decode(google_service_account_key.cloud_ops_sa_key.private_key)
  filename = "cloud_ops_sa_key.json"
}

resource "google_storage_bucket_object" "cloud_ops_sa_key_file_object" {
  name   = "cloudopsgsa/cloud_ops_sa_key.json"
  source = "cloud_ops_sa_key.json"
  bucket = var.project_id
  depends_on = [
    local_file.cloud_ops_sa_key_file
  ]
}
