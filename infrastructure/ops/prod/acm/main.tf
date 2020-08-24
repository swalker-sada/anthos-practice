# Create an ACM repo
resource "google_sourcerepo_repository" "acm_repo" {
  name    = var.acm_repo
  project = data.terraform_remote_state.vpc.outputs.project_id
}

