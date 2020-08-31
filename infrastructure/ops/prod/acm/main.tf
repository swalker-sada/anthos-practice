# Create an ACM repo
resource "google_sourcerepo_repository" "acm_repo" {
  name    = var.acm_repo
  project = data.terraform_remote_state.vpc.outputs.project_id
}

module "gke1_acm" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm"
  project_id       = data.terraform_remote_state.vpc.outputs.project_id
  cluster_name     = data.terraform_remote_state.gke.outputs.gke1_name
  location         = data.terraform_remote_state.gke.outputs.gke1_location
  cluster_endpoint = data.terraform_remote_state.gke.outputs.gke1_endpoint
#  operator_path    = "config-management-operator.yaml"
  ssh_auth_key     = file("csr-key")
  create_ssh_key   = false
  sync_repo        = "ssh://${var.user}@source.developers.google.com:2022/p/${data.terraform_remote_state.vpc.outputs.project_id}/r/${google_sourcerepo_repository.acm_repo.name}"
}

module "gke2_acm" {
  source           = "github.com/terraform-google-modules/terraform-google-kubernetes-engine//modules/acm"
  project_id       = data.terraform_remote_state.vpc.outputs.project_id
  cluster_name     = data.terraform_remote_state.gke.outputs.gke2_name
  location         = data.terraform_remote_state.gke.outputs.gke2_location
  cluster_endpoint = data.terraform_remote_state.gke.outputs.gke2_endpoint
#  operator_path    = "config-management-operator.yaml"
  ssh_auth_key     = file("csr-key")
  create_ssh_key   = false
  sync_repo        = "ssh://${var.user}@source.developers.google.com:2022/p/${data.terraform_remote_state.vpc.outputs.project_id}/r/${google_sourcerepo_repository.acm_repo.name}"
}

resource "null_resource" "exec_eks1_acm" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/eks_acm.sh ${data.terraform_remote_state.eks.outputs.eks1_cluster_id}"
    environment = {
      PROJECT_ID = data.terraform_remote_state.vpc.outputs.project_id
      GCLOUD_USER = var.user
      REPO_NAME = var.acm_repo
    }
  }
  triggers = {
    script_sha1          = sha1(file("eks_acm.sh"))
  }
}
resource "null_resource" "exec_eks2_acm" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "${path.module}/eks_acm.sh ${data.terraform_remote_state.eks.outputs.eks2_cluster_id}"
    environment = {
      PROJECT_ID = data.terraform_remote_state.vpc.outputs.project_id
      GCLOUD_USER = var.user
      REPO_NAME = var.acm_repo
    }
  }
  triggers = {
    script_sha1          = sha1(file("eks_acm.sh"))
  }
  depends_on = [null_resource.exec_eks1_acm]
}
