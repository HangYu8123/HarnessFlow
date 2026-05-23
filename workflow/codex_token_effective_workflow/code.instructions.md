---
name: 'Token-Effective Code Implementation (Codex)'
description: 'Token-effective Codex instructions for implementing new functionalities with Codex agent workers, Codex-in-VS-Code compatibility, and sequential fallback'
---
# Add New Functions to an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: [target functionalities]
- input 2: [important files] (optional)
- input 3: [target repo] (optional, default to current repo)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/harness_coding_instructions/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If important files are specified in [inputs], read them. Combine that understanding with [key md files].

### Step 2 - Parallel Planning
**[PARALLEL EXECUTION - launch ALL three subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + [inputs]. Identify highly associated scripts/files, read them, and draft [plan 1] + [diagram 1] for integrating the new functionalities while keeping the codebase stable. |
| Plan B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files] + [inputs]. Follow the pipeline upstream->downstream, read all scripts, and draft [plan 2] + [diagram 2] for integrating the new functionalities. |
| Plan C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [inputs]. Decide the reading strategy and draft [plan 3] with the integration approach. |

### Step 3 - Main-Agent Final Plan
The main agent reviews [plan 1], [plan 2], [plan 3], [diagram 1], and [diagram 2], then reads any necessary files. Reject incorrect or redundant parts. Draft [final plan] that is feasible, stable, and 100% correct.

### Step 4 - Final Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + all relevant scripts + [final plan] + [inputs]. Identify overlooked side effects, integration risks, incorrect assumptions, and regressions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + [final plan] + [inputs]. Identify extra needs for skills, tools, packages, or reliable external references. Search online for reliable resources and better solutions. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent reviews [challenge report], [online resource], and [inputs]. Incorporate valid criticisms and relevant findings into [final plan]. Print the updated [final plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - Implementation
Create **Implementer** subagent (`agents/implementer.agent.md`). Pass [final plan] + [inputs] + [key md files].

**Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback.

The subagent (or the main agent, if falling back) implements [final plan] and returns [implementation report] containing changes only, with no explanations.

### Step 7 - Main-Agent Code Review and Validation
The main agent reads [implementation report] and all changed files. Review implementation correctness, integration quality, maintainability, and whether [final plan] and [inputs] are fully satisfied.

Create **QA Engineer** subagent (`agents/qa-engineer.agent.md`). Pass [inputs] + [final plan] + [implementation report] + changed files. The subagent validates the implementation from a QA perspective and, if the user requested script runs, executes the relevant pipeline. Return [implemented code QA report].

The main agent reviews [implemented code QA report]. If the main-agent code review or QA report finds issues, revise [final plan] and repeat from Step 6 until the implementation is correct and complete.

### Step 8 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Function Update===============================}
{Functionality Name + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
