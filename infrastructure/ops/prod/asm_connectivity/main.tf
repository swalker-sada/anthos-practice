resource "null_resource" "exec_connectivity" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/connectivity.sh"
    environment = {
      PROJECT_ID = data.terraform_remote_state.vpc.outputs.project_id
      GKE1 = data.terraform_remote_state.gke.outputs.gke1_name
      GKE1_LOCATION = data.terraform_remote_state.gke.outputs.gke1_location
      GKE2 = data.terraform_remote_state.gke.outputs.gke2_name
      GKE2_LOCATION = data.terraform_remote_state.gke.outputs.gke2_location
      EKS1     = data.terraform_remote_state.eks.outputs.eks1_cluster_id
      EKS2     = data.terraform_remote_state.eks.outputs.eks2_cluster_id
    }
  }
  triggers = {
    script_sha1          = sha1(file("connectivity.sh"))
  }
}
