---
description: Create a new GitHub repository using the Terraform config in test03_terraform
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

## Steps

1. Ask the user the following questions (use the ask-questions tool, all in one call):
   - **Repository name** (required): the name for the new GitHub repo
   - **Description**: a short description for the repo (default: empty)
   - **Visibility**: public, private, or internal (default: private)
   - **Gitignore template**: e.g. Node, Python, Go, or none (default: none)
   - **License**: e.g. mit, apache-2.0, or none (default: none)

2. Read the current `test03_terraform/terraform.tfvars` file.

3. Update `test03_terraform/terraform.tfvars` with the user's answers, setting:
   - `repository_name`
   - `repository_description`
   - `visibility`
   - `gitignore_template` (empty string if none)
   - `license_template` (empty string if none)
   Keep `github_token` and `github_owner` unchanged.

4. Run `cd test03_terraform && tofu plan` and show the user the plan output.

5. Ask the user to confirm before applying.

6. If confirmed, run `cd test03_terraform && tofu apply -auto-approve` and report the outputs (repo URL, clone URLs).
