output "gke_list" {
  value = [
    #[START:gke_dev_1]
    "${module.gke_dev_1.name}",
    #[END:gke_dev_1]
    #[START:gke_dev_2]
    "${module.gke_dev_2.name}"
    #[END:gke_dev_2]
    ###MARKER###
  ]
}
