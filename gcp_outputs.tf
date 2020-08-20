# VPC
output "project_id" { value = "${module.vpc.project_id}" }
output "subnets_self_links" { value = "${module.vpc.subnets_self_links}" }
output "subnets_names" { value = "${module.vpc.subnets_names}" }
output "network_name" { value = "${module.vpc.network_name}" }
output "network_self_link" { value = "${module.vpc.network_self_link}" }

# GKE
output "gke1_name" { value = "${module.gke1.name}" }
output "gke1_location" { value = "${module.gke1.location}" }

output "gke1_endpoint" {
  sensitive = true
  value     = module.gke1.endpoint
}

output "client_token" {
  sensitive = true
  value     = base64encode(data.google_client_config.default.access_token)
}

output "gke1_ca_certificate" {
  value = module.gke1.ca_certificate
}

output "gke1_service_account" {
  description = "The default service account used for running nodes."
  value       = module.gke1.service_account
}
