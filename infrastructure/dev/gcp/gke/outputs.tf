#[START:gke_dev_1]
output "gke_dev_1_name" { value = "${module.gke_dev_1.name}" }
output "gke_dev_1_location" { value = "${module.gke_dev_1.location}" }
output "gke_dev_1_endpoint" { value = "${module.gke_dev_1.endpoint}" }
#[END:gke_dev_1]

#[START:gke_dev_2]
output "gke_dev_2_name" { value = "${module.gke_dev_2.name}" }
output "gke_dev_2_location" { value = "${module.gke_dev_2.location}" }
output "gke_dev_2_endpoint" { value = "${module.gke_dev_2.endpoint}" }
#[END:gke_dev_2]

###MARKER###


