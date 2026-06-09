mode: general
agent type: copilot
subagent_model: claude-sonnet-4-6

First, **READ THROUGH THE corresponding code.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/codex_token_effective_workflow/code.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/codex_workflow/code.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/vscode_token_effective_workflow/code.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/vscode_workflow/code.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/claudecode_token_effective_workflow/code.instructions.md` for `mode: fast` and `workflow/claudecode_workflow/code.instructions.md` for `mode: general`; the `subagent_model` header parameter controls the model used for all subagents (default: `claude-sonnet-4-6`). Follow the instructions in that file to implement the new functionalities mentioned in the following.

Follow the instructions in the selected code.instructions.md to implement the New functionalities:

New functionalities descriptions:
