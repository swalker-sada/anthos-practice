# Version
terraform {
  required_version = ">=0.12, <0.14"
}

# Provider
provider "google" { version = "~> 3.32.0" }
provider "google-beta" { version = "~> 3.32.0" }
# provider "kubernetes" { version = "~>1.10.0" }

# Create VPC
module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 2.4"

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
  network                 = module.vpc.network_name
  internal_ranges_enabled = true
  internal_ranges         = ["10.0.0.0/8"]
  internal_allow = [
    { "protocol" : "all" },
  ]
}

# Create GKE cluster
data "google_project" "project" {
  project_id = var.project_id
}

data "google_client_config" "default" {
}


module "gke1" {
  source                  = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-public-cluster"
  project_id              = var.project_id
  name                    = var.gke1
  regional                = false
  region                  = var.subnet_01_region
  zones                   = ["${var.subnet_01_region}-a"]
  release_channel         = "RAPID"
  network                 = module.vpc.network_name
  subnetwork              = var.subnet_01_name
  ip_range_pods           = var.subnet_01_secondary_pod_name
  ip_range_services       = var.subnet_01_secondary_svc_1_name
  network_policy          = false
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  node_pools = [
    {
      name         = "node-pool-01"
      autoscaling  = false
      auto_upgrade = true
      # ASM requires minimum 4 nodes and e2-standard-4
      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]
}

module "gke2" {
  source                  = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-public-cluster"
  project_id              = var.project_id
  name                    = var.gke2
  regional                = false
  region                  = var.subnet_01_region
  zones                   = ["${var.subnet_01_region}-b"]
  release_channel         = "RAPID"
  network                 = module.vpc.network_name
  subnetwork              = var.subnet_01_name
  ip_range_pods           = var.subnet_01_secondary_pod_name
  ip_range_services       = var.subnet_01_secondary_svc_2_name
  network_policy          = false
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}" }
  node_pools = [
    {
      name         = "node-pool-01"
      autoscaling  = false
      auto_upgrade = true
      # ASM requires minimum 4 nodes and e2-standard-4
      node_count   = 4
      machine_type = "e2-standard-4"
    },
  ]
}
