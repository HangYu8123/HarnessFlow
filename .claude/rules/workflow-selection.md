---
paths: [".github/HarnessFlow/workflow/claudecode_workflow/**"]
---

# Claude Code Workflow Rules

When working with files in `.github/HarnessFlow/workflow/claudecode_workflow/`, these are Claude Code CLI-native workflow files.

- Use pack-relative filesystem paths resolved via Pack Path Resolution (`.github/HarnessFlow/<path>` in installed repos, or `<path>` from repo root in the source repo)
- Read `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before any workflow-specific work
- Read context files from `repo_info/` (resolved via Pack Path Resolution)
- You have access to Claude Code native skills: `/simplify`, `/batch`, `/debug`, `/claude-api`
- Use `/simplify` after implementation steps when applicable
- Subagents must follow the shared Subagent Launch Contract and use the same model as the main agent
