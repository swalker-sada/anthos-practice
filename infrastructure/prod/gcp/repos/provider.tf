data "external" "gitlab-creds" {
  program = ["bash", "${path.module}/get_gitlab_creds.sh"]
  query = {
    PROJECT_ID = var.project_id
  }
}

provider "gitlab" {
  token    = data.external.gitlab-creds.result.gitlab_creds
  base_url = "https://${data.terraform_remote_state.prod_gcp_gitlab.outputs.gitlab_hostname}/api/v4/"
  insecure = true
}
