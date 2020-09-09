module "hub_gsa" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/hub_gsa/"
    project_id = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
    account_id = var.account_id
}
