output "gke_dev_1_name" { value = "${module.gke_dev_1.name}" }
output "gke_dev_1_location" { value = "${module.gke_dev_1.location}" }
output "gke_dev_1_endpoint" { value = "${module.gke_dev_1.endpoint}" }

output "gke_dev_2_name" { value = "${module.gke_dev_2.name}" }
output "gke_dev_2_location" { value = "${module.gke_dev_2.location}" }
output "gke_dev_2_endpoint" { value = "${module.gke_dev_2.endpoint}" }

output "gke_list" { value = ["${module.gke_dev_1.name}","${module.gke_dev_2.name}"] }
output "gke_location_list" { value = ["${module.gke_dev_1.location}","${module.gke_dev_2.location}"] }
