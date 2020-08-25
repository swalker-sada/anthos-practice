output "acm_repo" { value = google_sourcerepo_repository.acm_repo.name }
output "acm_repo_url" { value = google_sourcerepo_repository.acm_repo.url }
output "acm_repo_id" { value = google_sourcerepo_repository.acm_repo.id }
output "acm_git_creds_public" { value = module.gke1_acm.git_creds_public }
