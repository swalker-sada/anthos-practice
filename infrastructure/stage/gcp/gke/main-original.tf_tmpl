# GKE Stage 1
module "gke_stage_1" {
  source             = "../../../../platform_admins/shared_terraform_modules/gcp/gke/"
  subnet             = data.terraform_remote_state.stage_gcp_vpc.outputs.subnets["${var.gke1_subnet_name}"]
  suffix             = var.gke1_suffix
  zone               = var.gke1_zone
  env                = var.env
  acm_ssh_auth_key   = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
  acm_sync_repo      = "git@gitlab.endpoints.${data.terraform_remote_state.stage_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/${var.config-repo}.git"
  hub_sa_private_key = data.terraform_remote_state.prod_gcp_hub_gsa.outputs.private_key
}
