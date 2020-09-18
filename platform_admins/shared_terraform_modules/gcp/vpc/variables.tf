# Subnets
variable "subnets" {
  type = list(object({
    subnet_name   = string
    subnet_ip     = string
    subnet_region = string
    secondary_ranges = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
  }))
}

# VPC
variable "network_name" {
  type = string
}

# Project
variable "project_id" {
  type = string
}
