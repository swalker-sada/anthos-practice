resource "null_resource" "exec_install_asm" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/install_asm.sh"
    environment = {
      PROJECT_ID = data.terraform_remote_state.vpc.outputs.project_id
      ASM_VERSION = var.asm_version
      GKE1 = data.terraform_remote_state.gke.outputs.gke1_name
      GKE1_LOCATION = data.terraform_remote_state.gke.outputs.gke1_location
      GKE2 = data.terraform_remote_state.gke.outputs.gke2_name
      GKE2_LOCATION = data.terraform_remote_state.gke.outputs.gke2_location
      EKS1     = data.terraform_remote_state.eks.outputs.eks1_cluster_id
      EKS2     = data.terraform_remote_state.eks.outputs.eks2_cluster_id
    }
  }
  triggers = {
    script_sha1          = sha1(file("install_asm.sh"))
  }
}
