---
paths: [".github/HarnessFlow/workflow/**"]
---

# Workflow Rules

When working with files under `.github/HarnessFlow/workflow/`, these are the shared, platform-adaptive workflow files (one set per mode, each used by Claude Code, Codex, and VS Code Copilot):

- `workflow/general_workflow/` — the thorough general workflows (`mode: general`).
- `workflow/token_effective_workflow/` — the streamlined token-efficient workflows (`mode: fast`).
- `workflow/skill_workflow/` — the skill-backed variant (`mode: skill`); it swaps selected step instructions for confirmed ≥1000-star community skills, each with an inline fallback (catalogued in `skills/skill_workflow_skills.md`).

- Use pack-relative filesystem paths resolved via Pack Path Resolution (`.github/HarnessFlow/<path>` in installed repos, or `<path>` from repo root in the source repo)
- During a template-triggered workflow run, read `_lib/workflow_contract.md`, `philosophy/philosophy.instructions.md`, and the `repo_info/` context files (resolved via Pack Path Resolution) before any workflow-specific work — a bare, non-templated prompt carries none of these obligations
- When the active agent is Claude Code, you have access to Claude Code native skills: `/simplify`, `/code-review`, `/batch`, `/debug`, `/claude-api`. The `simplify` / `code_review` request headers decide whether a post-implementation review runs: `false` (default) skips, `true` runs those native skills, `local` runs the pack's vendored `skills/code-simplification` / `skills/code-review-and-quality` instead. `_lib/review_skills.md` is the canonical resolution. On Codex or VS Code Copilot the native skills are unavailable, so `true` falls back to whatever the workflow file specifies — `local` is the portable choice there.
- Subagents must follow the shared Subagent Launch Contract and use the model the instructions specify via the `subagent_model` header — a specific model id runs every subagent on that exact id (a deliberate override, even if smaller); `inherit` or unset uses the main agent's model with no downgrade (in `mode: fast` the default main model is Sonnet 4.6, so `inherit` subagents run on Sonnet 4.6).
