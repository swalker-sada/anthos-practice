module "asm-prod"  {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/asm/"
    project_id = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
    gke_net = var.gke_net
    asm_version = var.asm_version
    gke_list = "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_name},${data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_name}"
    gke_location_list = "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_location},${data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_location}"
    eks_list = "${data.terraform_remote_state.prod_aws_eks.outputs.eks1_cluster_id},${data.terraform_remote_state.prod_aws_eks.outputs.eks2_cluster_id}"
    eks_eip_list = join(",","${data.terraform_remote_state.prod_aws_vpc.outputs.eip_ids}")
    eks_ingress_ip_list = join(",","${data.terraform_remote_state.prod_aws_vpc.outputs.eip_public_ips}")
}
