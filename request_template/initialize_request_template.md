mode: fast
agent type: claude
subagent_model: inherit
subagent_effort: high

First, **READ THROUGH THE corresponding initialize.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to initialize the repo.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` **and** `subagent_effort` headers — two dials, neither may be silently dropped. Model: the default `inherit` keeps subagents on the main agent's model with **no downgrade**; a specific model id overrides it for all subagents. Effort: the shipped `high` is a deliberate pin (use `inherit` to follow the session instead); apply it via the platform effort field where the spawn exposes one, otherwise as an `effort: <level> — binding budget, not a hint` line in each subagent's prompt.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/initialize.instructions.md` | `workflow/general_workflow/initialize.instructions.md` | `workflow/skill_workflow/initialize.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/initialize.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/initialize.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/initialize.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/initialize.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/initialize.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/initialize.instructions.md` |

Follow the instructions in the selected initialize.instructions.md to initialize:

repo name:
