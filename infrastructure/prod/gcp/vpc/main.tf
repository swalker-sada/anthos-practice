module "prod_gcp_vpc_01" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/vpc/"
    project_id   = var.project_id
    network_name = var.network_name
    subnets = var.subnets
}

# create firewall rules to allow-all inernally and SSH from external
module "prod-net-firewall" {
  source                  = "terraform-google-modules/network/google//modules/fabric-net-firewall"
  project_id              = module.prod_gcp_vpc_01.project_id
  network                 = module.prod_gcp_vpc_01.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/8"]
  internal_allow = [
    { "protocol" : "all" },
  ]
}
