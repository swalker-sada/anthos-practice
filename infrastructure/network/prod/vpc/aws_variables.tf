variable "aws_vpc_name" { default = "aws-vpc" }
variable "aws_vpc_cidr" { default = "10.100.0.0/16" }
variable "aws_private_subnets" { default = [
    "10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"
] }
variable "aws_public_subnets" { default = [
    "10.100.4.0/24", "10.100.5.0/24", "10.100.6.0/24"
] }
