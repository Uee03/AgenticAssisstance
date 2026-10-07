---
name: designing-diagrams
description: Designs UML and system diagrams (architecture, class, component, deployment, ERD, data flow, frontend component and route maps) as editable draw.io files in docs/diagrams, with Mermaid for sequence and flow sketches. Use when the user wants to plan, document, or visualize a backend, frontend, or full-stack design, or mentions draw.io, UML, C4, or architecture diagrams.
---

# Designing diagrams

**Best model:** Plan tier (Claude Sonnet 5.5) via the Planner; writing the XML is mechanical, so Quick tier (GPT-6 Luna) also works for small diagrams.

Diagrams here are plain-text `.drawio` files (draw.io XML) in `docs/diagrams/`, opened and edited
with the draw.io VS Code extension (`hediet.vscode-drawio`). Sequence diagrams and simple flows use
Mermaid in Markdown instead, which is cheaper and renders in the preview.

## Pick the diagram by the question

| Question | Diagram | Format |
|----------|---------|--------|
| What are the systems and who uses them? | C4 context | `.drawio` |
| What are the deployable parts and how do they talk? | Container / deployment | `.drawio` |
| How are the layers and modules wired? | Component / layered dependency | `.drawio` |
| What are the domain types and relations? | UML class | `.drawio` |
| What does the data model look like? | ERD | `.drawio` (entityRelationEdgeStyle) |
| What happens, in order, for one request? | Sequence | Mermaid `sequenceDiagram` |
| What states can this entity be in? | State | Mermaid `stateDiagram-v2` |
| How is the UI composed and navigated? | Frontend component tree, route map, state/data flow | `.drawio` |

One diagram answers one question. Split instead of adding more boxes; aim for 15 nodes or fewer.

## Workflow

Copy this checklist and tick items as you go:

```
Diagram progress:
- [ ] 1. State the question, audience, and diagram type (table above)
- [ ] 2. List nodes, groups, and edges in one short block
- [ ] 3. Write docs/diagrams/<name>.drawio following reference/drawio-xml.md
- [ ] 4. Validate with scripts/validate-drawio.ps1 and fix every error
- [ ] 5. Tell the user the path and what each group or edge style means
```

1. If the system is unclear, read the code and `AGENTS.md` first; do not invent components. Ask at
   most 2 questions when the scope is ambiguous.
2. Decide groups (layers, bounded contexts, deployment boundaries) before writing XML. Put external
   actors outside groups.
3. Write the file with the editing tools. Start from [examples/layered-backend.drawio](examples/layered-backend.drawio)
   when it fits. Use the grid and styles in [reference/drawio-xml.md](reference/drawio-xml.md).
4. Run `pwsh .github/skills/designing-diagrams/scripts/validate-drawio.ps1 docs/diagrams/<name>.drawio`
   (Windows PowerShell also works). Without PowerShell, run `xmllint --noout <file>` and check the
   well-formedness rules in the reference by hand. Fix and re-run until it passes.
5. Mention the file in the answer; do not paste the XML into chat.

## Backend and frontend defaults

- **Backend:** show dependency direction inward (API to Application to Domain; Infrastructure
  implements Application ports). Use a cylinder for each database, dashed edges for async or optional links.
- **Frontend:** group by feature, show shared UI and services separately, and label edges with the
  data that moves (state, events, API calls).
- Label every edge with 1-3 words and add a small legend when mixing edge styles.
- Match label language to the user's.

## Mermaid in Markdown

For sequence and state diagrams, add a fenced `mermaid` block to the relevant doc, for example
`docs/<topic>.md`; see `writing-mermaid`. For UML notation and choosing the type, see `modeling-uml`.
Do not convert Mermaid to draw.io unless the user asks.
