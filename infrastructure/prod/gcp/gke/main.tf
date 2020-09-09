# GKE Prod 1
module "gke_prod_1" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/gke/"
    subnet = data.terraform_remote_state.prod_gcp_vpc.outputs.subnets["${var.gke1_subnet_name}"]
    suffix = var.gke1_suffix
    zone = var.gke1_zone
    env = var.env
    acm_ssh_auth_key = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
    acm_sync_repo = data.terraform_remote_state.prod_gcp_repos.outputs.acm_repo_ssh_url
}

module "gke_prod_2" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/gke/"
    subnet = data.terraform_remote_state.prod_gcp_vpc.outputs.subnets["${var.gke2_subnet_name}"]
    suffix = var.gke2_suffix
    zone = var.gke2_zone
    env = var.env
    acm_ssh_auth_key = data.terraform_remote_state.prod_gcp_ssh_key.outputs.private_key
    acm_sync_repo = data.terraform_remote_state.prod_gcp_repos.outputs.acm_repo_ssh_url
}
