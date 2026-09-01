---
name: supabase-setup
description: 'Initializes Supabase in a project — CLI install, local dev stack, project linking, migrations, config, and safe key/env handling. Use when adding Supabase to an app, setting up local Supabase development, or wiring the Supabase client into a .NET/Python/Flutter/Angular project.'
---

# Supabase Setup

## Keys & environment (get this right first)

Supabase gives you three values plus secrets:

| Value | Where it may live | Notes |
|-------|-------------------|-------|
| Project URL | client + server | Safe to ship |
| `anon` key | client + server | Safe to ship; RLS still applies |
| `service_role` key | **server only** | Bypasses RLS — never send to a client, never commit |
| DB password / JWT secret | **server only** | Secrets manager / env only |

Store them per `.env.example`. Clients read only URL + anon key.

## Local development (CLI + Docker)

```bash
# install the CLI (see supabase.com/docs), then:
supabase init            # creates supabase/ (config.toml, migrations/)
supabase start           # local Postgres + Auth + Storage + Studio (needs Docker)
supabase status          # shows local URL + anon/service_role keys for dev
```

Link to a hosted project when ready:

```bash
supabase login
supabase link --project-ref <ref>
```

## Schema as migrations (not Studio clicks)

```bash
supabase migration new create_customers
# edit supabase/migrations/<ts>_create_customers.sql
supabase db reset        # re-apply all migrations locally
supabase db push         # apply to the linked remote project
```

Follow the `sql` bundle's Postgres conventions + migration rules. **Enable RLS** in the same migration
that creates a user-data table (see [supabase-database-and-rls](../supabase-database-and-rls/SKILL.md)).

## Client libraries

- **JavaScript/Angular:** `@supabase/supabase-js` — create one client with URL + anon key; wrap it in
  an Angular service (inject it). Never put `service_role` in the browser.
- **Flutter:** `supabase_flutter` — initialize in `main()` with URL + anon key; wrap calls in a Service.
- **.NET:** `supabase-csharp` for direct access, or (recommended for a backend) treat Supabase as your
  Postgres via Npgsql/EF and use the service key only on the server.
- **Python:** `supabase` (supabase-py) on a server, or connect to the Postgres directly.

Generate typed models where supported (`supabase gen types` for TypeScript) to keep client code typed.

## Workflow

```
- [ ] 1. supabase init + start; copy .env.example -> .env with local keys
- [ ] 2. Author schema as migrations (tables + RLS enabled + policies)
- [ ] 3. Wire the client (anon key) into the app via a Service/wrapper
- [ ] 4. Add Auth (see supabase-auth) and Storage (see supabase-storage) as needed
- [ ] 5. Link remote project; db push; verify RLS with different roles
```
