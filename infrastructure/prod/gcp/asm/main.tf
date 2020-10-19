module "asm-prod" {
  source              = "../../../../platform_admins/shared_terraform_modules/gcp/asm/"
  project_id          = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
  gke_net             = var.gke_net
  asm_version         = var.asm_version
  env                 = var.env
  gke_list            = join(",", "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_list}")
  gke_location_list   = join(",", "${data.terraform_remote_state.prod_gcp_gke.outputs.gke_location_list}")
  eks_list            = join(",", "${data.terraform_remote_state.prod_aws_eks.outputs.eks_list}")
  eks_eip_list        = join(",", "${data.terraform_remote_state.prod_aws_vpc.outputs.eip_ids}")
  eks_ingress_ip_list = join(",", "${data.terraform_remote_state.prod_aws_vpc.outputs.eip_public_ips}")
}
