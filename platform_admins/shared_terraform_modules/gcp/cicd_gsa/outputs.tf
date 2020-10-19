output "private_key_base64" {
  value = google_service_account_key.cicd_sa_key.private_key 
}
