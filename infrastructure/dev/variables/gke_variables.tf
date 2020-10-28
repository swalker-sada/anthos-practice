variable "gke1_subnet_name" {
  type    = string
  default = "us-west1/dev-gcp-vpc-01-us-west1-subnet-01"
}

variable "gke1_region" {
  type    = string
  default = "us-west1"
}

variable "gke1_suffix" {
  type    = number
  default = 1
}

variable "gke1_zone" {
  type    = string
  default = "b"
}

variable "gke2_suffix" {
  type    = number
  default = 2
}

variable "gke2_zone" {
  type    = string
  default = "c"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "config-repo" {
  type = string
  default = "config"
}
