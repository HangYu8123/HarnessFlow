mode: fast
agent type: claude
subagent_model: inherit

First, **READ THROUGH THE corresponding query.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/codex_token_effective_workflow/query.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/general_workflow/query.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/vscode_token_effective_workflow/query.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/general_workflow/query.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/claudecode_token_effective_workflow/query.instructions.md` for `mode: fast` and `workflow/general_workflow/query.instructions.md` for `mode: general`; the optional `subagent_model` header selects the model for all subagents — its default `inherit` keeps subagents on the main agent's model (no downgrade), or set a specific model id to override. Follow the instructions in that file to answer the queries.

query:


descriptions:


important files:
