variable "github_token" {
  description = "GitHub personal access token with repo permissions. Set via GITHUB_TOKEN env var."
  type        = string
  sensitive   = true
  default     = null
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repository"
  type        = string
}

variable "repository_name" {
  description = "Name of the GitHub repository to create"
  type        = string
}

variable "repository_description" {
  description = "Description of the repository"
  type        = string
  default     = ""
}

variable "visibility" {
  description = "Repository visibility: public, private, or internal"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "internal"], var.visibility)
    error_message = "Visibility must be one of: public, private, internal."
  }
}

variable "has_issues" {
  description = "Enable GitHub Issues"
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Enable GitHub Wiki"
  type        = bool
  default     = false
}

variable "has_projects" {
  description = "Enable GitHub Projects"
  type        = bool
  default     = false
}

variable "auto_init" {
  description = "Initialize the repository with a README"
  type        = bool
  default     = true
}

variable "gitignore_template" {
  description = "Git ignore template (e.g. Node, Python, Go). Leave empty for none."
  type        = string
  default     = ""
}

variable "license_template" {
  description = "License template (e.g. mit, apache-2.0). Leave empty for none."
  type        = string
  default     = ""
}

variable "default_branch" {
  description = "Default branch name"
  type        = string
  default     = "main"
}

variable "delete_branch_on_merge" {
  description = "Automatically delete head branches after a PR is merged"
  type        = bool
  default     = true
}

variable "allow_merge_commit" {
  description = "Allow merge commits"
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Allow squash merging"
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merging"
  type        = bool
  default     = true
}

# --- Repository seed files ---

variable "codeowners" {
  description = "CODEOWNERS entry (e.g. @org/team-name or @username)"
  type        = string
  default     = "@org/team-name"
}

variable "seed_files" {
  description = "Whether to commit seed files (README, CODEOWNERS, devcontainer, etc.) into the repo"
  type        = bool
  default     = true
}

# --- Branch protection ---

variable "required_approving_review_count" {
  description = "Number of approving reviews required before a PR can be merged into the default branch"
  type        = number
  default     = 2

  validation {
    condition     = var.required_approving_review_count >= 0 && var.required_approving_review_count <= 6
    error_message = "Must be between 0 and 6."
  }
}

variable "dismiss_stale_reviews" {
  description = "Dismiss approved reviews when new commits are pushed"
  type        = bool
  default     = true
}

variable "enforce_admins" {
  description = "Enforce branch protection rules for administrators as well"
  type        = bool
  default     = true
}

# --- Develop branch ---

variable "create_develop_branch" {
  description = "Create a develop branch off the default branch at bootstrap"
  type        = bool
  default     = true
}
