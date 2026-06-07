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

| Category | Trigger Keywords / Intent | Instruction File |
|---|---|---|
| **Code Implementation** | implement, add, create, build, update, modify, write code, new feature, change behavior | #file:workflow/vscode_workflow/code.instructions.md |
| **Refactor** | refactor, restructure, reorganize, redesign, reduce redundancy, improve architecture, reduce technical debt | #file:workflow/vscode_workflow/refactor.instructions.md |
| **Debug** | debug, fix, error, bug, crash, broken, failing, not working, traceback, exception, investigate issue | #file:workflow/vscode_workflow/debug.instructions.md |
| **Query / Q&A** | explain, what is, how does, where is, why, describe, summarize, document, question about code | #file:workflow/vscode_workflow/query.instructions.md |
| **Correctness Check** | test, verify, check, validate, review, audit, examine, ensure correctness, consistency check | #file:workflow/vscode_workflow/correctness_check.instructions.md |
| **Exec (Cmd/Skill Execution)** | execute, run, exec, invoke, launch command, run skill, run script, trigger, run cmd | #file:workflow/vscode_workflow/exec.instructions.md |
| **PR Creation** | pull request, PR, stacked PR, break down branch, split PR, create PR | #file:workflow/vscode_workflow/pr.instructions.md |
| **Initialize Repo** | initialize, init, setup repo, create overview, bootstrap, first-time setup | #file:workflow/vscode_workflow/initialize.instructions.md |

All instruction files are under `.github/HarnessFlow/`.

## Routing Procedure

1. **Read** the user's prompt carefully.
2. **Classify** it into exactly one category from the table above.
3. **Read the matched instruction file** in its entirety.
4. **Also read and follow** #file:philosophy/philosophy.instructions.md for general guidelines.
5. **Require** the routed main agent and every subagent to read and follow #file:philosophy/philosophy.instructions.md before doing workflow-specific work.
6. **Follow** the matched instruction file step-by-step to complete the request.

## If multiple intents are present
Handle sequentially — complete one workflow type before starting the next.

## Repo context files
Look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `.github/HarnessFlow/repo_info/`.
