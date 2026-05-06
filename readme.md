
# Backstage and Terraform Provisioning Workspace

This workspace contains two main PoCs under `pocs`:

- `poc-01-backstage`: Backstage repository provisioning test
- `poc-02-terraform`: Terraform/OpenTofu repository provisioning test

## Setup Devcontainer environment

The workspace includes a single devcontainer configuration at `.devcontainer/devcontainer.json`.

### What it provides

- Node.js 22 and yarn for Backstage development in `pocs/poc-01-backstage`
- Terraform tooling for infrastructure workflows in `pocs/poc-02-terraform`

### Start the editor in the devcontainer

1. Install the Dev Containers extension in VS Code (if needed).
2. Open this repository root folder in VS Code.
3. Open the Command Palette and run Dev Containers: Reopen in Container.
4. Wait for container startup; VS Code reconnects automatically.

### Available VS Code tasks

- Backstage: install deps
- Backstage: start
- Terraform: init
- Terraform: plan
- Terraform: apply
- OpenTofu: init
- OpenTofu: plan
- OpenTofu: apply

## 2. poc-01-backstage (Backstage)

Location: `pocs/poc-01-backstage`

### Included Scaffolder templates

This workspace includes custom Backstage software templates:

For this PoC, the template is loaded from the `examples` folder.

- Template definition: `pocs/poc-01-backstage/examples/repo-template/template.yaml`
- Template content: `pocs/poc-01-backstage/examples/repo-template/content`
- Template definition: `pocs/poc-01-backstage/examples/csharp-repo-template/template.yaml`
- Template content: `pocs/poc-01-backstage/examples/csharp-repo-template/content`

You can change this path in `pocs/poc-01-backstage/app-config.yaml` under `catalog.locations` (and in `pocs/poc-01-backstage/app-config.production.yaml` for production).

Template names in the Scaffolder UI:

- `New Repository with README`
- `New C# Repository Foundation`

What it does:

- Prompts for repository/component metadata
- Publishes a new GitHub repository
- Registers the generated `catalog-info.yaml` in Backstage Catalog
- Sends a Backstage notification when creation completes

### PostgreSQL (docker-compose)

A `docker-compose.yml` in `pocs/poc-01-backstage` provides a PostgreSQL 16 instance for Backstage.

The image is pinned to a specific digest for reproducibility:

```
postgres:16@sha256:adaa8b0891d74ee64cc97119c96b4826190ada4644a41d69dfb6c2d96a27f7a3
```

Environment variables are defined in `pocs/poc-01-backstage/.env`. Load them before running Docker Compose:

```bash
source .env && docker compose up -d
```

> Docker Compose also auto-loads a `.env` file in the same directory when you run `docker compose up`. If all variables are set correctly in `.env` (without `export`), sourcing is not required. Use `source .env` explicitly if your shell session needs the variables for other tools too.

Default connection details (values from `.env`):

| Setting  | Variable           | Default value |
|----------|--------------------|---------------|
| Host     | `POSTGRES_HOST`    | localhost     |
| Port     | `POSTGRES_PORT`    | 5432          |
| User     | `POSTGRES_USER`    | backstage     |
| Password | `POSTGRES_PASSWORD`| backstage     |
| Database | `POSTGRES_DB`      | backstage     |

Port exposure and persistence:

- Host port exposure is configured in `docker-compose.yml` as `${POSTGRES_PORT:-5432}:5432`
- Persistent storage uses the named Docker volume `postgres_data`
- Data remains available across container restarts and `docker compose down`
- Data is deleted only when using `docker compose down -v`

Stop and remove:

```bash
docker compose down        # keep volume
docker compose down -v     # also delete data
```

### Run Backstage

Start the database first, then install and start Backstage from `pocs/poc-01-backstage`:

```bash
source .env && docker compose up -d
corepack yarn install
corepack yarn start
```

You can also use the VS Code tasks:

- Backstage: install deps
- Backstage: start

### Notes

- The Backstage app and backend sources are under `pocs/poc-01-backstage/packages/app` and `pocs/poc-01-backstage/packages/backend`.
- If your flow needs GitHub auth, provide token values through environment variables or a local `.env` file inside `pocs/poc-01-backstage`.
- Update `app-config.yaml` to point the Backstage backend at the database (see `backend.database`).

## 3. poc-02-terraform (Terraform/OpenTofu)

Location: `pocs/poc-02-terraform`

### Configure credentials

Set a GitHub token in your shell before planning/applying:

```bash
export GITHUB_TOKEN=<your-token>
```

### Run with OpenTofu

From `pocs/poc-02-terraform`:

```bash
tofu init
tofu plan
tofu apply
```

### Run with Terraform

From `pocs/poc-02-terraform`:

```bash
terraform init
terraform plan
terraform apply
```

You can also use the VS Code tasks for both Terraform and OpenTofu.

## Quick directory map

- `pocs/poc-01-backstage`: Backstage application and backend
- `pocs/poc-02-terraform`: Terraform/OpenTofu templates and state for repo provisioning tests
- `pocs/poc-02-terraform-created_repo`: Generated output from provisioning test runs


# Use GitHub Auth SSO


Go to: https://github.com/organizations/Oz-hubs/settings/applications/
(or your personal settings if you don't have org admin: https://github.com/settings/applications/new)

Field	Value
Application name	Backstage (dev)
Homepage URL	http://localhost:3000
Authorization callback URL	http://localhost:7007/api/auth/github/handler/frame
After creating it, note the Client ID and generate a Client Secret. You'll need:

```bash
AUTH_GITHUB_CLIENT_ID=<client-id>
AUTH_GITHUB_CLIENT_SECRET=<client-secret>
GITHUB_TOKEN=<your-pat>
```

**GITHUB_TOKEN must have these scopes:**
- `read:user` — Read GitHub user profiles (required for sign-in)
- `email` — Access user email addresses (required for sign-in)
- `read:org` — Read organization members and teams (required for org catalog ingestion)
