module "prod-istio-ingressgateway-gclb" {
  source  = "../../../../platform_admins/shared_terraform_modules/gcp/gclb/"
  env     = var.env
  project_id = var.project_id
  network_name = data.terraform_remote_state.prod_gcp_vpc.outputs.network_name
}
