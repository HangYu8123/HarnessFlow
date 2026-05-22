---
paths: [".github/harness_coding_instructions/workflow/claudecode_workflow/**"]
---

# Claude Code Workflow Rules

When working with files in `.github/harness_coding_instructions/workflow/claudecode_workflow/`, these are Claude Code CLI-native workflow files.

- Use pack-relative filesystem paths resolved through `.github/harness_coding_instructions/`
- Read `.github/harness_coding_instructions/_lib/workflow_contract.md` and `.github/harness_coding_instructions/philosophy/philosophy.instructions.md` before any workflow-specific work
- Read context files from `.github/harness_coding_instructions/repo_info/`
- You have access to Claude Code native skills: `/simplify`, `/batch`, `/debug`, `/claude-api`
- Use `/simplify` after implementation steps when applicable
- Subagents must follow the shared Subagent Launch Contract and use the same model as the main agent
