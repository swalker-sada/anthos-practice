# Create an ACM repo
resource "google_sourcerepo_repository" "acm_repo" {
  name    = var.acm_repo
  project = data.terraform_remote_state.vpc.outputs.project_id
}

module "gke1_acm" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  project_id       = data.terraform_remote_state.vpc.outputs.project_id
  cluster_name     = data.terraform_remote_state.gke.outputs.gke1_name
  location         = data.terraform_remote_state.gke.outputs.gke1_location
  cluster_endpoint = data.terraform_remote_state.gke.outputs.gke1_endpoint
  ssh_auth_key     = file("csr-key")
  create_ssh_key   = false
  sync_repo        = "ssh://${var.user}@source.developers.google.com:2022/p/${data.terraform_remote_state.vpc.outputs.project_id}/r/${google_sourcerepo_repository.acm_repo.name}"
}

module "gke2_acm" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/acm"
  project_id       = data.terraform_remote_state.vpc.outputs.project_id
  cluster_name     = data.terraform_remote_state.gke.outputs.gke2_name
  location         = data.terraform_remote_state.gke.outputs.gke2_location
  cluster_endpoint = data.terraform_remote_state.gke.outputs.gke2_endpoint
  ssh_auth_key     = file("csr-key")
  create_ssh_key   = false
  sync_repo        = "ssh://${var.user}@source.developers.google.com:2022/p/${data.terraform_remote_state.vpc.outputs.project_id}/r/${google_sourcerepo_repository.acm_repo.name}"
}
