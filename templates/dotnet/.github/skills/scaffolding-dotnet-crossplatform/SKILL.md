---
name: scaffolding-dotnet-crossplatform
description: 'Scaffolds a cross-platform .NET app (Windows/Linux/macOS/mobile) using Avalonia or .NET MAUI with MVVM, or a cross-platform CLI. Use when building a .NET GUI that must run on more than Windows, or when the user mentions Avalonia, MAUI, cross-platform desktop/mobile, or a console/CLI tool in .NET.'
---

# Scaffolding a Cross-platform .NET App (Avalonia / MAUI / CLI)

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer or a scaffolder agent.

Runs beyond Windows. First load [dotnet-clean-architecture](../dotnet-clean-architecture/SKILL.md).

## Ask the user first

**Target:**
- **Avalonia** — **preferred** for cross-platform desktop (Win/Linux/macOS) and optionally mobile;
  XAML + MVVM.
- **.NET MAUI** — mobile-first (Android/iOS) + Windows/macOS desktop.
- **CLI** — console tool (see the CLI section below).

## Avalonia

- **SDK:** Avalonia (latest, **12.x**), `net10.0`, MVVM template layout.
- **Pattern:** MVVM with **CommunityToolkit.Mvvm**. One View (`.axaml` + minimal code-behind) and one
  ViewModel per screen; ViewModels contain no framework/UI types and call `.Core` services via DI. Use
  a `ViewLocator` to map ViewModels → Views. Enable **compiled bindings**
  (`AvaloniaUseCompiledBindingsByDefault=true`, `x:DataType` on views).
- **DI:** register services + ViewModels in a composition root; resolve the main window/VM at startup
  in `App.axaml.cs` `OnFrameworkInitializationCompleted`.
- **Dialogs/IO:** abstract behind `IDialogService` / `IStorageService` (wrap Avalonia `StorageProvider`).
- **Theme (required):** Avalonia `FluentTheme` with `RequestedThemeVariant` = `Light`/`Dark`; an
  `IThemeService` + UI toggle flips `Application.Current.RequestedThemeVariant` and persists it.
- **Icons (required):** `Material.Icons.Avalonia` (`<icons:MaterialIcon Kind="..."/>`) bound to theme
  brushes, or Material Symbols SVGs via `Avalonia.Svg.Skia`. Buttons show icons, **no trailing
  ellipsis** labels.
- **Heads:** desktop-only → single `Desktop` head; if mobile is planned, split into a shared library +
  `.Desktop` / `.Android` / `.iOS` heads. On Android, use SAF folder pickers (Avalonia
  `OpenFolderPickerAsync`); Google Drive loopback OAuth won't work on Android.

## .NET MAUI

- **SDK:** `net10.0-android;net10.0-ios;net10.0-maccatalyst;net10.0-windows` as needed.
- **Pattern:** MVVM with **CommunityToolkit.Mvvm** + CommunityToolkit.Maui. One View (XAML) + one
  ViewModel per page; ViewModels call `.Core` services via DI. Use adaptive single-column layouts for
  phones. Theme via `AppThemeBinding` + a toggle; Material Symbols icons that recolor with the theme.

## CLI

- **SDK:** `Microsoft.NET.Sdk`, `OutputType=Exe`, `net10.0`. Use **`System.CommandLine`** for
  args/subcommands/help and `Host.CreateApplicationBuilder` (Generic Host) for DI/config/logging.
- **Structure:** `Program.cs` builds the host + root command; `Commands/` has one class per command,
  each depending on `.Core` via constructor injection. Command classes contain **no business logic**.
- **Output:** **Spectre.Console** for tables/prompts/progress; respect `--no-color` and the terminal's
  light/dark background.

## Packaging (required)

Release builds to a git-ignored `publish/` folder; prefer self-contained single-file per runtime:

```bash
dotnet publish src/<Project>.App -c Release -r linux-x64 --self-contained true -p:PublishSingleFile=true -o publish/linux-x64
dotnet publish src/<Project>.App -c Release -r osx-arm64 --self-contained true -p:PublishSingleFile=true -o publish/osx-arm64
dotnet publish src/<Project>.App -c Release -r win-x64   --self-contained true -p:PublishSingleFile=true -o publish/win-x64
```

Zip each build named after its target (`...-linux-x64.zip`, `...-osx-arm64.zip`). Provide
`publish.ps1` / `publish.sh`. (MAUI mobile: build AAB/IPA with signing.)

## Workflow

```
- [ ] 1. Choose target; create solution + projects (Core, Infrastructure, App/heads)
- [ ] 2. Directory.Packages.props + Directory.Build.props; DI composition root
- [ ] 3. Shell/navigation; IThemeService + theme toggle; Material Symbols icons (GUI targets)
- [ ] 4. First feature: View + ViewModel → Core service (no logic in code-behind)
- [ ] 5. Dialogs/storage abstractions; settings; logging
- [ ] 6. Unit tests for Core/ViewModels; publish script + git-ignored publish/
```

## Docs

`README.md` (supported OSes + run commands) and `AGENTS.md` (MVVM/ViewLocator/theming). Keep current.
