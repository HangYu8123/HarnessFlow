mode: fast
reproduce: false
agent type: claude
subagent_model: inherit

First, **READ THROUGH THE corresponding debug.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/token_effective_workflow/debug.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/general_workflow/debug.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/token_effective_workflow/debug.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/general_workflow/debug.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/token_effective_workflow/debug.instructions.md` for `mode: fast` and `workflow/general_workflow/debug.instructions.md` for `mode: general`; the optional `subagent_model` header selects the model for all subagents — its default `inherit` keeps subagents on the main agent's model with no downgrade (in `mode: fast` the default main model is Sonnet 4.6), or set a specific model id to override. Follow the instructions in that file to implement the bug fix below.

bug: 

descriptions: 



important files:
