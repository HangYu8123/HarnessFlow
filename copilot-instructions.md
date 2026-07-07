---
name: 'Master Orchestrator'
description: 'Routes user requests to the appropriate workflow instruction file'
applyTo: '**'
---

# Master Orchestrator — Instruction Router

This repo has structured workflow instructions. **Before doing any work**, read and follow #file:_lib/workflow_contract.md, then classify the user's request into one of the categories below and **read and follow** the corresponding instruction file in full.

## Request Classification

Analyze the user's prompt and determine which **one** category **best matches**.
Use the trigger phrases as soft signals, not strict rules. Classify based on the user's primary intent, even if none of the exact keywords appear. If multiple categories seem possible, pick the one that best reflects the main action the user wants.

If the prompt explicitly includes `mode: fast`, use the matching file under `workflow/token_effective_workflow/` (the Fast column). If the prompt explicitly includes `mode: skill`, use the matching file (same category filename) under `workflow/skill_workflow/` (the Skill column) — the unified skill-backed variant (one shared family for all tools) that replaces selected step instructions with confirmed ≥1000-star community skills (catalogued in #file:skills/skill_workflow_skills.md), each with an inline fallback. If the prompt includes `mode: general` or does not specify a mode, use `workflow/general_workflow/` (the General column).

| Category | Trigger Keywords / Intent | General Instruction File | Fast Instruction File | Skill Instruction File |
|---|---|---|---|---|
| **Code Implementation** | implement, add, create, build, update, modify, write code, new feature, change behavior | #file:workflow/general_workflow/code.instructions.md | #file:workflow/token_effective_workflow/code.instructions.md | #file:workflow/skill_workflow/code.instructions.md |
| **Refactor** | refactor, restructure, reorganize, redesign, reduce redundancy, improve architecture, reduce technical debt | #file:workflow/general_workflow/refactor.instructions.md | #file:workflow/token_effective_workflow/refactor.instructions.md | #file:workflow/skill_workflow/refactor.instructions.md |
| **Debug** | debug, fix, error, bug, crash, broken, failing, not working, traceback, exception, investigate issue | #file:workflow/general_workflow/debug.instructions.md | #file:workflow/token_effective_workflow/debug.instructions.md | #file:workflow/skill_workflow/debug.instructions.md |
| **Query / Q&A** | explain, what is, how does, where is, why, describe, summarize, document, question about code | #file:workflow/general_workflow/query.instructions.md | #file:workflow/token_effective_workflow/query.instructions.md | #file:workflow/skill_workflow/query.instructions.md |
| **Correctness Check** | test, verify, check, validate, review, audit, examine, ensure correctness, consistency check | #file:workflow/general_workflow/correctness_check.instructions.md | #file:workflow/token_effective_workflow/correctness_check.instructions.md | #file:workflow/skill_workflow/correctness_check.instructions.md |
| **Exec (Cmd/Skill Execution)** | execute, run, exec, invoke, launch command, run skill, run script, trigger, run cmd | #file:workflow/general_workflow/exec.instructions.md | #file:workflow/token_effective_workflow/exec.instructions.md | #file:workflow/skill_workflow/exec.instructions.md |
| **PR Creation** | pull request, PR, stacked PR, break down branch, split PR, create PR | #file:workflow/general_workflow/pr.instructions.md | #file:workflow/token_effective_workflow/pr.instructions.md | #file:workflow/skill_workflow/pr.instructions.md |
| **Initialize Repo** | initialize, init, setup repo, create overview, bootstrap, first-time setup | #file:workflow/general_workflow/initialize.instructions.md | #file:workflow/token_effective_workflow/initialize.instructions.md | #file:workflow/skill_workflow/initialize.instructions.md |
| **Loop** | loop, iterate, repeat, keep going until, until <condition>, poll, recurring, converge, run until done, autonomous until | #file:workflow/general_workflow/loop.instructions.md | #file:workflow/token_effective_workflow/loop.instructions.md | #file:workflow/skill_workflow/loop.instructions.md |

All instruction files are under `.github/HarnessFlow/`.

## Routing Procedure

1. **Read** the user's prompt carefully.
2. **Classify** it into exactly one category from the table above.
3. **Select general, fast, or skill mode** per the `mode:` rule above (default general), then pick the matching cell from the General, Fast, or Skill column.
4. **Read the matched instruction file** in its entirety.
5. **Also read and follow** #file:philosophy/philosophy.instructions.md for general guidelines.
6. **Require** the routed main agent and every subagent to read and follow #file:philosophy/philosophy.instructions.md before doing workflow-specific work.
7. **Follow** the matched instruction file step-by-step to complete the request.

## If multiple intents are present
Handle sequentially — complete one workflow type before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `.github/HarnessFlow/repo_info/`.
