output "gke_prod_1_name" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_name }
output "gke_prod_1_location" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_1_location }

output "gke_prod_2_name" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_name }
output "gke_prod_2_location" { value = data.terraform_remote_state.prod_gcp_gke.outputs.gke_prod_2_location }

output "eks_prod_1_name" { value = data.terraform_remote_state.prod_aws_eks.outputs.eks1_cluster_id }
output "eks_prod_2_name" { value = data.terraform_remote_state.prod_aws_eks.outputs.eks2_cluster_id }
