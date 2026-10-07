---
name: scaffolding-python-desktop
description: 'Scaffolds a cross-platform Python desktop GUI using PySide6, Flet, or CustomTkinter with MVVM/MVP, light/dark theming, and Material Symbols icons. Use when building a Python desktop app or GUI, or when the user mentions PySide6, PyQt6, Flet, CustomTkinter, Tkinter, or a Python desktop application.'
---

# Scaffolding a Python Desktop App

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer or a scaffolder agent.

Cross-platform desktop GUI. First load
[python-clean-architecture](../python-clean-architecture/SKILL.md).

## Ask the user first

**Framework:**
- **PySide6** (official Qt for Python, LGPL) — **preferred** for rich desktop apps.
- **Flet** — Flutter-based, modern, easy theming (good if you want web/mobile too).
- **CustomTkinter** — lightweight, simple modern-looking apps.
- (PyQt6 — mature Qt binding, GPL/commercial — if the user asks.)

## Structure

```
src/<project>/
  gui/             windows/widgets (Views), view models/presenters, dialog service
  application/     use cases, service Protocols
  domain/          entities, value objects, business rules
  infrastructure/  DB, files, external APIs, DI wiring
```

- **Pattern: MVVM/MVP.** Windows/widgets are Views only; a ViewModel/Presenter holds state + commands
  and calls `application` services via DI. **No business logic in widget callbacks.**
- One screen = one View class/file; shared widgets extracted into their own classes; dialogs/file
  pickers behind an `IDialogService` Protocol.

## Light/dark mode toggle (required)

- **Qt (PySide6):** `qdarktheme` / qt-material, or swap a Fusion palette; `IThemeService` + a UI
  toggle; persist via `QSettings`.
- **Flet:** `page.theme_mode = ThemeMode.LIGHT/DARK` from a bound toggle.
- **CustomTkinter:** `customtkinter.set_appearance_mode("Light"/"Dark")`.

## Google Material Symbols icons (required)

- Buttons show an icon where available and use **no trailing ellipsis** labels (`Open`, not `Open...`).
- **Qt:** `qtawesome` (Material Design Icons) or bundle Material Symbols SVGs via `QIcon`/`QSvgRenderer`;
  tint icons to follow the theme.
- **Flet:** built-in `ft.Icons.*` (Material) — color follows the theme.
- Icon-only buttons need tooltips; ensure keyboard focus + contrast in both themes.

## Packaging (required)

- Release builds to a git-ignored `publish/` folder. Build a self-contained executable with
  **PyInstaller** (or Nuitka / Briefcase for GUI) so users need no Python install → `publish/<platform>/`.
- Zip each build named after its target, e.g. `publish/<project>-<version>-win-x64.zip`. Provide a
  `publish.ps1` / `publish.sh`. Cross-platform binaries must be built on each target OS / via CI.

## Workflow

```
- [ ] 1. Create src/ package + pyproject.toml (deps, Ruff, mypy, pytest) + uv.lock; uv sync
- [ ] 2. Composition root (DI); Pydantic settings; logging
- [ ] 3. Main window + navigation; IThemeService + theme toggle; Material Symbols icons
- [ ] 4. First feature: View + ViewModel/Presenter → application service (no logic in callbacks)
- [ ] 5. IDialogService, settings persistence, structured logging
- [ ] 6. Unit tests for application/domain; publish script + git-ignored publish/
```

## Local data (optional)

Desktop apps usually want local storage — **SQLite is the quick win**: stdlib `sqlite3` or SQLAlchemy
`sqlite:///app.db`, with the `.db` file in the user's app-data folder, accessed behind a repository
Protocol. See the `sql` bundle's `sqlite-conventions`.

## Docs

`README.md` (supported OSes + run/build) + living `docs/`; `AGENTS.md` documents MVVM/MVP + theming.
Keep current.
