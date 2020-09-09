module "asm-stage"  {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/asm/"
    project_id = data.terraform_remote_state.stage_gcp_vpc.outputs.project_id
    gke_net = var.gke_net
    asm_version = var.asm_version
    gke_list = "${data.terraform_remote_state.stage_gcp_gke.outputs.gke_stage_1_name}"
    gke_location_list = "${data.terraform_remote_state.stage_gcp_gke.outputs.gke_stage_1_location}"
    eks_list = "${data.terraform_remote_state.stage_aws_eks.outputs.eks1_cluster_id}"
    eks_eip_list = join(",","${data.terraform_remote_state.stage_aws_vpc.outputs.eip_ids}")
    eks_ingress_ip_list = join(",","${data.terraform_remote_state.stage_aws_vpc.outputs.eip_public_ips}")
}
