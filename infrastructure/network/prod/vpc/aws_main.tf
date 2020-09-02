data "aws_availability_zones" "available" {
}

module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  # version = "2.6.0"

  name                 = var.aws_vpc_name
  cidr                 = var.aws_vpc_cidr
  azs                  = var.azs
  # azs                  = data.aws_availability_zones.available.names
  private_subnets      = var.aws_private_subnets
  public_subnets       = var.aws_public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks1_cluster_name}" = "shared"
    "kubernetes.io/cluster/${var.eks2_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks1_cluster_name}" = "shared"
    "kubernetes.io/cluster/${var.eks2_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

resource "aws_eip" "asm-ingress" {
  count = 4
  vpc = true
}

