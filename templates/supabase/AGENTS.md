# AGENTS.md — Supabase

Guidance for AI agents integrating **Supabase** (managed Postgres + Auth + Storage + Realtime + Edge
Functions). This is an **overlay bundle**: drop it alongside a backend and/or frontend bundle. Read
this first, then load the skill that matches the task.

## Golden rules (read before writing any code)

- **Never expose the `service_role` key to a client** (browser/mobile/Flutter/Angular). It bypasses
  Row Level Security. Clients use the **anon** key only; `service_role` stays on a trusted server.
- **Enable Row Level Security (RLS) on every table** with user data, and add explicit policies. RLS is
  the security boundary — do not rely on client checks alone.
- Secrets (`service_role`, DB password, JWT secret) come from env / a secrets manager — never committed.

> [!IMPORTANT]
> **STOP — mandatory project intake.** On any request to add or set up Supabase, first complete
> [project-intake](./.github/skills/project-intake/SKILL.md) and get the user's explicit confirmation
> **before** creating or modifying any file, running migrations, adding keys, or running commands. Do
> not assume defaults — getting keys or RLS wrong is a security problem.

## Skills — load the one that matches the task

| Skill | Use when |
|-------|----------|
| [project-intake](./.github/skills/project-intake/SKILL.md) | **Always first** on a new integration — confirm stack, keys, RLS tenancy before wiring anything |
| [supabase-setup](./.github/skills/supabase-setup/SKILL.md) | Initializing Supabase, local dev (CLI), linking, migrations, keys/env |
| [supabase-auth](./.github/skills/supabase-auth/SKILL.md) | Adding authentication, sessions, providers, server vs client keys |
| [supabase-database-and-rls](./.github/skills/supabase-database-and-rls/SKILL.md) | Designing tables + writing/reviewing RLS policies |
| [supabase-storage](./.github/skills/supabase-storage/SKILL.md) | Buckets, upload/download, storage access policies, signed URLs |

## Agents

- [supabase-scaffolder](./.github/agents/supabase-scaffolder.agent.md) — sets up Supabase in a project.

Path-scoped rules: [.github/instructions/supabase-conventions.instructions.md](./.github/instructions/supabase-conventions.instructions.md).

## Local development

Uses the Supabase CLI + Docker. Copy `.env.example` to `.env` (git-ignored). Common flow (see the
setup skill and the VS Code tasks):

```bash
supabase init
supabase start                 # local stack (Postgres, Auth, Storage, Studio)
supabase migration new <name>  # author schema changes as migrations
supabase db reset              # re-apply all migrations locally
supabase db push               # apply migrations to the linked remote project
```

## Relationship to the SQL bundle

Supabase **is** PostgreSQL. Follow the `sql` bundle's schema-design, Postgres conventions, and
migration rules; this bundle adds Supabase-specific concerns (RLS, Auth, Storage, keys, CLI). Manage
schema through **Supabase migrations**, not Studio clicks in production.

## Always do

- RLS enabled + policies on every user-data table; test policies with different roles.
- anon key on clients; `service_role` only server-side; validate JWTs where you trust them.
- Schema via migrations committed to git; generate typed clients where supported.
- Storage buckets private by default; grant access via policies / signed URLs.

## Never do

- Ship `service_role` (or the DB password / JWT secret) to any client or commit them.
- Leave a table without RLS "temporarily"; disable RLS to make something work.
- Manage production schema by hand in Studio instead of migrations.
