output "repository_full_name" {
  description = "Full name of the repository (owner/name)"
  value       = github_repository.this.full_name
}

output "repository_html_url" {
  description = "URL to the repository on GitHub"
  value       = github_repository.this.html_url
}

output "repository_ssh_clone_url" {
  description = "SSH clone URL"
  value       = github_repository.this.ssh_clone_url
}

output "repository_http_clone_url" {
  description = "HTTPS clone URL"
  value       = github_repository.this.http_clone_url
}
