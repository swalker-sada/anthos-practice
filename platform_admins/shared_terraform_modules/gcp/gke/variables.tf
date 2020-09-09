variable "subnet" {
    type = object({
        creation_timestamp = string
        description = string
        gateway_address = string
        id = string
        ip_cidr_range = string
        name = string
        network = string
        private_ip_google_access = string
        project = string
        region = string
        secondary_ip_range = list(object({
            ip_cidr_range = string
            range_name = string
        }))
        self_link = string
    })
}

variable "suffix" {
    type = number
}

variable "env" {
    type = string
}

variable "zone" {
    type = string
}

variable "acm_ssh_auth_key" {}
variable "acm_sync_repo" {}
