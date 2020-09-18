output "gke_location_list" {
  value = [
    #[START:gke_dev_1]
    "${module.gke_dev_1.location}",
    #[END:gke_dev_1]
    #[START:gke_dev_2]
    "${module.gke_dev_2.location}"
    #[END:gke_dev_2]
    ###MARKER###
  ]
}
