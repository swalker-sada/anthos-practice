resource "gitlab_group" "platform-admins" {
  name             = var.platform_admins
  path             = var.platform_admins
  description      = "An group of projects for Platform Admins"
  visibility_level = "internal"
}

resource "gitlab_project" "anthos-config-management" {
  name             = var.acm
  description      = "Anthos Config Management repo"
  namespace_id     = gitlab_group.platform-admins.id
  visibility_level = "internal"
  default_branch   = "master"
}

resource "gitlab_deploy_key" "anthos-config-management" {
  project    = gitlab_project.anthos-config-management.id
  title      = "acm deploy key"
  key        = data.terraform_remote_state.prod_gcp_ssh_key.outputs.public_key_openssh
  can_push   = "true"
   depends_on = [gitlab_project.anthos-config-management]
}

resource "gitlab_group" "online-boutique" {
  name             = var.online_boutique_group
  path             = var.online_boutique_group
  description      = "Online boutique group"
  visibility_level = "internal"
}

resource "gitlab_project" "online-boutique" {
  name             = var.online_boutique_project
  description      = "Online boutique project"
  namespace_id     = gitlab_group.online-boutique.id
  visibility_level = "internal"
  default_branch   = "master"
}
