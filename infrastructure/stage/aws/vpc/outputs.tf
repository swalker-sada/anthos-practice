output "id" { value = "${module.stage_vpc.id}" }
output "name" { value = "${module.stage_vpc.name}" }
output "private_subnets" { value = "${module.stage_vpc.private_subnets}" }
output "public_subnets" { value = "${module.stage_vpc.public_subnets}" }
output "eip_ids" { value = "${module.stage_vpc.eip_ids}" }
output "eip_public_ips" { value = "${module.stage_vpc.eip_public_ips}" }

