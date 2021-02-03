/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# GKE
locals {
  # The following locals are derived from the subnet object
  node_subnet = var.subnet.name
  pod_subnet  = var.subnet.secondary_ip_range[0].range_name
  svc_subnet  = var.subnet.secondary_ip_range[local.suffix].range_name
  region      = var.subnet.region
  network     = split("/", var.subnet.network)[length(split("/", var.subnet.network)) - 1]
  project     = var.subnet.project
  suffix      = var.suffix
  env         = var.env
  zone        = var.zone
}

data "google_project" "project" {
  project_id = var.subnet.project
}

module "gke" {
  source                  = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/beta-public-cluster"
  project_id              = local.project
  name                    = "gke-${local.env}-${local.region}${local.zone}-${local.suffix}"
  regional                = false
  region                  = local.region
  zones                   = ["${local.region}-${local.zone}"]
  release_channel         = "REGULAR"
  network                 = local.network
  subnetwork              = local.node_subnet
  ip_range_pods           = local.pod_subnet
  ip_range_services       = local.svc_subnet
  network_policy          = false
  cluster_resource_labels = { "mesh_id" : "proj-${data.google_project.project.number}", "environ" : "${local.env}", "infra" : "gcp" }
  # cluster_resource_labels = { "mesh_id": "proj-${data.google_project.project.number}" }
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
  source           = "github.com/CloudPharaoh/terraform-google-kubernetes-engine//modules/acm?ref=hub_depends_on"
  project_id       = local.project
  cluster_name     = module.gke.name
  location         = module.gke.location
  cluster_endpoint = module.gke.endpoint
  ssh_auth_key     = var.acm_ssh_auth_key
  create_ssh_key   = false
  sync_repo        = var.acm_sync_repo
  sync_branch      = var.acm_sync_branch
}

module "hub" {
  # Replace when new release including fix is merged
  source = "github.com/CloudPharaoh/terraform-google-kubernetes-engine//modules/hub?ref=hub_depends_on"

  module_depends_on       = [module.acm.wait]
  project_id              = local.project
  cluster_name            = module.gke.name
  location                = module.gke.location
  cluster_endpoint        = module.gke.endpoint
  use_existing_sa         = true
  sa_private_key          = var.hub_sa_private_key
  gke_hub_membership_name = module.gke.name
}
