---
name: deploying-with-dokploy
description: 'Deploys an app to your own VPS using Dokploy (or Coolify) — a self-hosted, open-source PaaS — with managed Postgres/Redis, auto-TLS, and backups. Use when self-hosting on Hetzner/DigitalOcean/etc., setting up Dokploy or Coolify, or wanting a Heroku-like deploy on a server you own.'
---

# Deploying with Dokploy (self-hosted PaaS)

Get a Heroku-like, git/Docker deploy experience on a cheap VPS you control. **Dokploy** is the default
here; **Coolify** is an equivalent alternative (same idea, similar steps). Prerequisite: a container
image (see [docker-and-services](../docker-and-services/SKILL.md)).

## Workflow

```
- [ ] 1. Provision a VPS (e.g. Hetzner Cloud, 2+ vCPU / 4+ GB) with a fresh Ubuntu LTS; point a domain's DNS at its IP
- [ ] 2. Install Dokploy (one-line installer from dokploy.com) — it sets up Docker + Traefik (auto-TLS)
- [ ] 3. Open the dashboard, create a project, connect the Git repo or a container registry
- [ ] 4. Add the app service (Dockerfile or buildpack); set env vars/secrets in the dashboard (never in git)
- [ ] 5. Add a Postgres (and Redis, if needed) service; attach a persistent volume; wire the connection string
- [ ] 6. Set the domain on the service; Traefik issues Let's Encrypt TLS automatically
- [ ] 7. Deploy; verify the health endpoint; enable auto-deploy on push
- [ ] 8. Configure scheduled database backups to object storage; set up basic monitoring/log retention
```

## Notes

- **TLS:** Dokploy/Coolify bundle Traefik and handle Let's Encrypt certificates — no manual Nginx
  needed for the common case. (Caddy is a fine standalone alternative if not using the dashboard.)
- **Database:** run Postgres as a Dokploy service with a persistent volume, or point at a managed
  Postgres (Supabase / Neon / provider RDS). **Always automate backups.**
- **Secrets:** store in the dashboard's env/secret store; keep them out of the image and git.
- **Scaling:** start on one server (app + Postgres + Redis co-located) — cheapest and simplest. Split
  services onto more nodes only when a concrete load need appears.
- **Portability:** because you deploy a Docker image to a server you own, moving hosts later is a
  re-provision, not a rewrite.

## Frontends

Angular / Flutter-web static builds can be served by the same VPS (a small Nginx/Caddy container) or
put on Vercel/Netlify/Cloudflare Pages — decide with [choosing-hosting](../choosing-hosting/SKILL.md).
