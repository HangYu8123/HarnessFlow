# AGENTS.md — Codex Entry Point

This file is auto-discovered by Codex when run from the repo root, including Codex CLI and Codex in VS Code.
It is the Codex CLI equivalent of `copilot-instructions.md`.

Read and follow `_lib/workflow_contract.md` (resolved via Pack Path Resolution) before proceeding.
Read and follow `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) for general guidelines.

---

## Pack Path Resolution

Resolve all pack-relative paths in this order:
1. `.github/HarnessFlow/<path>` from the target repo root (installed layout).
2. `<path>` from the repo root (source repo / pack root layout).

Apply this rule to every path referenced in this file, workflow files, and agent definitions.

---

## Request Classification

Analyze the user's prompt and determine which **one** category best matches.
Use the trigger phrases as soft signals, not strict rules. Classify based on primary intent.
If the prompt explicitly includes `mode: fast`, use the matching file under `workflow/token_effective_workflow/`. If the prompt explicitly includes `mode: skill`, use the matching file (same category filename) under `workflow/skill_workflow/` — the unified skill-backed variant (one shared family for all tools) that replaces selected step instructions with confirmed ≥1000-star community skills (catalogued in `skills/skill_workflow_skills.md`), each with an inline fallback. If the prompt includes `mode: general` or does not specify a mode, use `workflow/general_workflow/`.

| Category | Trigger Keywords / Intent | General Instruction File | Fast Instruction File |
|---|---|---|---|
| **Code Implementation** | implement, add, create, build, update, modify, write code, new feature | `workflow/general_workflow/code.instructions.md` | `workflow/token_effective_workflow/code.instructions.md` |
| **Refactor** | refactor, restructure, reorganize, redesign, reduce redundancy, improve architecture | `workflow/general_workflow/refactor.instructions.md` | `workflow/token_effective_workflow/refactor.instructions.md` |
| **Debug** | debug, fix, error, bug, crash, broken, failing, not working, traceback, exception | `workflow/general_workflow/debug.instructions.md` | `workflow/token_effective_workflow/debug.instructions.md` |
| **Query / Q&A** | explain, what is, how does, where is, why, describe, summarize, document | `workflow/general_workflow/query.instructions.md` | `workflow/token_effective_workflow/query.instructions.md` |
| **Correctness Check** | test, verify, check, validate, review, audit, examine, ensure correctness | `workflow/general_workflow/correctness_check.instructions.md` | `workflow/token_effective_workflow/correctness_check.instructions.md` |
| **Exec (Cmd/Skill Execution)** | execute, run, exec, invoke, launch command, run skill, run script, trigger | `workflow/general_workflow/exec.instructions.md` | `workflow/token_effective_workflow/exec.instructions.md` |
| **PR Creation** | pull request, PR, stacked PR, break down branch, split PR, create PR | `workflow/general_workflow/pr.instructions.md` | `workflow/token_effective_workflow/pr.instructions.md` |
| **Initialize Repo** | initialize, init, setup repo, create overview, bootstrap, first-time setup | `workflow/general_workflow/initialize.instructions.md` | `workflow/token_effective_workflow/initialize.instructions.md` |
| **Loop** | loop, iterate, repeat, keep going until, until <condition>, poll, recurring, converge, run until done, autonomous until | `workflow/general_workflow/loop.instructions.md` | `workflow/token_effective_workflow/loop.instructions.md` |

All instruction files are resolved via Pack Path Resolution.

## Routing Procedure

1. **Read** the user's prompt carefully.
2. **Classify** it into exactly one category from the table above.
3. **Select general, fast, or skill mode**, then read the matched instruction file in its entirety.
4. **Require** every subagent to read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before doing workflow-specific work.
5. **Subagent model:** Create every subagent on the model the instructions specify — the `subagent_model` header — following the Subagent Launch Contract's model-selection steps in `_lib/workflow_contract.md` (resolved via Pack Path Resolution). Since Codex does not auto-inherit the main agent's model (a worker's model is set via its named custom-agent definition), explicitly instruct every subagent: "**Use the model the instructions specify via `subagent_model`: a specific id is a deliberate override — use it even if it is smaller; when it is `inherit` or unset, use the exact same model as the main agent and do not downgrade.**"
6. **Follow** the matched instruction file step-by-step to complete the request.

## If multiple intents are present
Handle sequentially — complete one workflow type before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `repo_info/` (resolved via Pack Path Resolution).
