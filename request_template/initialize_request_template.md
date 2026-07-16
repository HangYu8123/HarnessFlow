mode: fast
agent type: claude
subagent_model: inherit

First, **READ THROUGH THE corresponding initialize.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to initialize the repo.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` header — the default `inherit` keeps subagents on the main agent's model with **no downgrade**; a specific model id overrides it for all subagents.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/initialize.instructions.md` | `workflow/general_workflow/initialize.instructions.md` | `workflow/skill_workflow/initialize.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/initialize.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/initialize.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/initialize.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/initialize.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/initialize.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/initialize.instructions.md` |

Follow the instructions in the selected initialize.instructions.md to initialize:

repo name:
