---
name: gitignore-setup
description: 'Adds or confirms a .gitignore for the stack using the github/gitignore templates, ensuring secrets, build output, publish/, .key/, and local DB files are never committed. Use when starting a repo, when the user asks about .gitignore, or when reviewing what should be ignored.'
---

# .gitignore Setup

Every app bundle already ships a stack-appropriate `.gitignore`. When starting a fresh repo (or one
without a bundle), add or confirm one. **Ask the user if they want a `.gitignore`** and generate it
from a trusted template rather than hand-rolling.

## Generate from a trusted template

- Base templates: **[github/gitignore](https://github.com/github/gitignore)** — e.g.
  `VisualStudio.gitignore` (.NET), `Python.gitignore`, `Node.gitignore`, `Dart.gitignore` (Flutter),
  and `Global/` editor/OS templates. Or use `gitignore.io` / the editor's built-in.
- **.NET:** `dotnet new gitignore` produces the canonical VS ignore file.

## Always ignore (add on top of the base template)

- **Secrets / env:** `.env`, `*.env.local`, `appsettings.*.local.json`, any credential files.
- **Signing keys:** `.key/*` (keep `!.key/README.md`), `*.jks`, `*.keystore`, `**/key.properties`.
- **Local release output:** `publish/` (this repo's convention for local builds).
- **Build output:** `bin/ obj/` (.NET), `dist/ .angular/ node_modules/` (Angular), `build/ .dart_tool/`
  (Flutter), `dist/ build/ .venv/ __pycache__/ .mypy_cache/ .ruff_cache/` (Python).
- **Local databases:** `*.db`, `*.db-shm`, `*.db-wal`, `*.sqlite`, `*.sqlite3` (unless a seed DB is
  intentionally versioned).
- **OS / editor cruft:** `.DS_Store`, `Thumbs.db`, `.idea/`, and `.vscode/*` except tracked
  `tasks.json` / `launch.json` / `extensions.json`.

## Checks

- Nothing under `publish/`, `.key/` (except its README), `.env`, or DB files is tracked.
- If a secret was already committed, add it to `.gitignore`, remove it from history, and rotate it.
- Keep one `.gitignore` per repository root; add nested `.gitignore` files only for local overrides.
