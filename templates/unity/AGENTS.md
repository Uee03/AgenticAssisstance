# AGENTS.md - Unity projects and packages

Guidance for experienced engineers building 2D or 3D games, tools, or reusable Unity packages.
This is an advisory/code workflow bundle, not an Editor automation server or generated Unity project.
Copy its contents into a Unity project or UPM package root. Merge existing guidance rather than
overwriting it. The workspace overlay is optional; Unity agents work without it.

## Baseline and boundaries

- Read `ProjectSettings/ProjectVersion.txt` for projects or `package.json` for packages. Preserve
  the supported Unity versions, C# level, targets, and render pipeline; never assume 2D or URP.
- Before scaffolding or adding dependencies, complete
  [unity-project-intake](./.github/skills/unity-project-intake/SKILL.md) and obtain confirmation.
  For an existing focused change, read only the relevant nearby implementation and dependency facts.
- Focus dependency decisions on user-added packages: R3, ZLinq, UniTask, LitMotion, NuGetForUnity,
  serialization extensions, and any explicitly selected integrations. Do not curate or replace
  Unity's project-template defaults. Verify package versions and installed APIs before use.
- Prefer manual composition roots unless a DI framework is already selected. Preserve the existing
  network stack; ask before selecting one. Addressables, Input System, and graph skills apply when
  requested or already relevant, not as mandatory installs.
- Package development requires explicit dependencies, Runtime/Editor separation, consumer-facing
  APIs, version compatibility, samples, and tests in a host project. Do not depend on game assemblies.
- Keep pure rules testable, adapters thin, and architecture proportional. Reuse project utilities
  (including LazyJedi where present) rather than cloning them. Patterns solve demonstrated problems.

## Agents

| Agent | Role |
|-------|------|
| [Unity Architect](./.github/agents/unity-architect.agent.md) | Read-only design, trade-offs, and implementation checklist |
| [Unity Developer](./.github/agents/unity-developer.agent.md) | Approved changes with compile/test loops |
| [Unity Performance Auditor](./.github/agents/unity-performance-auditor.agent.md) | Read-only, evidence-ranked performance findings |
| [Unity Reviewer](./.github/agents/unity-reviewer.agent.md) | Read-only correctness, lifecycle, serialization, and API review |

Architect, Auditor, and Reviewer use Plan tier; Developer uses Act tier with model fallbacks.
Reviewers distinguish measured facts from hypotheses. Two failed fixes require a Deep Research
handoff if that optional workspace agent is installed, otherwise a written investigation brief.

## Skills - load only the relevant one

| Skill | Trigger |
|-------|---------|
| [unity-project-intake](./.github/skills/unity-project-intake/SKILL.md) | Project/package setup and user-added dependency decisions |
| [unity-clean-architecture](./.github/skills/unity-clean-architecture/SKILL.md) | SOLID, boundaries, DI, interfaces, serialization, value semantics |
| [unity-design-patterns](./.github/skills/unity-design-patterns/SKILL.md) | Observer, Strategy, Bridge, Singleton, State, Command, Flyweight, Dirty Flag, MVP/MVVM, Chain of Responsibility |
| [unity-object-pooling](./.github/skills/unity-object-pooling/SKILL.md) | Built-in pools, factories, resets, prewarming, resource ownership |
| [unity-optimization](./.github/skills/unity-optimization/SKILL.md) | Profiling, allocations, ZLinq, CPU/GPU/memory budgets |
| [unity-async-reactive](./.github/skills/unity-async-reactive/SKILL.md) | UniTask, R3, LitMotion, coroutines, delegates, Action, Func |
| [unity-scriptable-objects](./.github/skills/unity-scriptable-objects/SKILL.md) | Shared configuration, event channels, runtime state isolation |
| [unity-ui-toolkit](./.github/skills/unity-ui-toolkit/SKILL.md) | UXML/USS, presenters, binding, virtualization, UI lifecycle |
| [unity-editor-tools](./.github/skills/unity-editor-tools/SKILL.md) | EditorWindow, custom inspectors, PropertyDrawers, Undo |
| [unity-addressables](./.github/skills/unity-addressables/SKILL.md) | Asset handles, bundles, catalogs, resource lifetime |
| [unity-scene-loading](./.github/skills/unity-scene-loading/SKILL.md) | Smooth transitions, additive loading, activation and recovery |
| [unity-input-system](./.github/skills/unity-input-system/SKILL.md) | Action maps, rebinding, players, input adapters |
| [unity-netcode](./.github/skills/unity-netcode/SKILL.md) | Multiplayer authority, replication, RPCs, latency and disconnects |
| [unity-shader-graph](./.github/skills/unity-shader-graph/SKILL.md) | Shader Graph, shader properties, pipeline compatibility, GPU cost |
| [unity-vfx-graph](./.github/skills/unity-vfx-graph/SKILL.md) | VFX Graph events, properties, pooling and platform constraints |
| [unity-common-types](./.github/skills/unity-common-types/SKILL.md) | Enums, constants, helpers, shared classes and API design |
| [unity-testing](./.github/skills/unity-testing/SKILL.md) | EditMode/PlayMode, package host tests, player builds |
| [unity-code-review](./.github/skills/unity-code-review/SKILL.md) | Findings-first correctness and compatibility review |
| [unity-adr](./.github/skills/unity-adr/SKILL.md) | Record an approved architecture decision when requested |

Path-scoped rules: [unity-csharp.instructions.md](./.github/instructions/unity-csharp.instructions.md).

## Verification and asset safety

Use the matching Unity Editor for compile/import checks, EditMode and PlayMode tests, and relevant
player builds. See [unity-testing](./.github/skills/unity-testing/SKILL.md) for batch commands.
Standalone packages need a configured consumer test project. Do not treat `dotnet build` on generated
Unity projects as proof of a valid player build. If Editor/licensing/host access is unavailable,
report exactly which checks remain unrun. Never claim a prompt smoke test or benchmark was executed
without evidence.

Preserve `.meta` GUIDs, serialized identities, and public contracts. Prefer supported Editor APIs
for scene, prefab, and graph changes; do not hand-edit their YAML. Keep disposable work tied to
scene, component, pool lease, or session lifetime. Do not create change-log Markdown or ADR files
unless requested. Official version-matched Unity/package documentation and installed source are
authoritative; community advice is a starting point, not API evidence.