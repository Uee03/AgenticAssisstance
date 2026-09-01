---
name: choosing-hosting
description: 'Recommends where to host an app when the user has no server — managed PaaS (Heroku alternatives), raw VPS/cloud, or self-hosted PaaS (Hetzner + Dokploy/Coolify). Use when deploying, choosing a host/server, comparing PaaS vs VPS, or asking where to run a backend/frontend/database.'
---

# Choosing Where to Host

If the user has no server, recommend an option that fits their **budget, scale, and ops comfort**.
There are three camps — pick based on how much infrastructure they want to own.

## 1. Managed PaaS — git-push, zero server maintenance ("Heroku alternatives")

Push code, they build/run it and provide managed databases. Simplest, but you rent the platform (some
lock-in). Note: **Heroku entered "sustaining mode" in 2026** — start on a modern alternative instead.

- **Railway** — fastest, best DX; ideal for MVPs/side projects/early startups.
- **Render** — "new Heroku"; polished, managed Postgres/Redis, preview envs; great for small teams.
- **Fly.io** — runs containers on bare metal across many regions; best for global low-latency.
- **DigitalOcean App Platform** — PaaS backed by a stable cloud; predictable pricing.
- Frontends (Angular / Flutter web static builds): **Vercel**, **Netlify**, or **Cloudflare Pages**.

## 2. Raw VPS / cloud — you manage the server ("Hetzner alternatives")

Cheapest per unit of compute; you handle Linux, firewall, Docker, updates.

- **Hetzner Cloud** — best price/performance; strong default recommendation.
- **DigitalOcean**, **Vultr**, **Akamai/Linode**, **Scaleway**, **OVH**, **Hostinger VPS**.
- Hyperscalers (**AWS**, **GCP**, **Azure**) — for enterprises/existing-cloud teams with DevOps staff.

## 3. Self-hosted PaaS — the "sweet spot" (Hetzner + open-source dashboard)

Rent a cheap, powerful VPS and install a free dashboard to get the Heroku experience at VPS cost, with
full ownership of your data.

- **Dokploy** or **Coolify** — open-source PaaS dashboards (git/Docker deploys, managed Postgres/Redis,
  auto-TLS). **Recommended default** for cost + control. See
  [deploying-with-dokploy](../deploying-with-dokploy/SKILL.md).
- **Dokku** / **CapRover** (single-server PaaS), **Kamal** (deploy Docker to your own servers),
  **Cloud 66** (managed deploys onto infrastructure you own).

## How to recommend

| Situation | Recommend |
|-----------|-----------|
| MVP / side project / fastest to live | Railway or Render |
| Small team, want managed + simple | Render (or DigitalOcean App Platform) |
| Global users / low latency | Fly.io |
| Cost-conscious + willing to own infra | **Hetzner + Dokploy/Coolify** (sweet spot) |
| Enterprise / already on a hyperscaler | AWS / GCP / Azure |
| Static frontend only | Vercel / Netlify / Cloudflare Pages |

## Always

- Terminate TLS with a reverse proxy (**Caddy** auto-HTTPS is simplest; Traefik/Nginx for more control;
  Dokploy/Coolify include this).
- Keep secrets in the platform's env/secret store; automate **database backups**; use a managed
  Postgres or a backed-up self-hosted one.
- Prefer options that keep your app portable (Docker image + Postgres) so you can move hosts later.
