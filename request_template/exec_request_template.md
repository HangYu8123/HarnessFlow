mode: fast
agent type: claude
subagent_model: claude-opus-5
subagent_effort: low
online_researcher_effort: medium
diversifier: on
devils_advocate: off
online_research: on
simplify: false
code_review: false

First, **READ THROUGH THE corresponding exec.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to achieve the goal described below.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every subagent per the `subagent_model` **and** `subagent_effort` headers — two dials, neither may be silently dropped. Model: the default `claude-opus-5` pins subagents to Opus 5; `inherit` keeps them on the main agent's model with **no downgrade**, and any other specific model id overrides it for all subagents. Effort: the shipped `low` is a deliberate pin (use `inherit` to follow the session instead); apply it via the platform effort field where the spawn exposes one, otherwise as an `effort: <level> — binding budget, not a hint` line in each subagent's prompt. `online_researcher_effort` replaces it for the Online Researcher only and ships as `medium` — honor it even when it is lower.
3. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/exec.instructions.md` | `workflow/general_workflow/exec.instructions.md` | `workflow/skill_workflow/exec.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/exec.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/exec.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/exec.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/exec.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/exec.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/exec.instructions.md` |

`diversifier` (default `on`), `devils_advocate` (default `off`), and `online_research` (default `on`) toggle the Diversifier, Devils Advocate, and Online Researcher subagents — `on` runs one; `off` skips it and leaves its output label unproduced.

`simplify` / `code_review` each accept `false` (skip — the default), `true` (Claude Code's native `/simplify` · `/code-review`), or `local` (the pack's local `skills/code-simplification` · `skills/code-review-and-quality`, which work on every platform). See `_lib/review_skills.md`.

**Use `exec` when** the goal is reached in a single plan → execute → validate pass using existing capabilities (commands, skills, scripts, tools, operations). If the goal needs *iteration until a condition holds*, use `loop_request_template.md`; if the deliverable is *new or changed source code*, use `code_request_template.md`.

Follow the instructions in the selected exec.instructions.md to achieve the goal below. Only the goal is required — if you omit the actions, the workflow derives them from the goal and prints them before executing.

Goal (required):
  - <the outcome to achieve, e.g. "get the nightly ETL job running green against the staging dataset">

Specific actions (optional — if omitted, the plan derives them from the goal):
  - <commands, skills, scripts, or operations to use, e.g. "python scripts/etl.py --env staging">

Success criteria / definition of done (optional but recommended):
  - <verifiable check, e.g. "the run exits 0 and the staging table row count is > 0">

Starting state (optional — defaults to the current repo/workspace state):
  - important files / target repo: <...>
