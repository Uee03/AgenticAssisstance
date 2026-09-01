---
name: scaffolding-python-api
description: 'Scaffolds a Python JSON API / SaaS backend with clean architecture, PostgreSQL, Pydantic validation, auth, and OpenAPI (FastAPI preferred). Use when building a Python REST/JSON API, microservice, or backend, or when the user mentions FastAPI, Flask API, Django REST, endpoints, or a Python web service.'
---

# Scaffolding a Python API

Builds a JSON API / backend. First load
[python-clean-architecture](../python-clean-architecture/SKILL.md).

## Ask the user first (do not assume)

1. **Framework:** **FastAPI** (preferred — async, Pydantic validation, auto OpenAPI) · Flask
   (lightweight, sync) · Django + DRF (batteries-included, ORM/admin). Route handlers stay thin and
   delegate to `application` use cases via DI.
2. **API doc UI:** FastAPI ships Swagger UI + ReDoc automatically; or serve **Scalar** over the
   generated OpenAPI. Django/Flask: drf-spectacular / flasgger / apispec. Always expose the OpenAPI spec.
3. **Database:** SQLite (quick win / local / small) · PostgreSQL (default for services) · SQL Server ·
   Supabase. If unsure, load the `sql` bundle's `database-selection` skill and ask before adding persistence.

## Layout

```
src/<project>/
  api/             routers/controllers, middleware, DI wiring, app factory, OpenAPI
  contracts/       Pydantic request/response schemas (no domain import)
  application/     use cases (commands/queries), service Protocols, orchestration
  domain/          entities, value objects, enums, business rules (framework-free)
  persistence/     SQLAlchemy models, repositories, migrations (Alembic), SQL
  infrastructure/  email, object storage, PDF, payment, 3rd-party adapters
```

- Organize `application` **by feature / vertical slice**:
  `application/features/<feature>/{create,update,delete,get,search}.py` with shared bits under
  `application/common/`. **CQRS-lite:** command (write) and query (read) objects; mediator optional.
- Value objects (`frozen=True` dataclasses/Pydantic) in `domain/value_objects/` — don't wrap every primitive.

## Validation (layered)

- **Input** — Pydantic schemas in `contracts` (required, types, lengths, formats). No business rules here.
- **Business** — application/domain (entity exists, tenant ownership, state allows operation).
- **Database** — constraints (PK/FK/unique/not-null/indexes).

## Data access

- **PostgreSQL** (recommended default) via **psycopg (v3)** / **asyncpg**. ORM: **SQLAlchemy 2.x**
  (typed) + **Alembic** migrations; use **SQLModel** to combine Pydantic + SQLAlchemy. Raw SQL for
  complex reads — **always parameterize**, never f-string user input into SQL.
- **SQLite** — only for a local/prototype quick start: SQLAlchemy `sqlite+aiosqlite:///app.db` (or
  stdlib `sqlite3`); Alembic still applies. Swap to Postgres later behind the repository. See `sqlite-conventions`.
- Serialize **enums as strings** (`"status": "paid"`, not `2`). Consider **Supabase** where it fits.

## Multi-tenancy (if multiple tenants)

Carry `tenant_id`/`company_id` on tenant-owned tables; every request establishes tenant context and
the backend **prevents cross-tenant access**. Security requirement, not a UI concern.

## Security & ops (suggest to the user)

AuthN/AuthZ (OAuth2/OIDC, JWT via `authlib`/`python-jose`, session, or Supabase Auth) · HTTPS redirect
· CORS · rate limiting (`slowapi`/proxy) · secure headers · secrets via env · audit logging · DB
backups. Scan with `pip-audit`/`safety` (deps) + `bandit` (code) + Dependabot/CodeQL. Reverse
proxy/TLS: **Caddy** first, or Nginx/Traefik. Observability: `structlog`, OpenTelemetry, `/health`,
Sentry. Server: **Uvicorn** (ASGI) behind Gunicorn workers for FastAPI; Gunicorn for Flask/Django.
Background jobs (Celery/RQ/Dramatiq + Redis) and caching (Redis) only when a concrete need appears.

## Consistent error format (standardize before frontend work; never leak tracebacks)

```json
{ "code": "company.not_found", "message": "Company was not found.", "details": [] }
```

## Abstractions & storage

Put email, PDF, and file/object storage behind Protocols in `application`; implement in
`infrastructure`. Don't store large files in Postgres — use S3-compatible / Hetzner Object Storage.
Call external HTTP APIs with **`httpx`** (explicit timeouts, reused client) behind an adapter.

## Deployment

Containerize with Docker (+ docker-compose for local API + Postgres + optional Redis). Deploy to
**Hetzner Cloud** via **Dokploy** (or Fly.io/Railway/Render) behind the reverse proxy with HTTPS.

## Workflow

```
- [ ] 1. Create src/ package + pyproject.toml (deps, Ruff, mypy, pytest) + uv.lock; uv sync
- [ ] 2. Composition root (DI), Pydantic settings, structured logging
- [ ] 3. Domain for first feature; application use cases + Pydantic contracts
- [ ] 4. Persistence: SQLAlchemy models, repositories, Alembic migration (parameterized)
- [ ] 5. Api: routers, auth, error handling, OpenAPI export
- [ ] 6. Tests (unit + integration); Docker + docker-compose; deploy config
```

## Docs

`README.md` (run/config/DB) + living `docs/`; `AGENTS.md` records framework, doc UI, layer rules.
Document every endpoint and export the OpenAPI spec; keep updated as endpoints change.
