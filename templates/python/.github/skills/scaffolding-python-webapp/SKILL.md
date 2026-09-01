---
name: scaffolding-python-webapp
description: 'Scaffolds a server-rendered Python web application with templates using Django or Flask (Jinja2) with clean architecture. Use when building a Python web app with HTML pages/UI (not a pure JSON API) — dashboards, admin sites, CRUD web apps, or when the user mentions Django views/templates, Flask + Jinja2, or a full-stack Python website.'
---

# Scaffolding a Python Web App (Django / Flask + templates)

For UI-bearing, server-rendered web apps. If the app is only a JSON backend, use
[scaffolding-python-api](../scaffolding-python-api/SKILL.md). First load
[python-clean-architecture](../python-clean-architecture/SKILL.md).

## Ask the user first

**Framework:**
- **Django** — **preferred** for larger apps: batteries-included ORM, admin, auth, templates,
  migrations.
- **Flask + Jinja2** — lightweight, flexible, minimal for smaller sites.

Also ask the **database** (SQLite / PostgreSQL / SQL Server / Supabase — see the `sql` bundle's
`database-selection` skill). Django defaults to SQLite locally; use Postgres for production.

## Structure

Keep business logic out of Django views / Flask routes — they are the thin UI layer that calls
`application` use cases:

```
src/<project>/
  web/             views/routes, templates, static, forms, URL routing, app factory
  application/     use cases, service Protocols, orchestration
  domain/          entities, value objects, business rules (framework-free)
  persistence/     ORM models, repositories, migrations
  infrastructure/  email, storage, 3rd-party adapters
```

- Django: keep apps focused; put domain/application logic in plain modules, not fat models or views.
  Use Django forms for input validation; business rules in application/domain.
- Flask: use blueprints per feature; Jinja2 templates; `flask-wtf`/Pydantic for input validation.
- **No business logic in views/routes or templates.**

## UI conventions

- **Light/dark theme toggle (required):** persist the choice (cookie/session/user setting); recolor
  via CSS variables. Provide a visible toggle.
- **Google Material Symbols icons (required):** buttons show an icon where available and use **no
  trailing ellipsis** labels (`Save`, not `Save...`). Icons recolor with the theme.
- Accessibility: tooltips on icon-only buttons, keyboard focus, adequate contrast in both themes.
- Prefer a lightweight frontend approach (server-rendered + progressive enhancement, e.g. htmx) unless
  the user wants a heavier SPA — confirm first.

## Data, security & deployment

PostgreSQL via the ORM (Django ORM / SQLAlchemy) with migrations (Django migrations / Alembic);
parameterize any raw SQL; enums as strings. Layered validation (input → business → DB constraints).
Auth (Django auth / Flask-Login / OAuth / Supabase), HTTPS redirect, CSRF protection, secure headers,
secrets via env. Server: Gunicorn (Django/Flask) behind Caddy/Nginx with HTTPS. Structured logging,
`/health`, Sentry, DB backups. Containerize with Docker + docker-compose; deploy to Hetzner via Dokploy.

## Workflow

```
- [ ] 1. Create src/ package + pyproject.toml (deps, Ruff, mypy, pytest) + uv.lock; uv sync
- [ ] 2. App factory / Django project; composition root (DI); Pydantic settings; logging; auth
- [ ] 3. Base layout + theme toggle + Material Symbols icons; navigation
- [ ] 4. First feature slice end-to-end (view/route → application use case → domain → persistence)
- [ ] 5. Input validation, error handling, CSRF, structured logging
- [ ] 6. Tests (unit + integration); Docker; deploy config
```

## Docs

`README.md` (run/config/DB) + living `docs/`; `AGENTS.md` records the chosen framework, auth, and
layer rules. Keep docs current.
