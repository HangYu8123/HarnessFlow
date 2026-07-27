---
name: 'Master Orchestrator'
description: 'Shared rules for running a HarnessFlow workflow instruction file'
applyTo: '**'
---

# Master Orchestrator

This repo has structured workflow instructions under `.github/HarnessFlow/workflow/`.

## Activation Gate

HarnessFlow is opt-in. Start it only when the current request is a completed `request_template/` prompt containing its `mode:` block, "READ THROUGH" sentence, numbered constraints and platform table, and user task content. Auto-discovery, plain prompts, inferred intent, unfilled templates, quoted history, and assistant or tool logs never start it; do not reconstruct a template. Without a valid template-started run, answer normally; do not classify, read workflow setup files, launch workflow agents, or run workflow-only skill discovery. Follow-up corrections may continue a valid run without repeating its template.

## Workflow Execution

Only after the current request passes the Activation Gate:

1. **Read and follow** #file:_lib/workflow_contract.md before any workflow-specific work.
2. **Read the matched instruction file** in its entirety.
3. **Also read and follow** #file:philosophy/philosophy.instructions.md for general guidelines.
4. **Require** the main agent and every subagent to read and follow #file:philosophy/philosophy.instructions.md before doing workflow-specific work. Subagents additionally read #file:_lib/subagent_contract.md — the short, subagent-facing subset of the workflow contract — instead of #file:_lib/workflow_contract.md.
5. **Follow** the matched instruction file step-by-step to complete the request.

Handle multiple templated requests sequentially — complete one workflow before starting the next.

## Repo context files
When running a workflow, look for context files (`codebase_overview.md`, `scripts_overview.md`, `update_logs.md`, etc.) under `.github/HarnessFlow/repo_info/`. In multi-layer repos — sub-repos or an enclosing repo carrying their own `repo_info/` — also read those layers' `codebase_overview.md` and `scripts_overview.md` per [`_lib/workflow_contract.md`](_lib/workflow_contract.md) §Key Context Files → Multi-Layer / Nested Repos.
