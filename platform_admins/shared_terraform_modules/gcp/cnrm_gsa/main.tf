# Create a cnrm gsa
resource "google_service_account" "cnrm_sa" {
  account_id   = var.account_id
  display_name = "CNRM SA"
  project      = var.project_id
}

# IAM binding to grant cnrm sa owner
resource "google_project_iam_member" "cnrm_sa_iam_owner" {
  project = var.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.cnrm_sa.email}"
}

resource "google_service_account_key" "cnrm_sa_key" {
  service_account_id = google_service_account.cnrm_sa.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "local_file" "cnrm_sa_key_file" {
  content  = base64decode(google_service_account_key.cnrm_sa_key.private_key)
  filename = "cnrm_sa_key.json"
}

resource "google_storage_bucket_object" "cnrm_sa_key_file_object" {
  name   = "cnrmgsa/cnrm_sa_key.json"
  source = "cnrm_sa_key.json"
  bucket = var.project_id
  depends_on = [
    local_file.cnrm_sa_key_file
  ]
}
