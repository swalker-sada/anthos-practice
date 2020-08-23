output "aws_vpc_id" { value = "${module.aws_vpc.vpc_id}" }
output "aws_vpc_name" { value = "${module.aws_vpc.name}" }
output "aws_vpc_private_subnets" { value = "${module.aws_vpc.private_subnets}" }
output "aws_vpc_public_subnets" { value = "${module.aws_vpc.public_subnets}" }
