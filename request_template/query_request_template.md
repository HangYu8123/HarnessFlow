mode: fast
agent type: claude
subagent_model: claude-opus-5
subagent_effort: low
online_researcher_effort: medium
devils_advocate: off
online_research: on

First, **READ THROUGH THE corresponding query.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to answer the queries.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` **and** `subagent_effort` headers — two dials, neither may be silently dropped. Model: the default `claude-opus-5` pins subagents to Opus 5; `inherit` keeps them on the main agent's model with **no downgrade**, and any other specific model id overrides it for all subagents. Effort: the shipped `low` is a deliberate pin (use `inherit` to follow the session instead); apply it via the platform effort field where the spawn exposes one, otherwise as an `effort: <level> — binding budget, not a hint` line in each subagent's prompt. `online_researcher_effort` replaces it for the Online Researcher only and ships as `medium` — honor it even when it is lower.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/query.instructions.md` | `workflow/general_workflow/query.instructions.md` | `workflow/skill_workflow/query.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/query.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/query.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/query.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/query.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/query.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/query.instructions.md` |

`devils_advocate` (default `off`) and `online_research` (default `on`) toggle the Devils Advocate and Online Researcher subagents — `on` runs one; `off` skips it and leaves its output label unproduced.

query:


descriptions:


important files:
