module "gke-gitlab" {
  source  = "terraform-google-modules/gke-gitlab/google"

  project_id            = data.terraform_remote_state.vpc.outputs.project_id
  domain                = "${trimprefix(module.cloud-endpoints-dns-gitlab.endpoint_computed, "gitlab.")}"
  certmanager_email     = "no-reply@${data.terraform_remote_state.vpc.outputs.project_id}.example.com"
  gitlab_runner_install = true
  gitlab_address_name   = google_compute_address.gitlab.name
  gitlab_db_name        = "gitlab-${lower(random_id.database_id.hex)}"
  helm_chart_version    = "4.0.7"
  gke_version           = "1.15"
}

module "cloud-endpoints-dns-gitlab" {
  source  = "terraform-google-modules/endpoints-dns/google"
  version = "~> 2.0.1"

  project     = data.terraform_remote_state.vpc.outputs.project_id
  name        = "gitlab"
  external_ip = google_compute_address.gitlab.address
}

module "cloud-endpoints-dns-registry" {
  source  = "terraform-google-modules/endpoints-dns/google"
  version = "~> 2.0.1"

  project     = data.terraform_remote_state.vpc.outputs.project_id
  name        = "registry"
  external_ip = google_compute_address.gitlab.address
}

resource "google_compute_address" "gitlab" {
  project = data.terraform_remote_state.vpc.outputs.project_id
  region  = "us-central1"
  name    = "gitlab"
}

resource "random_id" "database_id" {
  byte_length = 8
}
