#START:gke1
variable "gke1_subnet_name" {
  type    = string
  default = "us-west2/prod-gcp-vpc-01-us-west2-subnet-01"
}

variable "gke1_region" {
  type    = string
  default = "us-west2"
}

variable "gke1_suffix" {
  type    = number
  default = 1
}

variable "gke1_zone" {
  type    = string
  default = "a"
}
#END:gke1

#START:gke2
variable "gke2_subnet_name" {
  type    = string
  default = "us-west2/prod-gcp-vpc-01-us-west2-subnet-01"
}
variable "gke2_region" {
  type    = string
  default = "us-west2"
}

variable "gke2_suffix" {
  type    = number
  default = 2
}

variable "gke2_zone" {
  type    = string
  default = "b"
}

variable "env" {
  type    = string
  default = "prod"
}
#END:gke2
