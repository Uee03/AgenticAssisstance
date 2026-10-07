---
name: planning-projects
description: Turns an idea or request into a project plan for any stack - goals, scope, requirements, architecture sketch, phased milestones, work breakdown, risks, open questions, and an implementation checklist. Use when starting a new project, planning a large feature or migration, scoping an MVP, breaking work into phases, or when the user asks for a plan, roadmap, or breakdown before building.
---

# Planning projects

**Best model:** Plan tier (Claude Sonnet 5.5) via the Planner. Use Deep tier (Claude Opus 5.5) only when the plan hinges on an unresolved technical unknown.

Plan for decisions and sequencing, not paperwork. Every section must change what gets built.

## Workflow

Copy this checklist and tick items as you go:

```
Planning progress:
- [ ] 1. Capture the goal, users, and constraints
- [ ] 2. Resolve open decisions (research if needed)
- [ ] 3. Sketch the architecture
- [ ] 4. Slice into phases, thin vertical slice first
- [ ] 5. Break phase 1 into a checklist
- [ ] 6. List risks and open questions, then stop for approval
```

**1. Capture.** Ask at most 5 questions in one message, only what changes the plan: the problem and who
has it, must-have outcomes, hard constraints (stack, deadline, budget, hosting, compliance), what exists
already, and what is explicitly out of scope. State assumptions for anything unanswered. Read the
workspace and `AGENTS.md` first so you do not ask what the code already answers.

**2. Decide.** For each open choice (database, auth, hosting, build vs buy), use `researching-ideas`
when the answer is not obvious; otherwise pick the default that fits the existing stack and note it.
If an app bundle is installed, defer stack choices to its `project-intake` skill.

**3. Architecture.** Describe components and how they talk in 5-10 lines. Offer a diagram with
`designing-diagrams` (editable draw.io) or `writing-mermaid` (quick, in Markdown). Use `modeling-uml`
when types and relations matter.

**4. Phases.** Order by risk and value, not by layer:

| Phase | Purpose | Exit test |
|-------|---------|-----------|
| 0 Foundation | Repo, CI, licensing, `.gitignore`, local run | Build and test pass from a clean clone |
| 1 Walking skeleton | Thinnest end-to-end slice through every layer | One real request works UI to storage |
| 2 Core features | Must-haves, one slice at a time | Each slice demoable and tested |
| 3 Hardening | Auth edge cases, errors, performance, security review | Risks closed or accepted |
| 4 Release | Packaging, docs, deployment, monitoring | Deployed and rollback-able |

Prioritize with MoSCoW (Must, Should, Could, Won't). Size work as S, M, or L; give durations only if
the user supplies a team and capacity.

**5. Checklist.** Number the phase 1 items so an implementer can run them one at a time. Each item names
the file or module, the change, and the verification command.

**6. Risks.** List the top 3-5 risks with a mitigation and an owner, plus open questions. Stop and wait
for approval; do not start building.

## Output format

```markdown
# <Project> plan
**Goal:** <one sentence>  **Users:** <who>  **Out of scope:** <list>

## Decisions
| Decision | Choice | Why |

## Architecture
<5-10 lines + diagram link>

## Phases
| Phase | Scope | Exit test | Size |

## Phase 1 checklist
1. <file/module> - <change> - verify: <command>

## Risks and open questions
| Risk | Impact | Mitigation |
```

Keep it under about 80 lines. Save to `docs/plans/<name>.md` only when the user asks and edit tools
are available. Hand off with `/act` after approval.

## Re-planning

When scope changes mid-build, update only the affected phase and list what moved. Do not rewrite the
whole plan.
