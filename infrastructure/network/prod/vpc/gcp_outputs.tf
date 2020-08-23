# VPC
output "project_id" { value = "${module.gcp_vpc.project_id}" }
output "subnets_self_links" { value = "${module.gcp_vpc.subnets_self_links}" }
output "subnets_names" { value = "${module.gcp_vpc.subnets_names}" }
output "network_name" { value = "${module.gcp_vpc.network_name}" }
output "network_self_link" { value = "${module.gcp_vpc.network_self_link}" }
