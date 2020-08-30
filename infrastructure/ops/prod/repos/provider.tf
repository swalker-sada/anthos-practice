data "external" "gitlab-creds" {
  program = ["bash", "${path.module}/get_gitlab_creds.sh"]
  query = {
    PROJECT_ID = var.project_id
  }
}

provider "gitlab" {
  token = data.external.gitlab-creds.result.gitlab_creds
  # token    = var.gitlab_token
  base_url = "https://${var.gitlab_hostname}/api/v4/"
  insecure = true
}
