output "gke_prod_1_name" { value = "${module.gke_prod_1.name}" }
output "gke_prod_1_location" { value = "${module.gke_prod_1.location}" }
output "gke_prod_1_endpoint" { value = "${module.gke_prod_1.endpoint}" }

output "gke_prod_2_name" { value = "${module.gke_prod_2.name}" }
output "gke_prod_2_location" { value = "${module.gke_prod_2.location}" }
output "gke_prod_2_endpoint" { value = "${module.gke_prod_2.endpoint}" }

output "gke_list" { value = ["${module.gke_prod_1.name}", "${module.gke_prod_2.name}"] }
output "gke_location_list" { value = ["${module.gke_prod_1.location}", "${module.gke_prod_2.location}"] }
