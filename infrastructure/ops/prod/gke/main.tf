# Create GKE cluster
data "google_project" "project" {
  project_id = data.terraform_remote_state.vpc.outputs.project_id
}

data "google_client_config" "default" {
}


module "gke1" {
  source                  = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-public-cluster"
  project_id              = data.terraform_remote_state.vpc.outputs.project_id
  name                    = var.gke1
  regional                = false
  region                  = var.subnet_01_region
  zones                   = ["${var.subnet_01_region}-a"]
  release_channel         = "RAPID"
  network                 = data.terraform_remote_state.vpc.outputs.network_name
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
  project_id              = data.terraform_remote_state.vpc.outputs.project_id
  name                    = var.gke2
  regional                = false
  region                  = var.subnet_01_region
  zones                   = ["${var.subnet_01_region}-b"]
  release_channel         = "RAPID"
  network                 = data.terraform_remote_state.vpc.outputs.network_name
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
