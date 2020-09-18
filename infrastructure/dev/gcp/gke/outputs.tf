output "gke_dev_1_name" { value = "${module.gke_dev_1.name}" }
output "gke_dev_1_location" { value = "${module.gke_dev_1.location}" }
output "gke_dev_1_endpoint" { value = "${module.gke_dev_1.endpoint}" }

output "gke_dev_2_name" { value = "${module.gke_dev_2.name}" }
output "gke_dev_2_location" { value = "${module.gke_dev_2.location}" }
output "gke_dev_2_endpoint" { value = "${module.gke_dev_2.endpoint}" }

output "gke_list" { value = ["${module.gke_dev_1.name}", "${module.gke_dev_2.name}"] }
output "gke_location_list" { value = ["${module.gke_dev_1.location}", "${module.gke_dev_2.location}"] }

output "clusters" {
  value = {
    "${module.gke_dev_1.name}" = {
      name     = "${module.gke_dev_1.name}"
      location = "${module.gke_dev_1.location}"
      endpoint = "${module.gke_dev_1.endpoint}"
      asm_dir  = "${module.gke_dev_1.name}"
      regional = false
    }
    "${module.gke_dev_2.name}" = {
      name     = "${module.gke_dev_2.name}"
      location = "${module.gke_dev_2.location}"
      endpoint = "${module.gke_dev_2.endpoint}"
      asm_dir  = "${module.gke_dev_2.name}"
      regional = false
    }
  }
}
