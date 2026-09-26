---
name: project-intake
description: 'Mandatory pre-integration intake for adding Supabase to a project. ALWAYS run this before creating or modifying any file — confirm the target stack, whether a trusted server exists, local vs hosted Supabase, auth providers, data model + RLS tenancy, storage needs, and key/env handling, then get explicit confirmation before wiring anything. Use at the very start of any "add / set up Supabase" request.'
---

# Project intake (Supabase) — do this before wiring anything

**Hard gate.** Do NOT create files, run migrations, add clients/keys, or run commands until every
question below is answered and you have echoed the choices back and received an explicit "yes".
Never assume defaults — ask. Getting keys or RLS wrong is a security problem, so confirm first.

## How to run it

1. Ask the questions below **in one message** (grouped) so the user can answer quickly.
2. For anything left blank, state the default you would use and ask them to confirm it.
3. Post the **Intake summary** block with every value filled in.
4. Wait for explicit confirmation. Only then load the matching Supabase skill and wire it in.

## Questions

1. **Target stack** — Angular · Flutter · .NET · Python (which app is this overlaying)?
2. **Trusted server?** — is there a server/backend that can hold the `service_role` key, or is this a
   client-only app (browser/mobile) that must use the **anon** key exclusively?
3. **Supabase environment** — local dev via CLI + Docker, a hosted project, or both (link later)?
4. **Auth** — email/password · magic link · which OAuth providers? Sessions handled where?
5. **Data model & tenancy** — main tables, and the RLS boundary: per-user (`auth.uid()`) or
   per-org/tenant? (Every user-data table gets RLS enabled with explicit policies.)
6. **Storage** — any file/image/document buckets? Public or private (signed URLs)?
7. **Realtime / Edge Functions** — needed now, or later?
8. **Keys & env** — confirm `.env` is git-ignored; `service_role` server-only; anon key on clients.

## Intake summary (fill in, then confirm)

```text
Target stack : <Angular | Flutter | .NET | Python>
Trusted srv  : <yes (service_role server-side) | no (anon key only)>
Environment  : <local CLI | hosted | both>
Auth         : <email/password | magic link | OAuth: ...>
Tenancy/RLS  : <per-user auth.uid() | per-org/tenant>
Storage      : <none | buckets: ... (public|private)>
Realtime/Edge: <none | ...>
Keys/env     : <.env git-ignored; service_role server-only; anon on clients — confirmed>
```

> Only after the user confirms this summary do you load the matching `supabase-*` skill and wire
> Supabase in. Record the confirmed choices in `AGENTS.md` / the host project's `AGENTS.md`.
