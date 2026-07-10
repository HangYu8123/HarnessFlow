---
name: 'Fast Correctness Check'
description: 'Unified token-effective (fast) correctness workflow for Claude Code, Codex, and VS Code Copilot: main-agent scope-driven inspection with optional script runs, then one parallel challenge + research subagent step. Read-only.'
---
# Examine Existing Repo for Correctness

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Correctness_Check.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

This workflow is read-only — it inspects and reports, and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo
- input 2: target functionalities (optional)
- input 3: important files (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under `repo_info/`, resolved by Pack Path Resolution). Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames. In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files or target functionalities are specified in [inputs], read them. Per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, condense the understanding into a **[repo context digest]** (Claude Code passes it inline to subagents; Codex and VS Code Copilot keep [key md files] for subagents to read directly) and identify [important information] — the most relevant code, scripts, and functionalities. Decide the **scope**: whole-repo (include the full pipeline diagram) or target functionality (include upstream/downstream context).

### Step 2 - Correctness Analysis
Based on the repo context (per §Context Passing) + [important information] + the chosen scope, the main agent lists the relevant files, orders them by pipeline flow, reads them, and examines correctness:
- **Target scope:** focus on the named functionality and its upstream/downstream.
- **Whole-repo scope:** traverse the full pipeline upstream→downstream.

If the user requested script runs, run the runnable scripts directly in pipeline order and record any errors or unexpected outputs as [run results].

Draft [draft correctness report], including all script failures from [run results].

### Step 3 - Report Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read the repo context (per §Context Passing) + [draft correctness report] + [inputs], and all relevant scripts if needed. Assume every item in the report is wrong and flawed, then explain why — challenge false positives, overlooked issues, misattributed causes, and incorrect assumptions. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read the repo context (per §Context Passing) + [draft correctness report] + [inputs]. Actually call the platform's live web search/fetch tool(s) (never answer from prior knowledge) to find reliable references and known dependency bugs, returning the source URLs as proof. Return [online resource]. |

### Step 4 - Final Correctness Report
The main agent incorporates [challenge report] and [online resource] (when produced), prioritizing codebase evidence over external sources, and finalizes the correctness report. Print it.

### Step 5 - Documentation
1. Append to past_Correctness_Check.md, using the existing contents to determine the last CC ID (create if missing):
```md
{=============================Correctness Check: (current time, YYYY-MM-DD HH:MM) — (last CC ID + 1)===============================}
Incorrect: (one sentence summary)
Potential Cause: (brief precise bullet points)
```
2. Cross-check known_issues.md. If any found problems were marked as fixed there, add: "the attempted fix actually failed."
