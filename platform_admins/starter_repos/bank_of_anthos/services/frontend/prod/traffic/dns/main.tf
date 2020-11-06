# Static IP for ingress
resource "google_compute_global_address" "boa" {
  project = var.project_id
  name    = var.name
}

# Cloud endpoints for DNS
module "boa-cloud-endpoints-dns" {
  source      = "terraform-google-modules/endpoints-dns/google"
  project     = var.project_id
  name        = var.name
  external_ip = google_compute_global_address.boa.address
}

# Managed certificate
resource "google_compute_managed_ssl_certificate" "boa-managed-cert" {
  provider = google-beta
  project  = var.project_id

  name = "${var.name}-managed-ssl-cert"

  managed {
    domains = ["${module.boa-cloud-endpoints-dns.endpoint}."]
  }
}