---
paths: [".github/HarnessFlow/workflow/**"]
---

# Workflow Rules

When working with files under `.github/HarnessFlow/workflow/`, these are the shared, platform-adaptive workflow files (one set per mode, each used by Claude Code, Codex, and VS Code Copilot):

- `workflow/general_workflow/` — the thorough general workflows (`mode: general`).
- `workflow/token_effective_workflow/` — the streamlined token-efficient workflows (`mode: fast`).
- `workflow/skill_workflow/` — the skill-backed variant (`mode: skill`); it swaps selected step instructions for confirmed ≥1000-star community skills, each with an inline fallback (catalogued in `skills/skill_workflow_skills.md`).

- Use pack-relative filesystem paths resolved via Pack Path Resolution (`.github/HarnessFlow/<path>` in installed repos, or `<path>` from repo root in the source repo)
- During a template-triggered workflow run, the main agent reads `_lib/workflow_contract.md`, `philosophy/philosophy.instructions.md`, and the `repo_info/` context files (resolved via Pack Path Resolution) before any workflow-specific work; each spawned subagent reads the shorter `_lib/subagent_contract.md` plus `philosophy/philosophy.instructions.md` instead, and uses the repo context digest it was handed rather than re-reading `repo_info/` — a bare, non-templated prompt carries none of these obligations
- When the active agent is Claude Code, you have access to Claude Code native skills: `/simplify`, `/code-review`, `/batch`, `/debug`, `/claude-api`. The `simplify` / `code_review` request headers decide whether a post-implementation review runs: `false` (default) skips, `true` runs those native skills, `local` runs the pack's local `skills/code-simplification` / `skills/code-review-and-quality` instead. `_lib/review_skills.md` is the canonical resolution. On Codex or VS Code Copilot the native skills are unavailable, so `true` falls back to whatever the workflow file specifies — `local` is the portable choice there.
- Spawn every worker by its **agent type** — the `<slug>` of `agents/<slug>.agent.md`, installed as `.claude/agents/<slug>.md` (Claude Code) and `.codex/agents/<slug>.toml` (Codex), e.g. `focus-analyst`. The definition is already the subagent's system prompt, so the spawn prompt carries only task-specific content — never the role text, behavioral contract, or output format. Fall back to a full inline prompt only when the definition is not installed. `sync_agent_definitions.py` regenerates both sets from `agents/*.agent.md`.
- Subagents must follow the shared Subagent Launch Contract and use the model the instructions specify via the `subagent_model` header — a specific model id runs every subagent on that exact id (a deliberate override, even if smaller); `inherit` or unset uses the main agent's model with no downgrade (in `mode: fast` the default main model is Sonnet 4.6, so `inherit` subagents run on Sonnet 4.6).
- Effort is the second dial on the same spawn, never optional: the `subagent_effort` header (`inherit` | `low` | `medium` | `high` | `xhigh` | `max`; templates ship `high`), replaced by `online_researcher_effort` for the Online Researcher only. `inherit` means follow the session and add nothing; any other level goes in the agent definition's `effort:` field where the spawn uses one, and otherwise into the prompt as `effort: <level> — binding budget, not a hint`, because the `Task` tool has no per-invocation effort parameter. In a `dispatch:` loop both levels cross the boundary unchanged.
