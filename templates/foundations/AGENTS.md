# AGENTS.md — Foundations (licensing, .gitignore, Docker, hosting & deployment)

Cross-cutting project setup and operations that aren't tied to one language. This is an **overlay
bundle**: drop it alongside any app bundle. App scaffolders reference these skills when a project
starts (license + .gitignore) and when it's ready to run somewhere (Docker + hosting).

## Skills — load the one that matches the task

| Skill | Use when |
|-------|----------|
| [project-licensing](./.github/skills/project-licensing/SKILL.md) | Deciding open-source vs closed/commercial and adding a `LICENSE` |
| [gitignore-setup](./.github/skills/gitignore-setup/SKILL.md) | Adding/confirming a `.gitignore` for the stack |
| [docker-and-services](./.github/skills/docker-and-services/SKILL.md) | Containerizing local dev; adding Postgres/Redis/RabbitMQ/object storage |
| [choosing-hosting](./.github/skills/choosing-hosting/SKILL.md) | Picking where to host (managed PaaS vs VPS vs self-hosted PaaS) |
| [deploying-with-dokploy](./.github/skills/deploying-with-dokploy/SKILL.md) | Deploying to your own VPS via Dokploy/Coolify (self-hosted PaaS) |

## Agents

- [deployment-advisor](./.github/agents/deployment-advisor.agent.md) — read-only; recommends hosting +
  services based on scale, budget, and ops comfort.

## Ask early (at project start)

1. **License:** *is this open source or closed/commercial?* Add the matching `LICENSE` — don't assume
   MIT. See `project-licensing`.
2. **.gitignore:** confirm/extend one for the stack (app bundles already ship one). See `gitignore-setup`.

## Ask when it needs to run

3. **Docker?** Prefer Docker for local dev (Postgres parity); add Redis/RabbitMQ only when a concrete
   need appears. See `docker-and-services`.
4. **Hosting:** if the user has no server, recommend an option that fits their budget/ops comfort. See
   `choosing-hosting`.

## Defaults & principles

- **PostgreSQL** is the default database (run locally via Docker); SQLite only for embedded/prototype
  cases (see the `sql` bundle's `database-selection`).
- **Own your data**; avoid unnecessary vendor lock-in. Terminate TLS with a reverse proxy (Caddy
  auto-HTTPS, or Traefik/Nginx). Keep secrets in env / a secrets manager, never in git.
- Add infrastructure (Redis, RabbitMQ, background workers, k8s) **only when a concrete need exists**.

> This bundle is the canonical home for infra/deploy guidance. Older scattered notes (e.g. in
> `NET-PROJECT-SETUP.md` §1.15) are superseded by these skills — keep them consistent.
