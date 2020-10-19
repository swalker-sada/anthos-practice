provider "gitlab" {
  version  = "2.11.0"
  token    = var.gitlab_token
  base_url = "https://${var.gitlab_hostname}/api/v4/"
  insecure = true
}


