module "kcc" {
  source = "../../../../platform_admins/shared_terraform_modules/gcp/kcc/"
  project_id = var.project_id
  gke_name = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_name
  gke_location = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_location
}
