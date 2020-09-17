module "mci-dev"  {
    source        = "../../../../platform_admins/shared_terraform_modules/gcp/mci/"
    project_id    = data.terraform_remote_state.dev_gcp_vpc.outputs.project_id
    cluster_name  = data.terraform_remote_state.dev_gcp_gke.outputs.gke_dev_1_name
}