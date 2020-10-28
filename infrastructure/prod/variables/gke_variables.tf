#START:gke1
variable "gke1_subnet_name" {
  type    = string
  default = "us-west4/prod-gcp-vpc-01-us-west4-subnet-01"
}

variable "gke1_region" {
  type    = string
  default = "us-west4"
}

variable "gke1_suffix" {
  type    = number
  default = 1
}

variable "gke1_zone" {
  type    = string
  default = "b"
}
#END:gke1

#START:gke2
variable "gke2_subnet_name" {
  type    = string
  default = "us-west4/prod-gcp-vpc-01-us-west4-subnet-01"
}
variable "gke2_region" {
  type    = string
  default = "us-west4"
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
  default = "prod"
}
#END:gke2

variable "config-repo" {
  type = string
  default = "config"
}
