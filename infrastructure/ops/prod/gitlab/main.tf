module "gke-gitlab" {
  source  = "terraform-google-modules/gke-gitlab/google"

  project_id            = var.project_id
  domain                = "${trimprefix(module.cloud-endpoints-dns-gitlab.endpoint_computed, "gitlab.")}"
  certmanager_email     = "no-reply@${var.project_id}.example.com"
  gitlab_runner_install = true
  gitlab_address_name   = google_compute_address.gitlab.name
  gitlab_db_name        = "gitlab-${lower(random_id.database_id.hex)}"
  helm_chart_version    = "4.2.4"
  gke_version           = "1.16"
}

module "cloud-endpoints-dns-gitlab" {
  source  = "terraform-google-modules/endpoints-dns/google"
  version = "~> 2.0.1"

  project     = var.project_id
  name        = "gitlab"
  external_ip = google_compute_address.gitlab.address
}

module "cloud-endpoints-dns-registry" {
  source  = "terraform-google-modules/endpoints-dns/google"
  version = "~> 2.0.1"

  project     = var.project_id
  name        = "registry"
  external_ip = google_compute_address.gitlab.address
}

resource "google_compute_address" "gitlab" {
  project = var.project_id
  region  = "us-central1"
  name    = "gitlab"
}

resource "random_id" "database_id" {
  byte_length = 8
}

resource "null_resource" "exec_gitlab_creds" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/gitlab_creds.sh"
    environment = {
      PROJECT_ID = var.project_id
      GITLAB_HOSTNAME = module.cloud-endpoints-dns-gitlab.endpoint_computed
    }
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.gke-gitlab]
}
