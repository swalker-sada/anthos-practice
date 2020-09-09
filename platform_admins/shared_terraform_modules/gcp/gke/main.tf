# GKE
locals {
    # The following locals are derived from the subnet object
    node_subnet = var.subnet.name
    pod_subnet = var.subnet.secondary_ip_range[0].range_name
    svc_subnet = var.subnet.secondary_ip_range[local.suffix].range_name
    region = var.subnet.region
    network = split("/", var.subnet.network)[length(split("/", var.subnet.network))-1]
    project = var.subnet.project
    suffix = var.suffix
    env = var.env
    zone = var.zone
}

module "gke" {
  source                  = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-public-cluster"
  project_id              = local.project
  name                    = "gke-${local.env}-${local.region}${local.zone}-${local.suffix}"
  regional                = false
  region                  = local.region
  zones                   = ["${local.region}-${local.zone}"]
  release_channel         = "RAPID"
  network                 = local.network
  subnetwork              = local.node_subnet
  ip_range_pods           = local.pod_subnet
  ip_range_services       = local.svc_subnet
  network_policy          = false
  cluster_resource_labels = { "environ" : "${local.env}", "infra" : "gcp" }
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

module "acm" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm"
  project_id       = local.project
  cluster_name     = module.gke.name
  location         = module.gke.location
  cluster_endpoint = module.gke.endpoint
  ssh_auth_key     = var.acm_ssh_auth_key
  create_ssh_key   = false
  sync_repo        = var.acm_sync_repo
}