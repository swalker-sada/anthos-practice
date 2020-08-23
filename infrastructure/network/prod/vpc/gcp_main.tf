# Create VPC
module "gcp_vpc" {
    source  = "terraform-google-modules/network/google"

    project_id   = var.project_id
    network_name = var.vpc_name
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = var.subnet_01_name
            subnet_ip             = var.subnet_01_ip
            subnet_region         = var.subnet_01_region
        },
        {
            subnet_name           = var.subnet_02_name
            subnet_ip             = var.subnet_02_ip
            subnet_region         = var.subnet_02_region
        },
    ]

    secondary_ranges = {
      "${var.subnet_01_name}" = [
      {
        range_name    = var.subnet_01_secondary_svc_1_name
        ip_cidr_range = var.subnet_01_secondary_svc_1_range
      },
      {
        range_name    = var.subnet_01_secondary_svc_2_name
        ip_cidr_range = var.subnet_01_secondary_svc_2_range
      },
      {
        range_name    = var.subnet_01_secondary_pod_name
        ip_cidr_range = var.subnet_01_secondary_pod_range
      },
    ]
    "${var.subnet_02_name}" = [
      {
        range_name    = var.subnet_02_secondary_svc_1_name
        ip_cidr_range = var.subnet_02_secondary_svc_1_range
      },
      {
        range_name    = var.subnet_02_secondary_svc_2_name
        ip_cidr_range = var.subnet_02_secondary_svc_2_range
      },
      {
        range_name    = var.subnet_02_secondary_pod_name
        ip_cidr_range = var.subnet_02_secondary_pod_range
      },
    ]
    }
}

# create firewall rules to allow-all inernally and SSH from external
module "net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = var.project_id
  network                 = module.gcp_vpc.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/8"]
  internal_allow = [
    { "protocol" : "all" },
  ]
}
