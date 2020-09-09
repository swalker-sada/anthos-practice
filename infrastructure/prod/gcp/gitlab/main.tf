module "prod-gitlab" {
    source = "../../../../platform_admins/shared_terraform_modules/gcp/gitlab/"
    project_id = var.project_id
}
