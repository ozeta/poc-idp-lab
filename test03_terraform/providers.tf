terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = var.github_owner
  # Token is read automatically from the GITHUB_TOKEN env var.
  # Override via var.github_token if needed (e.g. TF_VAR_github_token).
  token = var.github_token
}
