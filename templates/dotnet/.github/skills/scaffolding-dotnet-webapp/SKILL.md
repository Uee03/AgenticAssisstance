---
name: scaffolding-dotnet-webapp
description: 'Scaffolds a server-rendered .NET web application using Blazor, Razor Pages, or ASP.NET MVC with clean architecture. Use when building a .NET web app with UI/pages (not a pure JSON API) — dashboards, admin panels, CRUD web apps, or when the user mentions Blazor, Razor Pages, MVC views, or a full-stack .NET website.'
---

# Scaffolding a .NET Web App (Blazor / Razor / MVC)

For UI-bearing web apps (server-rendered pages/components), not pure JSON APIs. If the app is only a
JSON backend, use [scaffolding-dotnet-api](../scaffolding-dotnet-api/SKILL.md) instead. First load
[dotnet-clean-architecture](../dotnet-clean-architecture/SKILL.md).

## Ask the user first

**UI technology:**
- **Blazor** (interactive components; Server or WebAssembly render mode) — **preferred** for
  app-like, component-driven UIs sharing C# with the backend.
- **Razor Pages** — page-focused CRUD sites, simplest model.
- **ASP.NET MVC** — controller + view, conventional larger sites.

Confirm data + auth needs (same options as the API skill). Ask the **database** (SQLite / PostgreSQL /
SQL Server / Supabase — see the `sql` bundle's `database-selection` skill) before adding persistence.

## Structure

Keep the clean-architecture split; the web project is the thin UI/host layer:

```
src/
  <Project>.Web            Blazor/Razor/MVC host: components/pages, layouts, DI, auth
  <Project>.Application    use cases, validators, interfaces
  <Project>.Domain         entities, value objects, business rules
  <Project>.Persistence    EF Core / Dapper, repositories, migrations
  <Project>.Infrastructure email, storage, 3rd-party
```

- Pages/components stay thin — they bind to view models / call Application use cases via injected
  services. **No business logic in `.razor`/`.cshtml` code-behind.**
- Organize by feature (e.g. `Components/Features/<Feature>/`), not by technical folder.
- Validation: **FluentValidation** for input; business rules in Application/Domain; DB constraints.

## UI conventions

- **Light/dark theme toggle (required):** persist the choice; recolor via CSS variables / a theme
  service. Blazor: swap a CSS class / theme provider.
- **Google Material Symbols icons (required):** buttons show an icon where available and use **no
  trailing ellipsis** labels (`Save`, not `Save...`). Icons recolor with the theme.
- Accessibility: tooltips on icon-only buttons, keyboard focus, adequate contrast in both themes.
- Prefer a component library that fits the UI tech (e.g. MudBlazor / Fluent UI for Blazor) rather than
  hand-rolling everything — confirm with the user.

## Data, security & deployment

Same as the API skill: PostgreSQL via Npgsql/EF Core/Dapper (parameterize SQL, enums as strings),
layered validation, auth (ASP.NET Identity / OAuth / Supabase), HTTPS/HSTS, CORS, secure headers,
secrets via env. Containerize with Docker + docker-compose; deploy to Hetzner via Dokploy behind
Caddy/Nginx with HTTPS. Structured logging (Serilog), `/health`, backups.

## Workflow

```
- [ ] 1. Create solution + projects (Web, Application, Domain, Persistence, Infrastructure)
- [ ] 2. Directory.Packages.props + Directory.Build.props; DI composition root; auth
- [ ] 3. Layout + theme toggle + Material Symbols icons; base navigation
- [ ] 4. First feature slice end-to-end (page/component → Application use case → Domain → Persistence)
- [ ] 5. Validation, error handling, logging
- [ ] 6. Tests (unit + integration); Docker; deploy config
```

## Docs

`README.md` (run/config/DB) and `AGENTS.md` (chosen UI tech, auth, layer rules). Keep docs current.
