module "gcr_public" {
  source              = "../../../../platform_admins/shared_terraform_modules/gcp/gcr/"
  project_id = var.project_id
}
