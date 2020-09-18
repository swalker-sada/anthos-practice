#[START:gke_prod_1]
output "gke_prod_1_name" { value = "${module.gke_prod_1.name}" }
output "gke_prod_1_location" { value = "${module.gke_prod_1.location}" }
output "gke_prod_1_endpoint" { value = "${module.gke_prod_1.endpoint}" }
#[END:gke_prod_1]

#[START:gke_prod_2]
output "gke_prod_2_name" { value = "${module.gke_prod_2.name}" }
output "gke_prod_2_location" { value = "${module.gke_prod_2.location}" }
output "gke_prod_2_endpoint" { value = "${module.gke_prod_2.endpoint}" }
#[END:gke_prod_2]

output "gke_list" {
  value = [
    #[START:gke_prod_1]
    "${module.gke_prod_1.name}",
    #[END:gke_prod_1]
    #[START:gke_prod_2]
    "${module.gke_prod_2.name}",
    #[END:gke_prod_2]
  ]
}

output "gke_location_list" {
  value = [
    #[START:gke_prod_1]
    "${module.gke_prod_1.location}",
    #[END:gke_prod_1]
    #[START:gke_prod_2]
    "${module.gke_prod_2.location}",
    #[END:gke_prod_2]
  ]
}

###MARKER###
