# Create an ACM repo
resource "google_sourcerepo_repository" "acm_repo" {
  name    = var.acm_repo
  project = data.terraform_remote_state.vpc.outputs.project_id
}

resource "null_resource" "exec_prep_acm" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/prep_acm.sh"
    environment = {
      PROJECT_ID         = data.terraform_remote_state.vpc.outputs.project_id
    }
  }

  triggers = {
    script_sha1          = sha1(file("prep_acm.sh"))
  }
}
