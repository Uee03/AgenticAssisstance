---
name: unity-uitk-custom-controls
description: "Create reusable UI Toolkit custom controls with [UxmlElement] and [UxmlAttribute] in Unity 6, including lifecycle, events, BaseField value controls and USS classes. Use when building a reusable element such as a toggle, health bar, tab view, path picker or any new VisualElement."
---

# Custom Controls (Unity 6)

**Best model:** Act tier.

## Template

```csharp
using UnityEngine.UIElements;

namespace Company.Module.Controls
{
    [UxmlElement]
    public partial class PathField : BaseField<string>
    {
        public static readonly string ussClassName = "acme-path-field";

        [UxmlAttribute("browse-label")]
        public string BrowseLabel { get; set; } = "Browse";

        public PathField() : this(null) { }

        public PathField(string label) : base(label, new VisualElement())
        {
            AddToClassList(ussClassName);
            RegisterCallback<AttachToPanelEvent>(OnAttach);
            RegisterCallback<DetachFromPanelEvent>(OnDetach);
        }

        public override void SetValueWithoutNotify(string newValue)
        {
            base.SetValueWithoutNotify(newValue);
        }

        void OnAttach(AttachToPanelEvent evt) { }
        void OnDetach(DetachFromPanelEvent evt) { }
    }
}
```

## Rules

- Use `[UxmlElement]` on a `partial` class and `[UxmlAttribute]` on properties. Do not use the obsolete `UxmlFactory` and `UxmlTraits`.
- Always provide a parameterless constructor so UXML and UI Builder can create it.
- Pick the closest base: `VisualElement` for containers, `BaseField<T>` for value controls, `Button` or `Label` for specialized versions.
- There is no `Awake`, `OnEnable` or `OnDestroy`. Build children in the constructor. Use `AttachToPanelEvent` for work that needs a panel and `DetachFromPanelEvent` to unsubscribe from anything outside the control.
- Update visuals from `SetValueWithoutNotify` and call `base.SetValueWithoutNotify` first. This avoids event loops.
- Raise changes through `value = ...` so `ChangeEvent<T>` fires. Call `evt.StopPropagation()` for events the control fully handles.
- Support keyboard and navigation events (`KeyDownEvent`, `NavigationSubmitEvent`) for interactive controls, not only mouse clicks.
- Add BEM classes to child parts: `acme-path-field__input`, `acme-path-field__browse-button`.
- Put control styles in `Styles/Components/<Name>.uss`. Expose colors and sizes as USS variables, not C# properties.
- Public `ussClassName` constants mirror Unity's own controls so users can restyle them.
- A control that builds an `EnumField` or `EnumFlagsField` should use the enum constructor. Setting `value` on a default-constructed `EnumField` can leave the text empty.

## Using in UXML

```xml
<engine:UXML xmlns:engine="UnityEngine.UIElements" xmlns:acme="Company.Module.Controls">
  <acme:PathField label="Output" browse-label="Pick" />
</engine:UXML>
```

The UXML namespace is the control's C# namespace. Confirm it in UI Builder's Library panel. A namespace that
shares a name with a third-party library (for example `R3` or `UniTask`) can hide that library inside the
namespace; put `using` directives inside the namespace block and use `global::` where needed.

## Placement

- Editor-only controls: the package's `Editor/Scripts/Controls/`.
- Controls usable at runtime: a Runtime asmdef folder such as `Runtime/Scripts/CustomElements/`. Only reference `UnityEditor` inside `#if UNITY_EDITOR` or an Editor asmdef.

## Pooling

Reset a pooled control fully before reuse: clear callbacks, values and USS state classes. Do not pool elements that register events without a matching unregister.

## Sources

- [Create a custom control](https://docs.unity3d.com/Manual/UIE-create-custom-controls.html)
