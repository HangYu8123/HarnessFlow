---
paths: [".github/HarnessFlow/workflow/general_workflow/**"]
---

# General Workflow Rules

When working with files in `.github/HarnessFlow/workflow/general_workflow/`, these are the shared, platform-adaptive general workflow files (one set used by Claude Code, Codex, and VS Code Copilot).

- Use pack-relative filesystem paths resolved via Pack Path Resolution (`.github/HarnessFlow/<path>` in installed repos, or `<path>` from repo root in the source repo)
- Read `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before any workflow-specific work
- Read context files from `repo_info/` (resolved via Pack Path Resolution)
- When the active agent is Claude Code, you have access to Claude Code native skills: `/simplify`, `/batch`, `/debug`, `/claude-api`; use `/simplify` after implementation steps when applicable. On Codex or VS Code Copilot these skills are unavailable — follow the platform-conditional fallbacks written into the workflow files.
- Subagents must follow the shared Subagent Launch Contract and use the same model as the main agent
