output "gitlab_hostname" {
  value       = module.cloud-endpoints-dns-gitlab.endpoint_computed
  description = "GitLab endpoint hostname."
}
output "gitlab_root_password_instructions" {
  value       = module.gke-gitlab.root_password_instructions
  description = "GitLab root password instructions."
}
