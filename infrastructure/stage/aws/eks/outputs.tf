/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "eks_list" {
  value = [
    "${module.eks-stage-1.cluster_id}"
  ]
}

output "eks1_cluster_id" {
  description = "eks1 cluster name"
  value       = module.eks-stage-1.cluster_id
}

output "eks1_cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks-stage-1.cluster_endpoint
}

output "eks1_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks-stage-1.cluster_security_group_id
}

output "eks1_kubectl_config" {
  description = "kubectl config as generated by the module."
  value       = module.eks-stage-1.kubeconfig
}

output "eks1_config_map_aws_auth" {
  description = "A kubernetes configuration to authenticate to this EKS cluster."
  value       = module.eks-stage-1.config_map_aws_auth
}

