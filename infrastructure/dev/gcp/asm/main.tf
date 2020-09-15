module "dev-asm" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/asm-gke/"
    project_id = data.terraform_remote_state.dev_gcp_vpc.outputs.project_id
    clusters = data.terraform_remote_state.dev_gcp_gke.outputs.clusters
}
