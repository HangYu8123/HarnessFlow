mode: general
agent type: copilot
subagent_model: claude-sonnet-4-6

First, **READ THROUGH THE corresponding correctness_check.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/codex_token_effective_workflow/correctness_check.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/codex_workflow/correctness_check.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/vscode_token_effective_workflow/correctness_check.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/vscode_workflow/correctness_check.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/claudecode_token_effective_workflow/correctness_check.instructions.md` for `mode: fast` and `workflow/claudecode_workflow/correctness_check.instructions.md` for `mode: general`; the `subagent_model` header parameter controls the model used for all subagents (default: `claude-sonnet-4-6`). Follow the instructions in that file to check the correctness of the following.

Follow the instructions in the selected correctness_check.instructions.md to check the correctness of:

descriptions:

important files:
