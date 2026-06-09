# CLAUDE.md — Claude Code CLI Entry Point

This file is auto-discovered by Claude Code when run from the repo root.
It is the Claude Code CLI equivalent of `copilot-instructions.md`.

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
If the prompt explicitly includes `mode: fast`, use the matching file under `workflow/claudecode_token_effective_workflow/`. If the prompt includes `mode: general` or does not specify a mode, use `workflow/claudecode_workflow/`.

| Category | Trigger Keywords / Intent | General Instruction File | Fast Instruction File |
|---|---|---|---|
| **Code Implementation** | implement, add, create, build, update, modify, write code, new feature | `workflow/claudecode_workflow/code.instructions.md` | `workflow/claudecode_token_effective_workflow/code.instructions.md` |
| **Refactor** | refactor, restructure, reorganize, redesign, reduce redundancy, improve architecture | `workflow/claudecode_workflow/refactor.instructions.md` | `workflow/claudecode_token_effective_workflow/refactor.instructions.md` |
| **Debug** | debug, fix, error, bug, crash, broken, failing, not working, traceback, exception | `workflow/claudecode_workflow/debug.instructions.md` | `workflow/claudecode_token_effective_workflow/debug.instructions.md` |
| **Query / Q&A** | explain, what is, how does, where is, why, describe, summarize, document | `workflow/claudecode_workflow/query.instructions.md` | `workflow/claudecode_token_effective_workflow/query.instructions.md` |
| **Correctness Check** | test, verify, check, validate, review, audit, examine, ensure correctness | `workflow/claudecode_workflow/correctness_check.instructions.md` | `workflow/claudecode_token_effective_workflow/correctness_check.instructions.md` |
| **Exec (Cmd/Skill Execution)** | execute, run, exec, invoke, launch command, run skill, run script, trigger | `workflow/claudecode_workflow/exec.instructions.md` | `workflow/claudecode_token_effective_workflow/exec.instructions.md` |
| **PR Creation** | pull request, PR, stacked PR, break down branch, split PR, create PR | `workflow/claudecode_workflow/pr.instructions.md` | `workflow/claudecode_token_effective_workflow/pr.instructions.md` |
| **Initialize Repo** | initialize, init, setup repo, create overview, bootstrap, first-time setup | `workflow/claudecode_workflow/initialize.instructions.md` | `workflow/claudecode_token_effective_workflow/initialize.instructions.md` |

All instruction files are resolved via Pack Path Resolution.

## Routing Procedure

1. **Read** the user's prompt carefully.
2. **Classify** it into exactly one category from the table above.
3. **Select general or fast mode**, then read the matched instruction file in its entirety.
4. **Require** every subagent to read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` (resolved via Pack Path Resolution) before doing workflow-specific work.
5. **Model parity:** In Claude Code, subagents automatically inherit the main agent's model (see `_lib/workflow_contract.md` §Implementer Model Verification Fallback), so there is no separate model-selection step — just do not downgrade. On other platforms, follow the Subagent Launch Contract's model-parity steps in `_lib/workflow_contract.md`.
6. **Follow** the matched instruction file step-by-step to complete the request.

## If multiple intents are present
Handle sequentially — complete one workflow type before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `repo_info/` (resolved via Pack Path Resolution).

## Skills
If you are Claude Code with native skills available, search `skills/index.md` for available skills. The `claude-native-skills-subagents` skill at `skills/claude-native-skills-subagents/SKILL.md` can be used after implementation steps.
