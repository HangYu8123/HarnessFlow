mode: fast
agent type: claude
subagent_model: inherit
simplify: false
code_review: false

First, **READ THROUGH THE corresponding code.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to implement the new functionalities mentioned in the following.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` header — the default `inherit` keeps subagents on the main agent's model with **no downgrade** (in `mode: fast` the default main model is Sonnet 4.6); a specific model id overrides it for all subagents.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/code.instructions.md` | `workflow/general_workflow/code.instructions.md` | `workflow/skill_workflow/code.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/code.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/code.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/code.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/code.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/code.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/code.instructions.md` |

Follow the instructions in the selected code.instructions.md to implement the New functionalities:

New functionalities descriptions:
