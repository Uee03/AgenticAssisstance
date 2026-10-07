# Model matrix

Prices are USD per 1M tokens (input / cached input / output), default context tier, from GitHub's
"Models and pricing" page. Verified 2026-10-06; re-check the sources before changing tiers.

## Contents
- Tier models
- Escalation-only models
- Notes behind the choices
- Sources

## Tier models

| Model (use this exact name) | Input / cached / output | Strength per GitHub docs |
|-----------------------------|-------------------------|--------------------------|
| GPT-6 Luna | 0.10 / 0.01 / 0.50 | Quick, cost-efficient help with small tasks |
| GPT-5.6 Luna | 0.20 / 0.02 / 1.20 | Same, lowest-cost GPT-5.6 |
| Claude Haiku 4.5 | 1.00 / 0.10 / 5.00 | Fast, reliable answers to lightweight questions |
| Claude Sonnet 5.5 | 2.00 / 0.20 / 10.00 | Efficient completion with fewer steps, tokens, tool calls |
| Claude Sonnet 5 | 2.00 / 0.20 / 10.00 | General coding and agent tasks |
| GPT-5.6 Terra | 2.00 / 0.20 / 12.00 | Balanced everyday interactive and agentic coding |
| GPT-6.1 Sol | 2.00 / 0.10 / 10.00 | Advanced, efficient reasoning for complex coding tasks |
| GPT-6 Sol | 2.00 / 0.20 / 10.00 | All-round dev tasks with careful multistep validation |
| GPT-5.6 Sol | 4.00 / 0.40 / 20.00 | Highest GPT-5.6 reasoning, large codebases |
| Claude Opus 5.5 | 4.00 / 0.20 / 20.00 | Long-running agentic work, error recovery, multistep tasks |
| Claude Opus 5 | 5.00 / 0.50 / 25.00 | Complex problem solving and reasoning |
| Claude Opus 4.8 | 5.00 / 0.50 / 25.00 | Same family, older |

## Escalation-only models

Never list these as automatic fallbacks.

| Model | Input / cached / output | Use |
|-------|-------------------------|-----|
| Claude Fable 5.1 | 10.00 / 0.25 / 50.00 | Long-running autonomous coding and deep codebase research |
| Claude Fable 5 | 10.00 / 1.00 / 50.00 | Long-horizon autonomous coding |
| GPT-6 Astra | 10.00 / 1.00 / 50.00 | Long-horizon coding with continuous planning and verification |

## Notes behind the choices

- Tier 3 uses GPT-6.1 Sol: same price as Sonnet 5.5, half the cached-input price. Agent loops re-read
  mostly cached context, so this lowers cost on long edit-and-test runs.
- Tier 4 uses Opus 5.5: 20% cheaper than Opus 5 and 4.8, and cache reads cost 5% of input price.
- Tier 2 uses Sonnet 5.5 for planning and review because it completes tasks with fewer steps and tool calls.
- A third-party single-prompt test (Merge, one web page build) found GPT-5.6 Terra about 2x faster and
  cheaper than Sonnet 5 at that gateway's rates. GitHub list prices put Terra above Sonnet 5.5 on
  output, so Terra is kept as a latency-oriented fallback, not a default.
- Cache reads are priced far below normal input, and a cache is tied to one model's prefix. A model
  switch starts cold; that is why routing happens at phase boundaries.
- Inline completions and next edit suggestions are not billed in AI credits.

## Sources

- https://docs.github.com/en/copilot/reference/ai-models/model-comparison
- https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing
- https://code.visualstudio.com/docs/copilot/customization/custom-agents (`model`, `agents`, `handoffs`)
- https://platform.claude.com/docs/en/build-with-claude/prompt-caching
- https://platform.claude.com/docs/en/managed-agents/multiagent-orchestration (coordinator, specialization, escalation)
- https://www.merge.dev/blog/gpt-5-6-terra-vs-claude-sonnet-5
