resource "null_resource" "exec_make_gcr_public" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/make_gcr_public.sh"
    environment = {
      PROJECT_ID             = var.project_id
    }
  }
  triggers = {
    script_sha1      = sha1(file("${path.module}/make_gcr_public.sh")),
  }
}
