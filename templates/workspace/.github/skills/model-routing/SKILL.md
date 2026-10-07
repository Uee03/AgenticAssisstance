---
name: model-routing
description: Chooses or changes which AI model a task, agent, or skill should use, based on task type, cost, and the project's four-tier routing (Quick, Plan, Act, Deep Research). Use when picking a model, adding or editing a custom agent's model, tuning token cost, or when a model is unavailable and a fallback is needed.
---

# Model routing

**Best model:** Quick tier (GPT-6 Luna) via Quick Helper; lookups and small agent-file edits only.

Models are pinned per custom agent in `.github/agents/*.agent.md` via `model:`. A list is a priority
order: the first available model is used. Skills and instruction files cannot select a model.

## Tiers

| Tier    | Agent                                                                                    | Model (then fallbacks)                             | Use for                                           |
| ------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------- | ------------------------------------------------- |
| 1 Quick | Quick Helper                                                                             | GPT-6 Luna, GPT-5.6 Luna, Claude Haiku 4.5         | One-file edits, syntax, regex, short answers      |
| 2 Plan  | Planner, reviewers, advisors, Unity Architect, Unity Performance Auditor, Unity Reviewer | Claude Sonnet 5.5, Sonnet 5, GPT-5.6 Terra         | Architecture, multi-file design, read-only review |
| 3 Act   | Implementer, scaffolders, Unity Developer                                                | GPT-6.1 Sol, GPT-6 Sol, GPT-5.6 Sol, GPT-5.6 Terra | Multi-file edits with build and test loops        |
| 4 Deep  | Deep Researcher                                                                          | Claude Opus 5.5, Opus 5, Opus 4.8                  | Root cause, races, migrations, trade-off research |

Unity agents are supplied by the optional `unity/` bundle. They preserve 2D/3D/package context and
focus dependency decisions on user-added integrations, not Unity's template defaults. Select them
directly; copying the bundle does not expand the generic Orchestrator's specialist allow-list.

Prices, strengths, and sources: [reference/model-matrix.md](reference/model-matrix.md).

## Choosing

0. Skills name their best tier on the line under their title. Design and decision skills: Plan.
   Build and convention skills: Act. Boilerplate (`.gitignore`, licence): Quick.
1. One file and obvious change: Tier 1.
2. Needs design or touches several files: Tier 2 to plan, then Tier 3 to execute.
3. Cause unknown, or two fixes failed: Tier 4. Do not retry the same fix a third time.
4. Do not pick Claude Fable 5.x or GPT-6 Astra by default; they cost about 2.5x the Tier 4 price.
   Choose them manually for long-horizon autonomous work only.

## Changing a model

1. Edit `model:` in the agent file. Keep the fallback list; use the exact names in the matrix, with
   the `(copilot)` suffix, for example `'Claude Sonnet 5.5 (copilot)'`.
2. Update `handoffs[].model` in agents that hand off to it, and the tier table above.
3. Check the agent loaded: right-click the Chat view, choose Diagnostics, and look for errors.

## Cost rules

- Switching models mid-task re-reads the context uncached. Switch at phase boundaries only and carry
  the checklist, not the transcript. For large explorations, start a new chat for `/act`.
- Keep always-on files (`AGENTS.md`, `copilot-instructions.md`) stable and short.
- Delegate wide exploration to a subagent that returns a short summary.

## What files cannot control

- A hard context-window limit, or thinking effort, per agent. Use the model picker where it offers
  an effort level; keep context small through the rules above.
- The inline completion model. Change it per GitHub's "Changing the AI model for GitHub Copilot
  inline suggestions" guide; completions are not billed in AI credits.
