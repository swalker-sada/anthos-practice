resource "null_resource" "exec_create_asm_yamls" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/create_asm_yamls.sh"
    environment = {
      GKE_NET  = var.gke_net
      ASM_VERSION = var.asm_version
      PROJECT_ID = var.project_id
      GKE_LIST_STRING = var.gke_list
      GKE_LOC_STRING  = var.gke_location_list
      EKS_LIST_STRING = var.eks_list
      EKS_INGRESS_IPS_STRING = var.eks_ingress_ip_list
      EKS_EIP_LIST_STRING = var.eks_eip_list
      # ASM yaml patches below
      HEADER = local.header
      EKS_COMPONENT = local.eks_component
      GCP_VALUES = local.gcp_values
      EKS_VALUES = local.eks_values
      GCP_REGISTRY = local.gcp_registry
      GATEWAYS_REGISTRY = local.gateways_registry
      EKS_SELF_NETWORK = local.eks_self_network
      EKS_REMOTE_NETWORK = local.eks_remote_network
    }
  }
  triggers = {
    build_number = "${timestamp()}"
  }
}

resource "null_resource" "exec_install_asm" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/install_asm.sh"
    environment = {
      ASM_VERSION = var.asm_version
      PROJECT_ID = var.project_id
      GKE_LIST_STRING = var.gke_list
      GKE_LOC_STRING  = var.gke_location_list
      EKS_LIST_STRING = var.eks_list
      CLUSTER_AWARE_GATEWAY = local.cluster_aware_gateway
    }
  }
  triggers = {
    build_number = "${timestamp()}"
  }
  depends_on = [null_resource.exec_create_asm_yamls]
}

