# AGENTS.md — Codex Entry Point

This file is auto-discovered by Codex when run from the repo root, including Codex CLI and Codex in VS Code.
It is the Codex CLI equivalent of `copilot-instructions.md`.

---

## Pack Path Resolution

Resolve all pack-relative paths in this order:
1. `.github/HarnessFlow/<path>` from the target repo root (installed layout).
2. `<path>` from the repo root (source repo / pack root layout).

Apply this rule to every path referenced in this file, workflow files, and agent definitions.

---

## Workflow Execution

A filled-in prompt from `request_template/` names the matched instruction file for its category and `mode:`.

1. **Read and follow** `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before any workflow-specific work.
2. **Read** the matched instruction file in its entirety.
3. **Require** every subagent to read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before doing workflow-specific work.
4. **Subagent model:** Create every subagent on the model the instructions specify — the `subagent_model` header — following the Subagent Launch Contract's model-selection steps in `_lib/workflow_contract.md` (resolved via Pack Path Resolution). Since Codex does not auto-inherit the main agent's model (a worker's model is set via its named custom-agent definition), explicitly instruct every subagent: "**Use the model the instructions specify via `subagent_model`: a specific id is a deliberate override — use it even if it is smaller; when it is `inherit` or unset, use the exact same model as the main agent and do not downgrade.**"
5. **Follow** the matched instruction file step-by-step to complete the request.

Handle multiple templated requests sequentially — complete one workflow before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `repo_info/` (resolved via Pack Path Resolution). In multi-layer repos — sub-repos or an enclosing repo carrying their own `repo_info/` — also read those layers' `codebase_overview.md` and `scripts_overview.md` per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.
