# Backstage and Terraform Provisioning Workspace

## Backstage repository provisioning test: test02

Install latest Backstage:

```bash
npx @backstage/create-app@latest
```

Pick a name for the new folder.

From within the folder, create a `.env` file and put a GitHub token with access to `repo`, `workflow`, and `delete_repo`. Then run:

```bash
source .env && yarn start
```

## Terraform repository provisioning test: test03_terraform

Add your GitHub token, then run:

```bash
tofu init
tofu plan
tofu apply
```

## Global devcontainer for test02 and test03_terraform

A single workspace-level devcontainer is available at `.devcontainer/devcontainer.json`.
It is set up to support:

- Backstage development in `test02` (Node 22 + yarn)
- Terraform workflows in `test03_terraform` (Terraform CLI installed)

### Use it

1. Open the workspace root in VS Code.
2. Run Reopen in Container.
3. After container startup:
   - `test02` dependencies are installed automatically.
   - Launch tasks are available from Terminal > Run Task.

### Included tasks

- `Backstage: install deps`
- `Backstage: start`
- `Terraform: init`
- `Terraform: plan`
- `Terraform: apply`

### Notes

- Terraform commands run in `test03_terraform`.
- Backstage commands run in `test02`.
- For GitHub provider auth in Terraform, export `GITHUB_TOKEN` in the container terminal.
