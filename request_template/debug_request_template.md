mode: fast
reproduce: false
agent type: claude
subagent_model: inherit
subagent_effort: low
online_researcher_effort: medium
diversifier: on
devils_advocate: off
online_research: on
simplify: false
code_review: false

First, **READ THROUGH THE corresponding debug.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to implement the bug fix below.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` **and** `subagent_effort` headers — two dials, neither may be silently dropped. Model: `subagent_model` pins every subagent to one specific model — a named model id is a deliberate override applied to all subagents, honored even when it is smaller than the main agent's model; the shipped `inherit` instead keeps them on the main agent's model with **no downgrade**. Effort: the shipped `low` is a deliberate pin (use `inherit` to follow the session instead); apply it via the platform effort field where the spawn exposes one, otherwise as an `effort: <level> — binding budget, not a hint` line in each subagent's prompt. `online_researcher_effort` replaces it for the Online Researcher only and ships as `medium` — honor it even when it is lower.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/debug.instructions.md` | `workflow/general_workflow/debug.instructions.md` | `workflow/skill_workflow/debug.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/debug.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/debug.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/debug.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/debug.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/debug.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/debug.instructions.md` |

`diversifier` (default `on`), `devils_advocate` (default `off`), and `online_research` (default `on`) toggle the Diversifier, Devils Advocate, and Online Researcher subagents — `on` runs one; `off` skips it and leaves its output label unproduced.

`simplify` / `code_review` each accept `false` (skip — the default), `true` (Claude Code's native `/simplify` · `/code-review`), or `local` (the pack's local `skills/code-simplification` · `skills/code-review-and-quality`, which work on every platform). See `_lib/review_skills.md`.

bug: 

descriptions: 



important files:
