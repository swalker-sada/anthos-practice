output "gclb-ip-address" {
  value = google_compute_global_address.boa.address
}

output "gke_prod_1_name" {
  value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_name
}

output "gke_prod_1_location" {
  value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_location
}

output "gke_prod_2_name" {
  value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_name
}

output "gke_prod_2_location" {
  value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_location
}