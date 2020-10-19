variable "project_id" {
  type = string
}

variable "account_id" {
  type = string
}

# gke_list is a comma separated string that gets re-formatted  in the bash script
variable "gke_list" {
  type = string
}

# gke_location_list is a comma separated string that gets re-formatted  in the bash script
variable "gke_location_list" {
  type = string
}
