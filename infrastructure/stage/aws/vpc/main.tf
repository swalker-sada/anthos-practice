module "stage_vpc" {
  source  = "../../../../platform_admins/shared_terraform_modules/aws/vpc/"

  name                 = var.name
  cidr                 = var.cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  eks1_cluster_name    = var.eks1_cluster_name
  eks2_cluster_name    = var.eks2_cluster_name
  eip_count            = var.eip_count

}
