mode: general
agent type: copilot
subagent_model: claude-sonnet-4-6

First, **READ THROUGH THE corresponding pr.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/codex_token_effective_workflow/pr.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/codex_workflow/pr.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/vscode_token_effective_workflow/pr.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/vscode_workflow/pr.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/claudecode_workflow/pr.instructions.md`; the `subagent_model` header parameter controls the model used for all subagents (default: `claude-sonnet-4-6`). Follow the instructions in that file to break down and create PRs as described below.

Follow the instructions in the selected pr.instructions.md to create PRs:

target branch:

base branch:

mode (plan/execute):

max lines per PR:

stack tool preference:

additional notes:
