---
name: 'Token-Effective Correctness Check (Codex)'
description: 'Token-effective Codex instructions for verifying repo correctness: main-agent scope-driven inspection with optional script runs and one parallel challenge + research subagent step. Read-only — with Codex agent workers and sequential fallback'
---
# Examine Existing Repo for Correctness

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Correctness_Check.md
-->

**Safety: follow `_lib/safety_rules.md`.**

This workflow is read-only — it inspects and reports, and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo
- input 2: target functionalities (optional)
- input 3: important files (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under .github/HarnessFlow/repo_info). Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files or target functionalities are specified in [inputs], read them. Condense the understanding and identify [important information] — the most relevant code, scripts, and functionalities. Decide the **scope**: whole-repo (include the full pipeline diagram) or target functionality (include upstream/downstream context).

### Step 2 - Correctness Analysis
Based on [key md files] + [important information] + the chosen scope, the main agent lists the relevant files, orders them by pipeline flow, reads them, and examines correctness:
- **Target scope:** focus on the named functionality and its upstream/downstream.
- **Whole-repo scope:** traverse the full pipeline upstream→downstream.

If the user requested script runs, run the runnable scripts directly in pipeline order and record any errors or unexpected outputs as [run results].

Draft [draft correctness report], including all script failures from [run results].

### Step 3 - Report Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [key md files] + [draft correctness report] + [inputs], and all relevant scripts if needed. Assume the report is wrong and flawed; challenge false positives, overlooked issues, misattributed causes, and incorrect assumptions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [key md files] + [draft correctness report] + [inputs]. Search online for reliable references and known dependency bugs. Return [online resource]. |

### Step 4 - Final Correctness Report
The main agent incorporates [challenge report] and [online resource] (when produced), prioritizing codebase evidence over external sources, and finalizes the correctness report. Print it.

### Step 5 - Documentation
1. Append to past_Correctness_Check.md, using the existing contents to determine the last CC ID (create if missing):
```md
{=============================Correctness Check: (last CC ID + 1)===============================}
Incorrect: (one sentence summary)
Potential Cause: (brief precise bullet points)
```
2. Cross-check known_issues.md. If any found problems were marked as fixed there, add: "the attempted fix actually failed."
