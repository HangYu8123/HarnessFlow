# CLAUDE.md — Claude Code CLI Entry Point

This file is auto-discovered by Claude Code when run from the repo root.
It is the Claude Code CLI equivalent of `copilot-instructions.md`.

Read and follow `.github/harness_coding_instructions/_lib/workflow_contract.md` before proceeding.
Read and follow `.github/harness_coding_instructions/philosophy/philosophy.instructions.md` for general guidelines.

---

## Request Classification

Analyze the user's prompt and determine which **one** category best matches.
Use the trigger phrases as soft signals, not strict rules. Classify based on primary intent.

| Category | Trigger Keywords / Intent | Instruction File |
|---|---|---|
| **Code Implementation** | implement, add, create, build, update, modify, write code, new feature | `.github/harness_coding_instructions/workflow/claudecode_workflow/code.instructions.md` |
| **Refactor** | refactor, restructure, reorganize, redesign, reduce redundancy, improve architecture | `.github/harness_coding_instructions/workflow/claudecode_workflow/refactor.instructions.md` |
| **Debug** | debug, fix, error, bug, crash, broken, failing, not working, traceback, exception | `.github/harness_coding_instructions/workflow/claudecode_workflow/debug.instructions.md` |
| **Query / Q&A** | explain, what is, how does, where is, why, describe, summarize, document | `.github/harness_coding_instructions/workflow/claudecode_workflow/query.instructions.md` |
| **Correctness Check** | test, verify, check, validate, review, audit, examine, ensure correctness | `.github/harness_coding_instructions/workflow/claudecode_workflow/correctness_check.instructions.md` |
| **Initialize Repo** | initialize, init, setup repo, create overview, bootstrap, first-time setup | `.github/harness_coding_instructions/workflow/claudecode_workflow/initialize.instructions.md` |

All instruction files are under `.github/harness_coding_instructions/`.

## Routing Procedure

1. **Read** the user's prompt carefully.
2. **Classify** it into exactly one category from the table above.
3. **Read the matched instruction file** in its entirety.
4. **Require** every subagent to read and follow `.github/harness_coding_instructions/_lib/workflow_contract.md` and `.github/harness_coding_instructions/philosophy/philosophy.instructions.md` before doing workflow-specific work.
5. Before creating any subagent, explicitly instruct it: "**Use the exact same model as the main agent — do not downgrade.**"
6. **Follow** the matched instruction file step-by-step to complete the request.

## If multiple intents are present
Handle sequentially — complete one workflow type before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `.github/harness_coding_instructions/repo_info/`.

## Skills
If you are Claude Code with native skills available, search `.github/harness_coding_instructions/skills/index.md` for available skills. The `claude-native-skills-subagents` skill at `.github/harness_coding_instructions/skills/claude-native-skills-subagents/SKILL.md` can be used after implementation steps.
