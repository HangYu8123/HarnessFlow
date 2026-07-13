mode: fast
agent type: claude
subagent_model: inherit
simplify: false
code_review: false

First, **READ THROUGH THE corresponding pr.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to break down and create PRs as described below.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` header — the default `inherit` keeps subagents on the main agent's model with **no downgrade** (in `mode: fast` the default main model is Sonnet 4.6); a specific model id overrides it for all subagents.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/workflow/token_effective_workflow/pr.instructions.md` | `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/workflow/general_workflow/pr.instructions.md` | `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/workflow/skill_workflow/pr.instructions.md` |
| Codex (CLI or VS Code) | `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/workflow/token_effective_workflow/pr.instructions.md` | `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/workflow/general_workflow/pr.instructions.md` | `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/workflow/skill_workflow/pr.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/pr.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/pr.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/pr.instructions.md` |

`simplify` / `code_review` each accept `false` (skip — the default), `true` (Claude Code's native `/simplify` · `/code-review`), or `local` (the pack's vendored `skills/code-simplification` · `skills/code-review-and-quality`, which work on every platform). See `_lib/review_skills.md`.

Follow the instructions in the selected pr.instructions.md to create PRs:

target branch:

base branch:

mode (plan/execute):

max lines per PR:

stack tool preference:

additional notes:
