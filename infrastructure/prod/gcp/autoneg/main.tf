module "autoneg" {
  source = "../../../../platform_admins/shared_terraform_modules/gcp/autoneg/"
  account_id = var.account_id
  project_id = var.project_id
  gke_list            = join(",", "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_list}")
  gke_location_list   = join(",", "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_location_list}")
}
