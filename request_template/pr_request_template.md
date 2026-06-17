mode: fast
agent type: claude
subagent_model: inherit

First, **READ THROUGH THE corresponding pr.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/token_effective_workflow/pr.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/general_workflow/pr.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/token_effective_workflow/pr.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/general_workflow/pr.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/token_effective_workflow/pr.instructions.md` for `mode: fast` and `workflow/general_workflow/pr.instructions.md` for `mode: general`; the optional `subagent_model` header selects the model for all subagents — its default `inherit` keeps subagents on the main agent's model with no downgrade (in `mode: fast` the default main model is Sonnet 4.6), or set a specific model id to override. Follow the instructions in that file to break down and create PRs as described below.

Follow the instructions in the selected pr.instructions.md to create PRs:

target branch:

base branch:

mode (plan/execute):

max lines per PR:

stack tool preference:

additional notes:
