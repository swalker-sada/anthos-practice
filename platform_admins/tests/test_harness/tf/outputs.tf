output "gke_prod_1_name" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_name }
output "gke_prod_1_location" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_location }

output "gke_prod_2_name" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_name }
output "gke_prod_2_location" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_location }

output "eks_prod_1_name" { value = data.terraform_remote_state.prod_aws_eks.outputs.eks1_cluster_id }
output "eks_prod_2_name" { value = data.terraform_remote_state.prod_aws_eks.outputs.eks2_cluster_id }

output "gke_stage_1_name" { value = data.terraform_remote_state.stage_gcp_gke.outputs.gke_stage_1_name }
output "gke_stage_1_location" { value = data.terraform_remote_state.stage_gcp_gke.outputs.gke_stage_1_location }

output "eks_stage_1_name" { value = data.terraform_remote_state.stage_aws_eks.outputs.eks1_cluster_id }

output "gke_dev_1_name" { value = data.terraform_remote_state.dev_gcp_gke.outputs.gke_dev_1_name }
output "gke_dev_1_location" { value = data.terraform_remote_state.dev_gcp_gke.outputs.gke_dev_1_location }

output "gke_dev_2_name" { value = data.terraform_remote_state.dev_gcp_gke.outputs.gke_dev_2_name }
output "gke_dev_2_location" { value = data.terraform_remote_state.dev_gcp_gke.outputs.gke_dev_2_location }

