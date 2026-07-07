mode: fast
agent type: claude
subagent_model: inherit
simplify: false
code_review: false

First, **READ THROUGH THE corresponding exec.instructions.md VERY CAREFULLY**. If the active agent is Codex (CLI or VS Code), use `.github/HarnessFlow/workflow/token_effective_workflow/exec.instructions.md` for `mode: fast` and `.github/HarnessFlow/workflow/general_workflow/exec.instructions.md` for `mode: general`. If the active agent is VS Code Copilot, use `@/.github/HarnessFlow/workflow/token_effective_workflow/exec.instructions.md` for `mode: fast` and `@/.github/HarnessFlow/workflow/general_workflow/exec.instructions.md` for `mode: general`. If the active agent is Claude Code, use `workflow/token_effective_workflow/exec.instructions.md` for `mode: fast` and `workflow/general_workflow/exec.instructions.md` for `mode: general`; the optional `subagent_model` header selects the model for all subagents — its default `inherit` keeps subagents on the main agent's model with no downgrade (in `mode: fast` the default main model is Sonnet 4.6), or set a specific model id to override. Follow the instructions in that file to execute the cmds/skills mentioned in the following.

Follow the instructions in the selected exec.instructions.md to execute the target cmds/skills:

Target cmds/skills:
