---
description: Scaffold a Backstage instance with GitHub integration and the repo-template
mode: agent
tools:
  - create_file
  - replace_string_in_file
  - read_file
  - run_in_terminal
  - get_terminal_output
---

# Set up Backstage with GitHub token and repo template

You are helping the user create a fresh Backstage instance, configure it with a GitHub Personal Access Token, and add the "New Repository with README" scaffolder template.

## Prerequisites

- Node.js >= 20 and Yarn installed
- A GitHub Personal Access Token (classic) with scopes: `repo`, `workflow`, `delete_repo`

## Steps

### 1. Scaffold the Backstage app

Run the Backstage create-app CLI in the target directory:

```
npx @backstage/create-app@latest
```

Follow the prompts to name the app (default: the current folder name).

### 2. Configure the GitHub token

Create a `.env` file in the Backstage app root:

```
export GITHUB_TOKEN=<ask the user for their token>
```

Make sure `.env` is listed in `.gitignore` (Backstage includes it by default).

### 3. Verify GitHub integration config

Confirm `app-config.yaml` contains the integration block with the token variable:

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

This is included by default in a new Backstage app. If missing, add it.

### 4. Create the repo template

Create the directory `examples/repo-template/content/` and add the following files.

#### 4.1 Template definition — `examples/repo-template/template.yaml`

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: new-repo-with-readme
  title: New Repository with README
  description: Creates a new GitHub repository pre-populated with a README and a Backstage catalog descriptor.
spec:
  owner: user:guest
  type: service

  parameters:
    - title: Component details
      required:
        - name
        - description
      properties:
        name:
          title: Name
          type: string
          description: Unique name of the component (used as the repo and catalog entry name)
          ui:autofocus: true
        description:
          title: Description
          type: string
          description: A short description of this repository
        owner:
          title: Owner
          type: string
          description: Owner of the component
          ui:field: OwnerPicker
          ui:options:
            catalogFilter:
              kind: [Group, User]
        codeowners:
          title: Code Owners
          type: string
          description: 'GitHub CODEOWNERS entry (e.g. @org/team-name or @username)'
    - title: Choose a location
      required:
        - repoUrl
      properties:
        repoUrl:
          title: Repository Location
          type: string
          ui:field: RepoUrlPicker
          ui:options:
            allowedHosts:
              - github.com

  steps:
    - id: fetch-base
      name: Fetch Base
      action: fetch:template
      input:
        url: ./content
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
          codeowners: ${{ parameters.codeowners }}

    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        description: ${{ parameters.description }}
        repoUrl: ${{ parameters.repoUrl }}
        defaultBranch: main

    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: /catalog-info.yaml

    - id: notify
      name: Notify
      action: notification:send
      input:
        recipients: entity
        entityRefs:
          - user:default/guest
        title: Repository created
        info: '${{ parameters.name }} has been created and registered in the catalog.'
        severity: normal

  output:
    links:
      - title: Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Open in catalog
        icon: catalog
        entityRef: ${{ steps['register'].output.entityRef }}
```

#### 4.2 Content files under `examples/repo-template/content/`

Create each of these files exactly as shown:

**`README.md`**
```markdown
# ${{ values.name }}

${{ values.description }}

## Getting Started

1. Clone this repository:

   ```sh
   git clone <repository-url>
   cd ${{ values.name }}
   ```

2. Install dependencies and follow the project-specific setup instructions.

3. You're ready to go!
```

**`catalog-info.yaml`**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.name | dump }}
  description: ${{ values.description | dump }}
spec:
  type: service
  owner: ${{ values.owner | dump }}
  lifecycle: experimental
```

**`CODEOWNERS`**
```
# Default code owners for the entire repository
* ${{ values.codeowners }}
```

**`.devcontainer/devcontainer.json`**
```json
{
  "name": "Python Dev Container",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  "features": {
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers-contrib/features/pre-commit:2": {}
  },
  "postCreateCommand": "pip install -r requirements.txt && pre-commit install",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "charliermarsh.ruff",
        "eamodio.gitlens"
      ],
      "settings": {
        "python.defaultInterpreterPath": "/usr/local/bin/python"
      }
    }
  }
}
```

**`.pre-commit-config.yaml`**
```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-merge-conflict

  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.4.4
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format

  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.10.0
    hooks:
      - id: mypy
        additional_dependencies: []
```

**`.github/PULL_REQUEST_TEMPLATE.md`**
```markdown
## Description

<!-- Describe your changes in detail -->

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Checklist

- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have added tests that prove my fix is effective or my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have updated the documentation accordingly

## Related Issues

<!-- Link related issues: Fixes #123, Closes #456 -->
```

**`.updatecli/updatecli.d/python.yaml`**
```yaml
name: Update Python dependencies

scms:
  default:
    kind: github
    spec:
      user: "{{ .github.user }}"
      email: "{{ .github.email }}"
      owner: "{{ .github.owner }}"
      repository: "{{ .github.repository }}"
      branch: main

sources:
  pip:
    name: Check for pip package updates
    kind: shell
    spec:
      command: pip index versions pip --pre 2>/dev/null | head -1 | grep -oP '\([\d.]+\)'

targets:
  requirements:
    name: Update requirements.txt
    kind: file
    sourceid: pip
    spec:
      file: requirements.txt
    scmid: default

actions:
  default:
    kind: github/pullrequest
    scmid: default
    spec:
      title: "chore(deps): update Python dependencies"
      labels:
        - dependencies
        - automated
```

### 5. Register the template in catalog config

Add the following entry to `catalog.locations` in **both** `app-config.yaml` and `app-config.production.yaml`:

For `app-config.yaml` (paths relative to `packages/backend`):
```yaml
    - type: file
      target: ../../examples/repo-template/template.yaml
      rules:
        - allow: [Template]
```

For `app-config.production.yaml` (paths relative to app root):
```yaml
    - type: file
      target: ./examples/repo-template/template.yaml
      rules:
        - allow: [Template]
```

### 6. Start the app

```
source .env && yarn dev
```

### 7. Verify

- Open the Backstage UI at http://localhost:3000
- Navigate to the Scaffolder page ("Create..." in the sidebar)
- Confirm the **New Repository with README** template is listed
- Optionally run it with a test repo to verify all files are generated correctly
