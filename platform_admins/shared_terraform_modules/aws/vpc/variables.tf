variable "name" {}
variable "cidr" {}
variable "azs" {}

# EKS requires minimum two AZs and 2 subnets
# https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
variable "private_subnets" {}
variable "public_subnets" {}

variable "eks1_cluster_name" {}
variable "eks2_cluster_name" {}

variable "eip_count" {}
