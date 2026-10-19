---
name: unity-uitk-uss-style-system
description: "Write UXML and USS with consistent BEM naming, USS variables, selectors, themes, transitions and editor skin support. Use when creating or restyling UI Toolkit layouts, naming elements and classes, adding USS files, themes, or hover/focus transitions."
---

# UXML and USS Style System

**Best model:** Act tier.

Pick one short class prefix per project or package (`<prefix>`, for example `acme-`) and keep it everywhere.
If the project already has a convention, follow it.

## Naming (BEM, kebab-case, `<prefix>`)

`block__element--modifier`, for example `<prefix>project-setup__apply-button--primary`.

- Prefix every class so a library never clashes with user classes.
- Use element `name` for code lookups (`Q<T>("...")`) and classes for styling. Names need not be unique but should be unambiguous.
- Semantic modifiers (`--danger`), not presentational ones (`--red`).
- Add classes in the control's constructor with `AddToClassList`.
- File names are PascalCase (`ProjectSetupWindow.uxml`). No version suffixes.

## USS rules

- One responsibility per file. Split shared pieces: `Variables.uss`, `Global.uss`, `Components/<Name>.uss`, then one feature USS per window.
- Put values in variables on `:root` or on the block class and use `var(--<prefix>...)`. No repeated magic numbers or hex colors.
- Prefer class selectors. Avoid `*`, deep descendant selectors, and overriding Unity classes such as `.unity-button` globally.
- Specificity order: inline, then `#name`, then `.class`, then type. Ties go to the later rule.
- Do not set styles inline in UXML or C# except for values computed at runtime.
- Reuse existing shared variables and controls in the project before adding new ones. If you add shared pieces, say so.

## Editor skins

Use Unity's editor variables so the UI follows the Light and Dark themes (for example `--unity-colors-window-background`, `--unity-colors-default-text`, `--unity-colors-button-background`). Check the exact variable names in the manual for the project's Unity version ("USS common variables") before using them. Add project tokens on top as aliases, for example `--<prefix>surface: var(--unity-colors-window-background);`.

## Transitions and states

- Animate `opacity`, `translate`, `scale`, `rotate`, `background-color`. Do not animate `width`, `height`, `top` or `left` (they trigger layout).
- Use pseudo-classes (`:hover`, `:focus`, `:active`, `:disabled`) with `transition-property`, `transition-duration`, `transition-timing-function`.
- Toggle state from C# with `EnableInClassList("<prefix>x--active", on)`.

## UXML template

```xml
<engine:UXML xmlns:engine="UnityEngine.UIElements" xmlns:editor="UnityEditor.UIElements">
  <engine:VisualElement name="example-window" class="acme-example-window">
    <engine:Label text="Title" class="acme-example-window__title" />
    <engine:Button name="example-window__apply-button" text="Apply"
                   class="acme-example-window__apply-button acme-example-window__apply-button--primary" />
  </engine:VisualElement>
  <engine:Style src="../Styles/ExampleWindow.uss" />
</engine:UXML>
```

Prefer `<engine:Style src="...">` or `styleSheets.Add(...)` over USS `@import`. `@import` is only reliable inside TSS theme files.

## Themes

Theme Style Sheet (TSS) files inherit Unity's default theme and add project USS on top. Use them for runtime UI. For editor tools, plain USS with Unity variables is enough.

## Folder layout

`Layouts/`, `Styles/` (`Variables`, `Global`, `Components/`, `Themes/`), `Scripts/`. Keep Editor and Runtime assets in separate folders.

## Sources

- [USS common properties and variables](https://docs.unity3d.com/Manual/UIE-USS.html)
- [USS transitions](https://docs.unity3d.com/Manual/UIE-Transitions.html)
- Runtime UI structure: [unity-ui-toolkit](../unity-ui-toolkit/SKILL.md)
