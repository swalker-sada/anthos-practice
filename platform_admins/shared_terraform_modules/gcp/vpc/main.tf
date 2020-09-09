module "vpc" {
    source  = "terraform-google-modules/network/google"

    project_id   = var.project_id
    network_name = var.network_name
    routing_mode = "GLOBAL"

    subnets = [
        for subnet in var.subnets: {
                subnet_name           = subnet.subnet_name
                subnet_ip             = subnet.subnet_ip
                subnet_region         = subnet.subnet_region
            }
        ]

    secondary_ranges = {
        for subnet in var.subnets : 
            subnet.subnet_name => subnet.secondary_ranges 
    }
}
