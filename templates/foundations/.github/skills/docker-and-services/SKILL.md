---
name: docker-and-services
description: 'Containerizes local development and adds backing services — PostgreSQL, Redis, RabbitMQ, object storage — via Docker Compose, plus production Dockerfile best practices. Use when the user wants Docker, a local database/cache/queue, docker-compose, or a container image for deployment.'
---

# Docker & Backing Services

## Ask the user

> "Do you want to use **Docker** for local development? (Recommended — a local Postgres in
> docker-compose matches production. Alternatives: Podman, Rancher Desktop, OrbStack.)"

Default to **yes** for anything with a database. Add extra services **only when a concrete need
exists** — don't provision Redis/RabbitMQ speculatively.

## Local services (docker-compose)

Start with just the database; add others as needs appear:

| Service | Add when | Image |
|---------|----------|-------|
| **PostgreSQL** | Default database (recommended even for small apps) | `postgres:17` |
| **Redis** | Caching, sessions, rate limits, or a light job queue | `redis:7` |
| **RabbitMQ** | Reliable async messaging / a real message broker between services | `rabbitmq:3-management` |
| **MinIO** | Local S3-compatible object storage (files/images) | `minio/minio` |

The `sql` bundle ships a ready `docker-compose.yml` for Postgres (and SQL Server). Extend it with the
services above as required. Put credentials in `.env` (git-ignored) and reference with `${VAR}`; add
`healthcheck`s and named volumes for persistence.

## Production Dockerfile best practices

- **Multi-stage build:** build in an SDK image, copy only the artifact into a small runtime image
  (`mcr.microsoft.com/dotnet/aspnet` for .NET, `python:3.x-slim` for Python, `nginx` to serve an
  Angular/Flutter-web `dist`).
- **Run as non-root**; set a fixed `WORKDIR`; pin base image tags (avoid `latest`).
- Add a **`.dockerignore`** (exclude `.git`, `node_modules`, `bin/obj`, `.venv`, `publish/`, `.env`).
- Expose a health endpoint; read config/secrets from env; don't bake secrets into the image.
- Keep images small and layers cache-friendly (copy manifests + restore before copying source).

## Handoff to hosting

Once containerized, deploy the image via a platform from
[choosing-hosting](../choosing-hosting/SKILL.md) — e.g. self-host with
[deploying-with-dokploy](../deploying-with-dokploy/SKILL.md), which can also run Postgres/Redis as
managed services next to the app.
