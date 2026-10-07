---
name: unity-ui-toolkit
description: "Build and review Unity UI Toolkit UXML/USS, runtime and Editor UI, custom controls, data binding, ListView virtualization, MVP/MVVM, R3 state, and LitMotion transitions. Use for UI lifecycle, focus, performance, or responsive layout."
---

# Unity UI Toolkit

**Best model:** Act tier for UI changes; Plan tier for presentation design.

## Workflow

1. Confirm runtime vs Editor surface, installed Unity UI capabilities, input ownership, resolution,
   and accessibility needs. Preserve existing uGUI screens unless migration is requested.
2. Use UXML for structure, USS for presentation, and a small adapter for view interactions. Keep
   domain rules outside VisualElement callbacks. Choose MVP or MVVM from the actual screen needs.
3. Query stable elements once per instantiated tree, not every frame. Decide who owns the tree,
   presenter/view-model, scheduled work, and callbacks; re-created UIDocument trees need rebinding.
4. Verify version-specific runtime binding before using it. R3 bridges model state only where
   installed; handle initial values, two-way feedback loops, errors, and subscription disposal.
5. Register/unregister matching callbacks at deliberate attach/enable boundaries. Dispose bindings
   and cancel LitMotion handles on detachment/disable as applicable, not only GameObject destruction.
6. For collections, use ListView/TreeView virtualization where appropriate. Separate make/bind/
   unbind/destroy responsibilities; recycled rows must release old callbacks and item references.
7. Use flex layouts and size constraints; test text overflow, localization, focus traversal,
   gamepad/keyboard navigation, pointer input, scaling, and multiple panel resolutions.
8. Measure style/layout/repaint work, per-frame allocations, and redundant updates. Prefer updating
   changed state over rebuilding entire visual trees. Test disable/enable and repeated view opening.

## DO NOT

- Invent WPF binding/ICommand APIs in UI Toolkit or mix IMGUI assumptions into runtime UI.
- Leave pooled rows subscribed to old items, re-query every frame, or register callbacks twice.
- Assume existing Canvas-based helpers work on UI Toolkit without an adapter.
- Hand-edit assets through unsupported YAML or impose UI Toolkit on a package with no UI requirement.

## Sources

- [UI Toolkit manual](https://docs.unity3d.com/Manual/UIElements.html)
- [ListView API](https://docs.unity3d.com/ScriptReference/UIElements.ListView.html)
- [MVP](../unity-design-patterns/reference/mvp.md)
- [MVVM](../unity-design-patterns/reference/mvvm.md)
- [R3](https://github.com/Cysharp/R3)
- [LitMotion](https://github.com/annulusgames/LitMotion)
