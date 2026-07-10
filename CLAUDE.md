# CLAUDE.md — Claude Code CLI Entry Point

This file is auto-discovered by Claude Code when run from the repo root.
It is the Claude Code CLI equivalent of `copilot-instructions.md`.

---

## Pack Path Resolution

Resolve all pack-relative paths in this order:
1. `.github/HarnessFlow/<path>` from the target repo root (installed layout).
2. `<path>` from the repo root (source repo / pack root layout).

Apply this rule to every path referenced in this file, workflow files, and agent definitions.

---

## Workflow Execution

A filled-in prompt from `request_template/` names the matched instruction file for its category and `mode:`.

1. **Read and follow**, as the main agent and in their entirety, `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution). Do this before any workflow-specific work and before any tool call that reads or writes code. Never delegate this read to a subagent in place of doing it yourself.
2. **Read** the matched instruction file in its entirety.
3. **Require** every subagent to read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before doing workflow-specific work.
4. **Subagent model:** Create every subagent on the model the instructions specify — the `subagent_model` header (see `_lib/workflow_contract.md` §Subagent Launch Contract). In Claude Code the main agent sets the subagent's model when spawning it: a specific `subagent_model` id runs the subagent on that exact id (a deliberate override — honor it even if smaller), while `inherit` or unset uses the main agent's model with no downgrade. On other platforms, follow the Subagent Launch Contract's model-selection steps in `_lib/workflow_contract.md`.
5. **Follow** the matched instruction file step-by-step to complete the request.

Handle multiple templated requests sequentially — complete one workflow before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `repo_info/` (resolved via Pack Path Resolution). In multi-layer repos — sub-repos or an enclosing repo carrying their own `repo_info/` — also read those layers' `codebase_overview.md` and `scripts_overview.md` per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

## Skills
If you are Claude Code with native skills available, search `skills/index.md` for available skills. The `claude-native-skills-subagents` skill at `skills/claude-native-skills-subagents/SKILL.md` can be used after implementation steps.
