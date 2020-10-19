module "eks-stage-1" {
  source           = "../../../../platform_admins/shared_terraform_modules/aws/eks/"
  eks_cluster_name = var.eks1_cluster_name
  vpc_id           = data.terraform_remote_state.stage_aws_vpc.outputs.id
  private_subnets  = data.terraform_remote_state.stage_aws_vpc.outputs.private_subnets
  project_id       = data.terraform_remote_state.stage_gcp_vpc.outputs.project_id
  env              = var.env
  repo_url         = "git@gitlab.endpoints.${data.terraform_remote_state.stage_gcp_vpc.outputs.project_id}.cloud.goog:platform-admins/${var.config-repo}.git"
}
