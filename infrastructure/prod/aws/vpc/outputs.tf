output "id" { value = "${module.prod_vpc.id}" }
output "name" { value = "${module.prod_vpc.name}" }
output "private_subnets" { value = "${module.prod_vpc.private_subnets}" }
output "public_subnets" { value = "${module.prod_vpc.public_subnets}" }
output "eip_ids" { value = "${module.prod_vpc.eip_ids}" }
output "eip_public_ips" { value = "${module.prod_vpc.eip_public_ips}" }

