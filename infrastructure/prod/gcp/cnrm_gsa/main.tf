module "cnrm_gsa" {
  source     = "../../../../platform_admins/shared_terraform_modules/gcp/cnrm_gsa/"
  project_id = var.project_id
  account_id = var.account_id
}
