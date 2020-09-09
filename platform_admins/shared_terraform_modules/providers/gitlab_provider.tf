provider "gitlab" {
  token    = var.gitlab_token
  base_url = "https://${var.gitlab_hostname}/api/v4/"
  insecure = true
}


