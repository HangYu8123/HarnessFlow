---
name: 'Master Orchestrator'
description: 'Shared rules for running a HarnessFlow workflow instruction file'
applyTo: '**'
---

# Master Orchestrator

This repo has structured workflow instructions under `.github/HarnessFlow/workflow/`.

## Workflow Execution

**Step 0 — gate check, always first.** Only a filled-in prompt from `request_template/` (a `mode:` header block plus a numbered "Hard constraints" list naming its category's `*.instructions.md`) triggers a workflow. Any other prompt — even one that mentions workflows or pack files — fails the gate: **skip steps 1–5 and answer it normally**, with no classification, no `*.instructions.md`, and no contract/philosophy reads as workflow setup.

For a prompt that passes the gate:

1. **Read and follow** #file:_lib/workflow_contract.md before any workflow-specific work.
2. **Read the matched instruction file** in its entirety.
3. **Also read and follow** #file:philosophy/philosophy.instructions.md for general guidelines.
4. **Require** the main agent and every subagent to read and follow #file:philosophy/philosophy.instructions.md before doing workflow-specific work.
5. **Follow** the matched instruction file step-by-step to complete the request.

Handle multiple templated requests sequentially — complete one workflow before starting the next.

## Repo context files
When running a workflow, look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `.github/HarnessFlow/repo_info/`. In multi-layer repos — sub-repos or an enclosing repo carrying their own `repo_info/` — also read those layers' `codebase_overview.md` and `scripts_overview.md` per [`_lib/workflow_contract.md`](_lib/workflow_contract.md) §Key Context Files → Multi-Layer / Nested Repos.
