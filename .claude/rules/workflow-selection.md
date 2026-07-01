---
paths: [".github/HarnessFlow/workflow/**"]
---

# Workflow Rules

When working with files under `.github/HarnessFlow/workflow/`, these are the shared, platform-adaptive workflow files (one set per mode, each used by Claude Code, Codex, and VS Code Copilot):

- `workflow/general_workflow/` — the thorough general workflows (`mode: general`, the default).
- `workflow/token_effective_workflow/` — the streamlined token-efficient workflows (`mode: fast`).
- `workflow/skill_workflow/` — the skill-backed variant (`mode: skill`); it swaps selected step instructions for confirmed ≥1000-star community skills, each with an inline fallback (catalogued in `skills/skill_workflow_skills.md`).

- Use pack-relative filesystem paths resolved via Pack Path Resolution (`.github/HarnessFlow/<path>` in installed repos, or `<path>` from repo root in the source repo)
- Read `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before any workflow-specific work
- Read context files from `repo_info/` (resolved via Pack Path Resolution)
- When the active agent is Claude Code, you have access to Claude Code native skills: `/simplify`, `/batch`, `/debug`, `/claude-api`; use `/simplify` after implementation steps when applicable. On Codex or VS Code Copilot these skills are unavailable — follow the platform-conditional fallbacks written into the workflow files.
- Subagents must follow the shared Subagent Launch Contract and use the model the instructions specify via the `subagent_model` header — a specific model id runs every subagent on that exact id (a deliberate override, even if smaller); `inherit` or unset uses the main agent's model with no downgrade (in `mode: fast` the default main model is Sonnet 4.6, so `inherit` subagents run on Sonnet 4.6).
