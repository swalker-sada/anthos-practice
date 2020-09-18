output "clusters" {
  value = {
    #[START:gke_dev_1]
    "${module.gke_dev_1.name}" = {
      name     = "${module.gke_dev_1.name}"
      location = "${module.gke_dev_1.location}"
      endpoint = "${module.gke_dev_1.endpoint}"
      asm_dir  = "${module.gke_dev_1.name}"
      regional = false
    }
    #[END:gke_dev_1]
    #[START:gke_dev_2]
    "${module.gke_dev_2.name}" = {
      name     = "${module.gke_dev_2.name}"
      location = "${module.gke_dev_2.location}"
      endpoint = "${module.gke_dev_2.endpoint}"
      asm_dir  = "${module.gke_dev_2.name}"
      regional = false
    }
    #[END:gke_dev_2]
  }
}
