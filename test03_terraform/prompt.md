
---
description: Create a new GitHub repository with seed files using the Terraform/OpenTofu config in test03_terraform
mode: agent
tools:
  - replace_string_in_file
  - read_file
  - run_in_terminal
  - get_terminal_output
  - vscode_askQuestions
---

# Create a new GitHub repository

You are helping the user create a new GitHub repository using the existing Terraform (OpenTofu) configuration in `test03_terraform/`.

## Project structure

```
test03_terraform/
├── .env                  # GITHUB_TOKEN (git-ignored, never commit)
├── .gitignore            # Ignores .env, *.tfstate, .terraform/, *.tfvars
├── main.tf               # github_repository + github_repository_file resources
├── variables.tf          # All input variables with defaults
├── providers.tf          # GitHub provider (token from env var GITHUB_TOKEN)
├── outputs.tf            # Repo URL, SSH/HTTPS clone URLs
├── terraform.tfvars      # Current variable values (git-ignored)
├── terraform.tfvars.example  # Committed example for reference
└── templates/            # Seed files committed into the new repo
    ├── README.md.tftpl           # Templated README (uses repository_name, repository_description)
    ├── CODEOWNERS.tftpl          # Templated CODEOWNERS (uses codeowners var)
    ├── .devcontainer/
    │   └── devcontainer.json     # Python 3.11 devcontainer
    ├── .github/
    │   └── PULL_REQUEST_TEMPLATE.md
    ├── .pre-commit-config.yaml   # Python hooks (ruff, mypy, pre-commit-hooks)
    └── .updatecli/
        └── updatecli.d/
            └── python.yaml       # Updatecli config for Python deps
```

## Authentication

The GitHub token is stored in `.env` as `GITHUB_TOKEN` and is **never** placed in `terraform.tfvars`.
The GitHub provider reads it automatically from the environment when `var.github_token` is null.
Always `source .env` before running tofu commands, or export `GITHUB_TOKEN` in your shell.

## Variables reference

| Variable | Type | Default | Description |
|---|---|---|---|
| `github_owner` | string | — | GitHub org or user |
| `repository_name` | string | — | Repository name |
| `repository_description` | string | `""` | Short description |
| `visibility` | string | `"private"` | `public`, `private`, or `internal` |
| `auto_init` | bool | `true` | Init with a commit |
| `gitignore_template` | string | `""` | e.g. `Node`, `Python`, `Go`, or empty |
| `license_template` | string | `""` | e.g. `mit`, `apache-2.0`, or empty |
| `default_branch` | string | `"main"` | Default branch name |
| `has_issues` | bool | `true` | Enable Issues |
| `has_wiki` | bool | `false` | Enable Wiki |
| `has_projects` | bool | `false` | Enable Projects |
| `delete_branch_on_merge` | bool | `true` | Auto-delete merged branches |
| `allow_merge_commit` | bool | `true` | Allow merge commits |
| `allow_squash_merge` | bool | `true` | Allow squash merging |
| `allow_rebase_merge` | bool | `true` | Allow rebase merging |
| `seed_files` | bool | `true` | Commit seed files into the repo |
| `codeowners` | string | `"@org/team-name"` | CODEOWNERS entry |

## Seed files

When `seed_files = true`, these files are committed into the new repo via `github_repository_file` resources:
- `README.md` — generated from `templates/README.md.tftpl`
- `CODEOWNERS` — generated from `templates/CODEOWNERS.tftpl`
- `.devcontainer/devcontainer.json` — Python 3.11 dev container
- `.pre-commit-config.yaml` — Python linting hooks (ruff, mypy)
- `.github/PULL_REQUEST_TEMPLATE.md` — Standard PR checklist
- `.updatecli/updatecli.d/python.yaml` — Updatecli dependency update config

## Steps

1. Ask the user the following questions (use the ask-questions tool, all in one call):
   - **Repository name** (required): the name for the new GitHub repo
   - **Description**: a short description for the repo (default: empty)
   - **Visibility**: public, private, or internal (default: private)
   - **Gitignore template**: e.g. Node, Python, Go, or none (default: none)
   - **License**: e.g. mit, apache-2.0, or none (default: none)
   - **Seed files**: whether to commit starter files (README, CODEOWNERS, .devcontainer, .pre-commit-config.yaml, PR template, updatecli) into the repo (default: yes)
   - **CODEOWNERS**: who should own the code, e.g. @org/team-name (only ask if seed files = yes)

2. Read the current `test03_terraform/terraform.tfvars` file.

3. Update `test03_terraform/terraform.tfvars` with the user's answers, setting:
   - `repository_name`
   - `repository_description`
   - `visibility`
   - `gitignore_template` (empty string if none)
   - `license_template` (empty string if none)
   - `seed_files` (true/false)
   - `codeowners` (if seed files enabled)
   Keep `github_owner` unchanged. Do NOT put the GitHub token in tfvars.

4. Run `cd test03_terraform && source .env && tofu plan` and show the user the plan output.

5. Ask the user to confirm before applying.

6. If confirmed, run `cd test03_terraform && source .env && tofu apply -auto-approve` and report the outputs (repo URL, clone URLs).

## Important notes

- The existing `terraform.tfstate` tracks the previously created repo. If creating a **new** repo, you may need to remove or move the old state first (`tofu state rm` or start a new workspace).
- To destroy a repo: `source .env && tofu destroy`.
- Template files in `templates/` can be customized before applying — they are the source of truth for seed file content.
