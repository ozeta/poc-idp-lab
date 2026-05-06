# [Backstage](https://backstage.io)

This is a scaffolded Backstage App with GitHub organization-based authentication.

## Prerequisites

- **GitHub OAuth App** — Create one in the [Oz-hubs organization settings](https://github.com/organizations/Oz-hubs/settings/applications/new)
  - **Homepage URL:** `http://localhost:3000`
  - **Authorization callback URL:** `http://localhost:7007/api/auth/github/handler/frame`
  - Note the **Client ID** and **Client Secret**

## Setup & Run

1. **Install dependencies:**
   ```sh
   yarn install
   ```

2. **Set environment variables** (create `.env.local` or export):
   ```bash
   export AUTH_GITHUB_CLIENT_ID=<your-client-id>
   export AUTH_GITHUB_CLIENT_SECRET=<your-client-secret>
   export GITHUB_TOKEN=<your-pat>
   ```

   **GITHUB_TOKEN must have these scopes:**
   - `read:user` — Read GitHub user profiles (required for sign-in)
   - `email` — Access user email addresses (required for sign-in)
   - `read:org` — Read organization members and teams (required for org catalog ingestion)

3. **Start the app:**
   ```sh
   yarn start
   ```

## Authentication

- **Only Oz-hubs members can sign in** — Authentication uses GitHub OAuth and restricts access to members of the `Oz-hubs` organization
- Org members are automatically ingested into the catalog as `User` and `Group` entities
- Users must have a matching GitHub username in the catalog to sign in (typically automatic for org members)
- Frontend is configured with a **GitHub-only SignIn page** (guest sign-in disabled)

## Architecture

- **Backend auth:** `@backstage/plugin-auth-backend-module-github-provider`
- **Catalog ingestion:** `@backstage/plugin-catalog-backend-module-github-org` (syncs Oz-hubs members/teams)
- **Frontend gating:** `@backstage/plugin-auth/alpha` (sign-in page shown for unauthenticated users)
- **Sign-in resolver:** `usernameMatchingUserEntityName` (GitHub username must exist as User entity)

## Notes

- `app-config.yaml` uses `auth.environment: development`, so GitHub auth is read from `auth.providers.github.development`
- GitHub org ingestion is configured via `catalog.providers.githubOrg` (not a catalog location)
- The bootstrap catalog URL should point to a raw YAML URL (for GitHub, `raw.githubusercontent.com`)
- After changing auth or catalog config, fully restart `yarn start`
