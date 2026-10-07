---
name: scaffolding-dotnet-api
description: 'Scaffolds a .NET REST/JSON Web API or SaaS backend with clean architecture, PostgreSQL, validation, auth, and OpenAPI. Use when building a .NET Web API, HTTP service, microservice, or backend, or when the user mentions ASP.NET API, controllers, FastEndpoints, endpoints, or REST service in .NET.'
---

# Scaffolding a .NET Web API

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer or a scaffolder agent.

Builds a `Microsoft.NET.Sdk.Web`, `net10.0` backend. First load
[dotnet-clean-architecture](../dotnet-clean-architecture/SKILL.md) for the layer layout and rules.

## Ask the user first (do not assume)

1. **API style:** Controllers or FastEndpoints. Do not scaffold before the user chooses.
   - **Controllers:** attribute-routed `ControllerBase` classes, small and cohesive. Prefer for an
     existing MVC/controller estate, teams using MVC action filters or data annotations, or when an
     external endpoint framework is undesirable.
   - **FastEndpoints:** one REPR endpoint class per operation, co-located with its request, response,
     and validator. Prefer for a greenfield API expected to grow and a team that wants enforced
     feature-slice structure. Add `FastEndpoints`, `builder.Services.AddFastEndpoints()`, and
     `app.UseFastEndpoints()`. Use FluentValidation; FastEndpoints does not use Data Annotations
     validation.
   - In either style, endpoints stay thin, use constructor-injected Application use cases, and expose
     Contracts DTOs rather than Domain entities. Do not mix styles in a new API.
2. **API doc UI:** Swagger / Swashbuckle · Scalar. Either way, generate an OpenAPI document.
3. **Database:** SQLite (quick win / local / small) · PostgreSQL (default for services) · SQL Server ·
   Supabase. If unsure, load the `sql` bundle's `database-selection` skill and ask before adding persistence.

## Workflow

```
- [ ] 1. Create the solution + projects (Api, Contracts, Application, Domain, Persistence, Infrastructure, SharedKernel)
- [ ] 2. Add Directory.Packages.props + Directory.Build.props; wire DI composition root
- [ ] 3. Model the Domain (entities, value objects) for the first feature
- [ ] 4. Add Application use cases (Commands/Queries), FluentValidation validators, interfaces
- [ ] 5. Persistence: schema, migrations, repositories (parameterized SQL)
- [ ] 6. Api: endpoints, auth, error handling, OpenAPI export
- [ ] 7. Tests (unit + integration + architecture)
- [ ] 8. Docker + docker-compose (API + Postgres); publish/CI later
```

## Organization

- Application layer organized **by feature / vertical slice**:
  `Application/Features/<Feature>/{Create,Update,Delete,Get,Search}` with shared bits under
  `Application/Common/{Interfaces,Behaviors,Exceptions,Extensions}`.
- **CQRS (pattern, not a library):** separate Command (state-changing) and Query (read) objects with
  your own `ICommand`/`IQuery` + handler interfaces and decorators — **do not add MediatR**. Inject the
  specific handler into the endpoint and call it directly. Use CQRS where the domain warrants it; for a
  simple CRUD domain a plain data-access layer is better. See the
  [dotnet-cqrs](../dotnet-cqrs/SKILL.md) skill for the abstractions, decorators, and DI wiring.
- Value objects (`Money`, `Address`) in `Domain/ValueObjects` — don't wrap every primitive.

## Validation (layered)

- **Input** — `FluentValidation` (required, lengths, formats, ranges). No core business rules here.
- **Business** — Application/Domain (entity exists, tenant ownership, state allows the operation).
- **Database** — constraints (PK/FK/unique/not-null/indexes).

## Request handling (both API styles)

- Accept and propagate `CancellationToken`; keep data access and external I/O asynchronous. Never use
  `.Result`, `.Wait()`, or `Task.Run` to make ordinary request work appear asynchronous.
- Page and project collection queries; avoid buffering unbounded collections or large bodies. Use
  `IHttpClientFactory` for outbound HTTP clients.
- `HttpContext` is request-scoped and not thread-safe: do not capture it or scoped services for
  background work. Use a hosted service and create a fresh DI scope for long-running work.

## Data access

- **PostgreSQL** (recommended default) via **Npgsql**. Prefer **Dapper** for read-heavy/SQL work;
  **EF Core** for simple CRUD/migrations/change tracking. Both may coexist. **Always parameterize SQL**
  (never string-build from input) — see the `sql` bundle's `efcore-data-access` skill for EF Core
  code-first, EF raw SQL, and Dapper/ADO.NET parameterization patterns.
- **SQLite** — only for a local/prototype quick start: EF Core `Microsoft.EntityFrameworkCore.Sqlite`;
  swap to Postgres later behind the repository interface. See the `sql` bundle's `sqlite-conventions`.
- Serialize **enums as strings** in responses (`"status": "Paid"`, not `2`). Consider **Supabase** for
  managed Postgres/auth/storage where it fits.

## Multi-tenancy (if multiple tenants)

Carry `TenantId`/`CompanyId` on tenant-owned tables; every request establishes tenant context and the
backend **prevents cross-tenant access**. This is a security requirement, not a UI concern.

## Security & ops (suggest to the user)

AuthN/AuthZ (JWT bearer, ASP.NET Identity, OAuth/OIDC, or Supabase Auth) · HTTPS/HSTS redirect · CORS
policy · rate limiting (`Microsoft.AspNetCore.RateLimiting`) · secure headers · secrets via env /
user-secrets · audit logging · DB backups. Scan with `dotnet list package --vulnerable`, Dependabot,
CodeQL. Reverse proxy/TLS: **Caddy** (auto-HTTPS) first, or Nginx/Traefik/YARP. Observability: Serilog
structured logging (request/user/tenant id, duration — never secrets/PII), OpenTelemetry, `/health`.
Background jobs (Hangfire) and caching (Redis) only when a concrete need appears.

## Consistent error format (standardize before frontend work; never leak internal exceptions)

```json
{ "code": "company.not_found", "message": "Company was not found.", "details": [] }
```

## Abstractions & storage

Put `IEmailService`, PDF generation, and file/object storage behind interfaces in Application;
implement in Infrastructure. Don't store large files in Postgres — use S3-compatible / Hetzner Object
Storage.

## Deployment

Containerize with Docker (+ `docker-compose` for local API + Postgres + optional Redis). Deploy to
**Hetzner Cloud** via **Dokploy** (or Fly.io/Railway/Render) behind the reverse proxy with HTTPS. Keep
initial infra small.

## Endpoint documentation (required)

Document every endpoint — route, method, request/response DTOs, status codes, auth — in code (XML
docs / OpenAPI annotations) and in the living docs, and **export the OpenAPI spec** for third parties.

## Docs

`README.md` covers run/config/DB setup. `AGENTS.md` records the chosen API style, doc UI, and layer
rules; keep endpoint docs + OpenAPI spec updated as endpoints change. For FastEndpoints, document
the REPR/feature-slice convention and the `AddFastEndpoints`/`UseFastEndpoints` pipeline setup.
