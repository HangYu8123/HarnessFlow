mode: fast
agent type: claude
subagent_model: inherit
simplify: false
code_review: false

First, **READ THROUGH THE corresponding exec.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to execute the cmds/skills mentioned in the following.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` header — the default `inherit` keeps subagents on the main agent's model with **no downgrade**; a specific model id overrides it for all subagents.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/exec.instructions.md` | `workflow/general_workflow/exec.instructions.md` | `workflow/skill_workflow/exec.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/exec.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/exec.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/exec.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/exec.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/exec.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/exec.instructions.md` |

`simplify` / `code_review` each accept `false` (skip — the default), `true` (Claude Code's native `/simplify` · `/code-review`), or `local` (the pack's vendored `skills/code-simplification` · `skills/code-review-and-quality`, which work on every platform). See `_lib/review_skills.md`.

Follow the instructions in the selected exec.instructions.md to execute the target cmds/skills:

Target cmds/skills:
