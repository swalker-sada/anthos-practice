output "id" { value = "${module.vpc.vpc_id}" }
output "name" { value = "${module.vpc.name}" }
output "private_subnets" { value = "${module.vpc.private_subnets}" }
output "public_subnets" { value = "${module.vpc.public_subnets}" }
output "eip_ids" { value = "${aws_eip.asm-ingress.*.id}" }
output "eip_public_ips" { value = "${aws_eip.asm-ingress.*.public_ip}" }

