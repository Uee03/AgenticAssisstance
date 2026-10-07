# Workflow and model routing

Each custom agent in `.github/agents/` is pinned to a model tier. Pick the agent (dropdown or slash
command) that matches the task, or use **Orchestrator** to route automatically.

| Task | Agent / command | Tier |
|------|-----------------|------|
| One-file edit, syntax fix, quick question | Quick Helper `/quick` | cheap and fast |
| Architecture, multi-file design, review layout | Planner `/plan` | balanced, read-only |
| Execute an approved plan across files | Implementer `/act` | strong coder, edits + tests |
| Hard bug, race condition, migration, trade-off research | Deep Researcher `/deep-research` | deep reasoning, read-only |

Skills: `model-routing`, `planning-projects`, `researching-ideas`, `modeling-uml`, `writing-mermaid`,
`designing-diagrams` (draw.io). Guide: `docs/ai-workflow.md`.

## Rules

- One task, one agent session. Switch models only at phase boundaries (plan, then act). A different
  model re-reads the whole context uncached, so hand over the checklist, not the exploration.
- Planner and Deep Researcher never edit files. Implementer works only from an approved checklist.
- After two failed fixes, stop and recommend `/deep-research` instead of retrying.
- Keep context small: search before reading, read line ranges not whole files, summarize logs and
  diffs over about 100 lines, and delegate wide exploration to a subagent that returns a short summary.
- Keep this file and `AGENTS.md` stable: no dates, run logs, or per-task notes.
