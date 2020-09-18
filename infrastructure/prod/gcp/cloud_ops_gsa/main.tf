module "cloud_ops_gsa" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/cloud_ops_gsa/"
    project_id = var.project_id
    account_id = var.account_id
}
