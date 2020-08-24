provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks1_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks1_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks1_cluster.token
  load_config_file       = false
  version                = "~> 1.11"
  alias                  = "eks1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks2_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks2_cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks2_cluster.token
  load_config_file       = false
  version                = "~> 1.11"
  alias                  = "eks2"
}

data "aws_eks_cluster" "eks1_cluster" {
  name = module.eks1.cluster_id
}

data "aws_eks_cluster_auth" "eks1_cluster" {
  name = module.eks1.cluster_id
}

data "aws_eks_cluster" "eks2_cluster" {
  name = module.eks2.cluster_id
}

data "aws_eks_cluster_auth" "eks2_cluster" {
  name = module.eks2.cluster_id
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = data.terraform_remote_state.vpc.outputs.aws_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = data.terraform_remote_state.vpc.outputs.aws_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "192.168.0.0/16",
    ]
  }
}

resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = data.terraform_remote_state.vpc.outputs.aws_vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "eks1" {
  source          = "terraform-aws-modules/eks/aws"
  providers        = { kubernetes = kubernetes.eks1 }
  cluster_name    = var.eks1_cluster_name
  cluster_version = "1.17"
  subnets         = data.terraform_remote_state.vpc.outputs.aws_vpc_private_subnets

  tags = {
    Environment = "prod"
  }

  vpc_id = data.terraform_remote_state.vpc.outputs.aws_vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.2xlarge"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 3
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}

module "eks2" {
  source          = "terraform-aws-modules/eks/aws"
  providers        = { kubernetes = kubernetes.eks2 }
  cluster_name    = var.eks2_cluster_name
  cluster_version = "1.17"
  subnets         = data.terraform_remote_state.vpc.outputs.aws_vpc_private_subnets

  tags = {
    Environment = "prod"
  }

  vpc_id = data.terraform_remote_state.vpc.outputs.aws_vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t3.2xlarge"
      additional_userdata           = "echo foo bar"
      asg_desired_capacity          = 3
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  map_roles                            = var.map_roles
  map_users                            = var.map_users
  map_accounts                         = var.map_accounts
}

resource "null_resource" "exec_eks_kubeconfig" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/eks_kubeconfig.sh"
    environment = {
      PROJECT_ID         = data.terraform_remote_state.vpc.outputs.project_id
    }
  }

  triggers = {
    script_sha1          = sha1(file("eks_kubeconfig.sh"))
  }
  depends_on = [
    module.eks1,
    module.eks2,
  ]
}

