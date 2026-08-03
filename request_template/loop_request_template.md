mode: fast
agent type: claude
subagent_model: inherit
subagent_effort: low
online_researcher_effort: medium
devils_advocate: off
online_research: on
dispatch_main_model: inherit
dispatch_subagent_model: inherit
max_iterations: 10
no_progress_k: 3
loop_strategy: stable_advancing
simplify: false
code_review: false

First, **READ THROUGH THE corresponding loop.instructions.md VERY CAREFULLY**, in its entirety, then follow it step-by-step to run the loop described below.

Hard constraints, in priority order (hardest first) —
1. Read the entire matched instruction file before doing anything else, and follow its steps in order.
2. Create every one of the loop's own workers per the `subagent_model` **and** `subagent_effort` headers — two dials, neither may be silently dropped. Model: `subagent_model` pins every worker to one specific model — a named model id is a deliberate override applied to all of them, honored even when it is smaller than the main agent's model; the shipped `inherit` instead keeps them on the main agent's model with **no downgrade**. Effort: the shipped `low` is a deliberate pin (use `inherit` to follow the session instead); apply it via the platform effort field where the spawn exposes one, otherwise as an `effort: <level> — binding budget, not a hint` line in each subagent's prompt. `online_researcher_effort` replaces it for the Online Researcher only and ships as `medium` — honor it even when it is lower.
3. When the loop body uses `dispatch:`, the optional `dispatch_main_model` / `dispatch_subagent_model` headers select the model for the dispatched family's main agent and that family's own subagents respectively (both default `inherit`); the `subagent_effort` / `online_researcher_effort` levels carry across the dispatch boundary unchanged — the sub-main agent applies them to every subagent it spawns.
4. The `max_iterations` / `no_progress_k` headers set the always-on safety caps (hard iteration cap, default 10; stop after this many no-progress iterations, default 3).
5. The `loop_strategy` header selects how iterations advance — `aggressive` (ambitious steps; over-engineering and fine-grained optimization allowed), `fast_iteration` (proof-of-concept focus; small steps, more analysis, referencing papers/tech reports/online resources for new ideas), or `stable_advancing` (default — solid validated increments, careful verification, code quality). It modulates body-work style only and never weakens the caps, exit conditions, or write-guard (see `_lib/loop_control.md` §Loop Strategy).
6. Resolve the matched instruction file from this table — pick your platform's row and this request's `mode:` column.

| Active agent | `mode: fast` | `mode: general` | `mode: skill` |
|---|---|---|---|
| Claude Code | `workflow/token_effective_workflow/loop.instructions.md` | `workflow/general_workflow/loop.instructions.md` | `workflow/skill_workflow/loop.instructions.md` |
| Codex (CLI or VS Code) | `.github/HarnessFlow/workflow/token_effective_workflow/loop.instructions.md` | `.github/HarnessFlow/workflow/general_workflow/loop.instructions.md` | `.github/HarnessFlow/workflow/skill_workflow/loop.instructions.md` |
| VS Code Copilot | `@/.github/HarnessFlow/workflow/token_effective_workflow/loop.instructions.md` | `@/.github/HarnessFlow/workflow/general_workflow/loop.instructions.md` | `@/.github/HarnessFlow/workflow/skill_workflow/loop.instructions.md` |

`devils_advocate` (default `off`) and `online_research` (default `on`) toggle the Devils Advocate and Online Researcher subagents — `on` runs one; `off` skips it and leaves its output label unproduced.

`simplify` / `code_review` each accept `false` (skip — the default), `true` (Claude Code's native `/simplify` · `/code-review`), or `local` (the pack's local `skills/code-simplification` · `skills/code-review-and-quality`, which work on every platform). See `_lib/review_skills.md`.

The loop runs a delegated body action each iteration while the main agent controls observation, exit-condition checks, and the ledger. Provide a **goal** and **success criteria + exit conditions** (both required). The loop body and starting state are optional — if you omit the loop body, the controller decides it from your goal; starting state defaults to the current repo/workspace state.

Goal (required):
  - <one concrete sentence with a specific term/quantity, e.g. "make all tests in tests/ pass">

Success criteria & exit conditions (required):
  - success (goal-met): <verifiable check, e.g. "pytest -q exits 0">
  - extra exit conditions (optional): <budget (token / time / cost) / human checkpoint>
  - (max_iterations and no_progress_k are set in the headers above)

Loop body (optional — if omitted, the controller decides it from the goal):
  - action: <free-form, e.g. "fix the next failing test">   OR   dispatch: family=<code|debug|exec|refactor|query|correctness_check|pr|initialize> mode=<fast|general|skill>

Starting state (optional — defaults to the current repo/workspace state):
  - important files / target repo / baseline notes: <...>
