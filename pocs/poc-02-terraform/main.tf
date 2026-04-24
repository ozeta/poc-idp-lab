resource "github_repository" "this" {
  name        = var.repository_name
  description = var.repository_description
  visibility  = var.visibility

  has_issues   = var.has_issues
  has_wiki     = var.has_wiki
  has_projects = var.has_projects

  auto_init          = var.auto_init
  gitignore_template = var.gitignore_template != "" ? var.gitignore_template : null
  license_template   = var.license_template != "" ? var.license_template : null

  delete_branch_on_merge = var.delete_branch_on_merge
  allow_merge_commit     = var.allow_merge_commit
  allow_squash_merge     = var.allow_squash_merge
  allow_rebase_merge     = var.allow_rebase_merge
}

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = var.default_branch
}

# --- Branch protection for default branch ---

resource "github_branch_protection" "default" {
  repository_id = github_repository.this.node_id
  pattern       = var.default_branch

  required_pull_request_reviews {
    required_approving_review_count = var.required_approving_review_count
    dismiss_stale_reviews           = var.dismiss_stale_reviews
  }

  enforce_admins = var.enforce_admins

  # Prevent direct pushes – all changes must go through a PR
  restrict_pushes {
    blocks_creations = true
  }

  depends_on = [github_branch_default.this]
}

# --- Create develop branch ---

resource "github_branch" "develop" {
  count         = var.create_develop_branch ? 1 : 0
  repository    = github_repository.this.name
  branch        = "develop"
  source_branch = var.default_branch

  depends_on = [
    github_branch_default.this,
    github_repository_file.readme,
    github_repository_file.codeowners,
  ]
}

# --- Seed files committed into the repository ---

resource "github_repository_file" "readme" {
  count               = var.seed_files ? 1 : 0
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = "README.md"
  content             = templatefile("${path.module}/templates/README.md.tftpl", {
    repository_name        = var.repository_name
    repository_description = var.repository_description
  })
  commit_message      = "chore: add README.md"
  overwrite_on_create = true

  depends_on = [github_branch_default.this]
}

resource "github_repository_file" "codeowners" {
  count               = var.seed_files ? 1 : 0
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = "CODEOWNERS"
  content             = templatefile("${path.module}/templates/CODEOWNERS.tftpl", {
    codeowners = var.codeowners
  })
  commit_message      = "chore: add CODEOWNERS"
  overwrite_on_create = true

  depends_on = [github_branch_default.this]
}

resource "github_repository_file" "devcontainer" {
  count               = var.seed_files ? 1 : 0
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = ".devcontainer/devcontainer.json"
  content             = file("${path.module}/templates/.devcontainer/devcontainer.json")
  commit_message      = "chore: add devcontainer config"
  overwrite_on_create = true

  depends_on = [github_branch_default.this]
}

resource "github_repository_file" "pre_commit" {
  count               = var.seed_files ? 1 : 0
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = ".pre-commit-config.yaml"
  content             = file("${path.module}/templates/.pre-commit-config.yaml")
  commit_message      = "chore: add pre-commit config"
  overwrite_on_create = true

  depends_on = [github_branch_default.this]
}

resource "github_repository_file" "pr_template" {
  count               = var.seed_files ? 1 : 0
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = ".github/PULL_REQUEST_TEMPLATE.md"
  content             = file("${path.module}/templates/.github/PULL_REQUEST_TEMPLATE.md")
  commit_message      = "chore: add PR template"
  overwrite_on_create = true

  depends_on = [github_branch_default.this]
}

resource "github_repository_file" "updatecli" {
  count               = var.seed_files ? 1 : 0
  repository          = github_repository.this.name
  branch              = var.default_branch
  file                = ".updatecli/updatecli.d/python.yaml"
  content             = file("${path.module}/templates/.updatecli/updatecli.d/python.yaml")
  commit_message      = "chore: add updatecli config"
  overwrite_on_create = true

  depends_on = [github_branch_default.this]
}
