---
name: 'Fast Correctness Check (Claude Code)'
description: 'Fast correctness review for Claude Code: scope-driven inspection with optional script runs and false-positive challenge. Read-only'
---
# Examine Existing Repo for Correctness

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - workflow/claudecode_token_effective_workflow/_fast_rules.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Correctness_Check.md
-->

**Safety: follow `_lib/safety_rules.md`.** This workflow is read-only — it inspects and reports, and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo
- input 2: target functionalities (optional)
- input 3: important files (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.
> **Fast-tier rules (apply to every step below):** See `workflow/claudecode_token_effective_workflow/_fast_rules.md` — no Broad Analyst, no QA subagent (the main agent runs any requested scripts directly), single-analyst default, conditional Online Researcher, default-on Devils Advocate.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under .github/HarnessFlow/repo_info). Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If important files or target functionalities are specified in [inputs], read them. Combine with [key md files] into [repo context digest] and [important information] — the most relevant code, scripts, and functionalities. Decide the **scope**: whole-repo (include the full pipeline diagram) or target functionality (include upstream/downstream context).

### Step 2 - Correctness Check
Launch **one Free Analyst** (`agents/free-analyst.agent.md`). Pass [repo context digest] + [important information] + [inputs] + the chosen scope. The analyst lists the relevant files, orders them by pipeline flow, and examines correctness:
- **Target scope:** focus on the named functionality and its upstream/downstream.
- **Whole-repo scope:** traverse the full pipeline upstream→downstream by its own judgment (this replaces Broad mode).

Return [findings]. For a narrowly-scoped check (≤ ~3 files), the main agent may inspect directly and skip the subagent.

If the user requested script runs, the **main agent** runs the runnable scripts directly in pipeline order and records any errors or unexpected outputs as [run results].

### Step 3 - Main-Agent Draft Correctness Report
The main agent reads [findings] and [run results] (if any), rejects redundant or incorrect parts, reads necessary files, and drafts [draft correctness report]. Include all script failures from [run results].

### Step 4 - Draft Report Challenge and Research
Spawn **Devils Advocate by default** to guard against false positives (_fast_rules §5 default-on). Spawn **Online Researcher only** when an issue needs external documentation or a known dependency-bug reference (_fast_rules §4).

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | default-on for whole-repo; for scoped checks, when any finding is non-obvious | Read relevant scripts + [draft correctness report] + [inputs]. Challenge false positives, overlooked issues, misattributed causes, and incorrect assumptions. Return [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | a finding hinges on external docs or a known dependency bug | Read [draft correctness report] + [inputs]. Search online for reliable references. Return [online resource]. |

### Step 5 - Main-Agent Final Correctness Report
The main agent incorporates [valid criticisms] and [online resource] (when produced), prioritizing codebase evidence over external sources, and finalizes the correctness report.

### Step 6 - Documentation
1. Append to past_Correctness_Check.md, using the existing contents to determine the last CC ID (create if missing):
```md
{=============================Correctness Check: (last CC ID + 1)===============================}
Incorrect: (one sentence summary)
Potential Cause: (brief precise bullet points)
```
2. Cross-check known_issues.md. If any found problems were marked as fixed there, add: "the attempted fix actually failed."
