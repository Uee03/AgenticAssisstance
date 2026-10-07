---
name: scaffolding-dotnet-desktop
description: 'Scaffolds a Windows desktop .NET app using WinForms or WPF with MVVM/MVP, light/dark theming, and Material Symbols icons. Use when building a Windows-only desktop GUI in .NET, or when the user mentions WinForms, WPF, a desktop app, or a Windows GUI. For cross-platform desktop use the crossplatform skill instead.'
---

# Scaffolding a .NET Desktop App (WinForms / WPF)

**Best model:** Act tier (GPT-6.1 Sol) via the Implementer or a scaffolder agent.

Windows-only desktop GUI. For Windows + Linux + macOS use
[scaffolding-dotnet-crossplatform](../scaffolding-dotnet-crossplatform/SKILL.md). First load
[dotnet-clean-architecture](../dotnet-clean-architecture/SKILL.md).

## Ask the user first

**UI technology:** **WPF** (XAML, data binding, MVVM — **preferred** for new desktop apps) or
**WinForms** (mature, simplest, MVP pattern).

## SDK

- **WPF:** `net10.0-windows`, `<UseWPF>true</UseWPF>`, `OutputType=WinExe`.
- **WinForms:** `net10.0-windows`, `<UseWindowsForms>true</UseWindowsForms>`, `OutputType=WinExe`.

## Pattern

- **WPF → MVVM** with **CommunityToolkit.Mvvm** (`ObservableObject`, `[ObservableProperty]`,
  `[RelayCommand]`). One View (`.xaml` + minimal code-behind) and one ViewModel per screen; ViewModels
  hold no framework/UI types and call `.Core` services via DI.
- **WinForms → MVP.** Forms are Views only, implementing an `IView` interface (events + properties); a
  **Presenter** holds logic and talks to services. **No business logic in `.cs` code-behind.**
- Wire Presenters/ViewModels and services through the DI container built in `Program.cs`/`App.xaml.cs`.
- Dialogs/message boxes and file IO go through an `IDialogService` / `IStorageService` so the
  presentation layer stays testable.

## Light/dark mode toggle (required)

- `IThemeService.ApplyTheme(ThemeMode mode)` recolors the UI; persist the choice in settings; expose a
  toggle (menu item / switch).
- **WPF:** swap `ResourceDictionary` theme dictionaries (or use a library like ModernWpf / WPF-UI).
- **WinForms:** apply a palette across the control tree + Win32 immersive dark title bar via
  `DwmSetWindowAttribute` (or a library like `DarkModeForms`).

## Google Material Symbols icons (required)

- Buttons show an icon where available and use **no trailing ellipsis** labels (`Open`, not `Open...`).
- **WPF:** bundle the Material Symbols font and render glyphs, or embed SVGs (`Svg.Skia`); bind icon
  brush to the theme so it inverts in light/dark.
- **WinForms:** export needed icons as PNG at multiple DPIs into `Resources/Icons/`, or render the icon
  font; tint icons to follow the theme.
- Icon-only buttons need tooltips; ensure keyboard focus + contrast in both themes.

## Local data (optional)

Desktop apps usually want local storage — **SQLite is the quick win**: EF Core
`Microsoft.EntityFrameworkCore.Sqlite` (or `Microsoft.Data.Sqlite`) with the `.db` file in the user's
app-data folder. Access it behind a repository interface. See the `sql` bundle's `sqlite-conventions`.

## Packaging (required)

- Release builds to a git-ignored `publish/` folder. Prefer self-contained single-file:
  ```bash
  dotnet publish src/<Project>.App -c Release -r win-x64 --self-contained true \
    -p:PublishSingleFile=true -o publish/win-x64
  ```
- Zip each build named after its target, e.g. `publish/<Project>-<version>-win-x64.zip`. Provide a
  `publish.ps1` that builds, zips, and names the archive.

## Workflow

```
- [ ] 1. Create solution + projects (Core, Infrastructure, App)
- [ ] 2. Directory.Packages.props + Directory.Build.props; DI composition root
- [ ] 3. Main window/form + navigation shell; IThemeService + theme toggle; Material Symbols icons
- [ ] 4. First feature: View/Form + ViewModel/Presenter → Core service (no logic in code-behind)
- [ ] 5. IDialogService, settings persistence, logging
- [ ] 6. Unit tests for Core/Presenters; publish script + git-ignored publish/
```

## Docs

`README.md` (Windows-only note, build/run) and `AGENTS.md` (MVVM/MVP contract + theming). Keep current.
