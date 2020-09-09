output "gitlab_hostname" {
  value       = module.prod-gitlab.gitlab_hostname
  description = "GitLab endpoint hostname."
}
output "gitlab_root_password_instructions" {
  value       = module.prod-gitlab.gitlab_root_password_instructions
  description = "GitLab root password instructions."
}

