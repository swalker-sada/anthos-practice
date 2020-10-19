resource "null_resource" "kcc" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/install_kcc.sh"
    environment = {
      PROJECT_ID       = var.project_id
      GKE_NAME         = var.gke_name
      GKE_LOC          = var.gke_location
    }
  }

  triggers = {
    script_sha1      = sha1(file("${path.module}/install_kcc.sh")),
  }
}
