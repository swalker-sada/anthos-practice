output "gke_stage_1_name" { value = "${module.gke_stage_1.name}" }
output "gke_stage_1_location" { value = "${module.gke_stage_1.location}" }
output "gke_stage_1_endpoint" { value = "${module.gke_stage_1.endpoint}" }

output "gke_list" { value = ["${module.gke_stage_1.name}"] }
output "gke_location_list" { value = ["${module.gke_stage_1.location}"] }
