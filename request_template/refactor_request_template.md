mode: fast
agent type: copilot
subagent_model: claude-sonnet-4-6

First, **READ THROUGH THE corresponding refactor.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/codex_token_effective_workflow/refactor.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/codex_workflow/refactor.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/vscode_token_effective_workflow/refactor.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/vscode_workflow/refactor.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/claudecode_token_effective_workflow/refactor.instructions.md` for `mode: fast` and `workflow/claudecode_workflow/refactor.instructions.md` for `mode: general`; the `subagent_model` header parameter controls the model used for all subagents (default: `claude-sonnet-4-6`). Follow the instructions in that file to implement the refactor goals specified by the followings.

Follow the instructions in the selected refactor.instructions.md to implement the refactor goal to the:


refactor descriptions:
