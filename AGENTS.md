# AGENTS.md — Codex Entry Point

This file is auto-discovered by Codex when run from the repo root, including Codex CLI and Codex in VS Code.
It is the Codex CLI equivalent of `copilot-instructions.md`.

Read and follow `.github/harness_coding_instructions/_lib/workflow_contract.md` before proceeding.
Read and follow `.github/harness_coding_instructions/philosophy/philosophy.instructions.md` for general guidelines.

---

## Request Classification

Analyze the user's prompt and determine which **one** category best matches.
Use the trigger phrases as soft signals, not strict rules. Classify based on primary intent.
If the prompt explicitly includes `mode: fast`, use the matching file under `workflow/codex_token_effective_workflow/`. If the prompt includes `mode: general` or does not specify a mode, use `workflow/codex_workflow/`.

| Category | Trigger Keywords / Intent | General Instruction File | Fast Instruction File |
|---|---|---|---|
| **Code Implementation** | implement, add, create, build, update, modify, write code, new feature | `.github/harness_coding_instructions/workflow/codex_workflow/code.instructions.md` | `.github/harness_coding_instructions/workflow/codex_token_effective_workflow/code.instructions.md` |
| **Refactor** | refactor, restructure, reorganize, redesign, reduce redundancy, improve architecture | `.github/harness_coding_instructions/workflow/codex_workflow/refactor.instructions.md` | `.github/harness_coding_instructions/workflow/codex_token_effective_workflow/refactor.instructions.md` |
| **Debug** | debug, fix, error, bug, crash, broken, failing, not working, traceback, exception | `.github/harness_coding_instructions/workflow/codex_workflow/debug.instructions.md` | `.github/harness_coding_instructions/workflow/codex_token_effective_workflow/debug.instructions.md` |
| **Query / Q&A** | explain, what is, how does, where is, why, describe, summarize, document | `.github/harness_coding_instructions/workflow/codex_workflow/query.instructions.md` | `.github/harness_coding_instructions/workflow/codex_token_effective_workflow/query.instructions.md` |
| **Correctness Check** | test, verify, check, validate, review, audit, examine, ensure correctness | `.github/harness_coding_instructions/workflow/codex_workflow/correctness_check.instructions.md` | `.github/harness_coding_instructions/workflow/codex_token_effective_workflow/correctness_check.instructions.md` |
| **Initialize Repo** | initialize, init, setup repo, create overview, bootstrap, first-time setup | `.github/harness_coding_instructions/workflow/codex_workflow/initialize.instructions.md` | `.github/harness_coding_instructions/workflow/codex_token_effective_workflow/initialize.instructions.md` |

All instruction files are under `.github/harness_coding_instructions/`.

## Routing Procedure

1. **Read** the user's prompt carefully.
2. **Classify** it into exactly one category from the table above.
3. **Select general or fast mode**, then read the matched instruction file in its entirety.
4. **Require** every subagent to read and follow `.github/harness_coding_instructions/_lib/workflow_contract.md` and `.github/harness_coding_instructions/philosophy/philosophy.instructions.md` before doing workflow-specific work.
5. Before creating any subagent, explicitly instruct it: "**Use the exact same model as the main agent — do not downgrade.**"
6. **Follow** the matched instruction file step-by-step to complete the request.

## If multiple intents are present
Handle sequentially — complete one workflow type before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `.github/harness_coding_instructions/repo_info/`.
