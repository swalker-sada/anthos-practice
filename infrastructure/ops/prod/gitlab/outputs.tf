output "gitlab_hostname" {
  value       = module.cloud-endpoints-dns-gitlab.endpoint_computed
  description = "GitLab endpoint hostname."
}
