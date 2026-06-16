mode: fast
agent type: claude
subagent_model: inherit

First, **READ THROUGH THE corresponding code.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/codex_token_effective_workflow/code.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/codex_workflow/code.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/vscode_token_effective_workflow/code.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/vscode_workflow/code.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/claudecode_token_effective_workflow/code.instructions.md` for `mode: fast` and `workflow/claudecode_workflow/code.instructions.md` for `mode: general`; the optional `subagent_model` header selects the model for all subagents — its default `inherit` keeps subagents on the main agent's model (no downgrade), or set a specific model id to override. Follow the instructions in that file to implement the new functionalities mentioned in the following.

Follow the instructions in the selected code.instructions.md to implement the New functionalities:

New functionalities descriptions:
