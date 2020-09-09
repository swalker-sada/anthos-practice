output "network" { value = module.prod_gcp_vpc_01.network }
output "project_id" { value = module.prod_gcp_vpc_01.project_id }
output "network_name" { value = module.prod_gcp_vpc_01.network_name }
output "subnets" { value = module.prod_gcp_vpc_01.subnets }
output "subnets_ips" { value = module.prod_gcp_vpc_01.subnets_ips }
output "subnets_names" { value = module.prod_gcp_vpc_01.subnets_names }
output "subnets_regions" { value = module.prod_gcp_vpc_01.subnets_regions }
output "subnets_secondary_ranges" { value = module.prod_gcp_vpc_01.subnets_secondary_ranges }
