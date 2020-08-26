module "asm-gke1" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  project_id       = data.terraform_remote_state.vpc.outputs.project_id
  gke_hub_sa_name  = "gke-hub-sa-${data.terraform_remote_state.gke.outputs.gke1_name}"
  gke_hub_membership_name  = "gke-asm-membership-${data.terraform_remote_state.gke.outputs.gke1_name}"
  cluster_name     = data.terraform_remote_state.gke.outputs.gke1_name
  location         = data.terraform_remote_state.gke.outputs.gke1_location
  cluster_endpoint = data.terraform_remote_state.gke.outputs.gke1_endpoint
}

module "asm-gke2" {
  source           = "terraform-google-modules/kubernetes-engine/google//modules/asm"
  project_id       = data.terraform_remote_state.vpc.outputs.project_id
  gke_hub_sa_name  = "gke-hub-sa-${data.terraform_remote_state.gke.outputs.gke2_name}"
  gke_hub_membership_name  = "gke-asm-membership-${data.terraform_remote_state.gke.outputs.gke2_name}"
  cluster_name     = data.terraform_remote_state.gke.outputs.gke2_name
  location         = data.terraform_remote_state.gke.outputs.gke2_location
  cluster_endpoint = data.terraform_remote_state.gke.outputs.gke2_endpoint
}

resource "null_resource" "exec_create_cross_cluster_endpoint_discovery" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/cross_cluster_endpoint_discovery.sh"
    environment = {
      ASM_VERSION             = var.asm_version
      PROJECT_ID              = data.terraform_remote_state.vpc.outputs.project_id
      GKE1                    = data.terraform_remote_state.gke.outputs.gke1_name
      GKE1_LOCATION           = data.terraform_remote_state.gke.outputs.gke1_location
      GKE2                    = data.terraform_remote_state.gke.outputs.gke2_name
      GKE2_LOCATION           = data.terraform_remote_state.gke.outputs.gke2_location
    }
  }

  triggers = {
    script_sha1          = sha1(file("cross_cluster_endpoint_discovery.sh"))
  }
}

resource "null_resource" "exec_eks1_asm" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/eks_asm.sh ${data.terraform_remote_state.eks.outputs.eks1_cluster_id}"
    environment = {
      PROJECT_ID = data.terraform_remote_state.vpc.outputs.project_id
      ASM_VERSION = var.asm_version
    }
  }
  triggers = {
    script_sha1          = sha1(file("eks_asm.sh"))
  }
}

resource "null_resource" "exec_eks2_asm" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/eks_asm.sh ${data.terraform_remote_state.eks.outputs.eks2_cluster_id}"
    environment = {
      PROJECT_ID = data.terraform_remote_state.vpc.outputs.project_id
      ASM_VERSION = var.asm_version
    }
  }
  triggers = {
    script_sha1          = sha1(file("eks_asm.sh"))
  }
  depends_on = [null_resource.exec_eks1_asm]
}
