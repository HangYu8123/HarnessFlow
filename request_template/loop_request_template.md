mode: fast
agent type: claude
subagent_model: inherit
dispatch_main_model: inherit
dispatch_subagent_model: inherit
max_iterations: 10
no_progress_k: 3
simplify: false
code_review: false

First, **READ THROUGH THE corresponding loop.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/token_effective_workflow/loop.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/general_workflow/loop.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/token_effective_workflow/loop.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/general_workflow/loop.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/token_effective_workflow/loop.instructions.md` for `mode: fast` and `workflow/general_workflow/loop.instructions.md` for `mode: general`; the `subagent_model` header selects the model for the loop's own workers (its default `inherit` keeps subagents on the main agent's model with no downgrade — in `mode: fast` the default main model is Sonnet 4.6), when the loop body uses `dispatch:` the optional `dispatch_main_model` / `dispatch_subagent_model` headers select the model for the dispatched family's main agent and that family's own subagents respectively (both default `inherit`), and the `max_iterations` / `no_progress_k` headers set the always-on safety caps (hard iteration cap, default 10; stop after this many no-progress iterations, default 3). Follow the instructions in that file to run the loop described below.

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
