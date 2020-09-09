module "eks-prod-1" {
    source = "../../../../platform_admins/shared_terraform_modules/aws/eks/"
    eks_cluster_name = var.eks1_cluster_name
    vpc_id = data.terraform_remote_state.prod_aws_vpc.outputs.id
    private_subnets = data.terraform_remote_state.prod_aws_vpc.outputs.private_subnets
    project_id = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
    env = var.env
    repo_url = data.terraform_remote_state.prod_gcp_repos.outputs.acm_repo_ssh_url
}

module "eks-prod-2" {
    source = "../../../../platform_admins/shared_terraform_modules/aws/eks/"
    eks_cluster_name = var.eks2_cluster_name
    vpc_id = data.terraform_remote_state.prod_aws_vpc.outputs.id
    private_subnets = data.terraform_remote_state.prod_aws_vpc.outputs.private_subnets
    project_id = data.terraform_remote_state.prod_gcp_vpc.outputs.project_id
    env = var.env
    repo_url = data.terraform_remote_state.prod_gcp_repos.outputs.acm_repo_ssh_url
}