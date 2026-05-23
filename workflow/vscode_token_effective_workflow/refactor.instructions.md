---
name: 'Fast Refactor'
description: 'Streamlined instructions for refactoring with maximum parallelization'
---
# Refactor an Existing Repo

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
-->

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: target refactor functionalities/repository/scripts
- input 2: target files (optional)
- input 3: target repo (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `#file:../../_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/harness_coding_instructions/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If target files are specified in [inputs], read them. Combine that understanding with [key md files].

### Step 2 - Parallel Refactor Analysis
**[PARALLEL EXECUTION - launch ALL five subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Architecture Analyst** (`agents/architecture-analyst.agent.md`) | Architecture | Read [key md files] + [inputs]. Analyze inappropriate designs and architecture improvements. Draft [plan 1] + [comparison 1]. |
| Plan B | **Redundancy Analyst** (`agents/redundancy-analyst.agent.md`) | Redundancy | Read [key md files] + [inputs]. Analyze redundant code and overlapping implementations. Draft [plan 2] + [comparison 2]. |
| Plan C | **Robustness Analyst** (`agents/robustness-analyst.agent.md`) | Robustness | Read [key md files] + [inputs]. Analyze robustness issues and potential bugs. Draft [plan 3] + [comparison 3]. |
| Plan D | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [inputs]. Decide the reading strategy and draft [plan 4]. |
| Plan E | **Complexity Analyst** (`agents/complexity-analyst.agent.md`) | Complexity reduction | Read [key md files] + [inputs]. Analyze complexity directly and draft a plan to simplify without changing behavior. Return [plan 5] + [comparison 4]. |

### Step 3 - Principal Review and Main-Agent Final Plan
Create **Principal Engineer** subagent (`agents/principal-engineer.agent.md`). Pass [inputs], [plan 1], [plan 2], [plan 3], [plan 4], [plan 5], [comparison 1], [comparison 2], [comparison 3], [comparison 4], and [key md files]. The subagent reviews correctness, feasibility, dependency ordering, and redundant or risky plan items. Return [plan review].

The main agent reads necessary target files and performs the code-quality review directly. Record [main-agent code review notes] covering maintainability, robustness, readability, and behavioral risks.

The main agent combines [plan 1-5], [comparison 1-4], [plan review], and [main-agent code review notes]. Reject incorrect or redundant parts. Draft [final plan] and verify each step for target files, known_issues.md conflicts, upstream/downstream dependencies, and behavior preservation.

### Step 4 - Final Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + relevant scripts + [final plan] + [inputs]. Identify overlooked side effects, integration risks, incorrect assumptions, and regressions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + [final plan] + [inputs]. Identify extra needs for skills, tools, packages, patterns, or migration references. Search online for reliable resources and solutions. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] into [final plan]. Print [final plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - Implementation
Create **Implementer** subagent (`agents/implementer.agent.md`). Pass [final plan] + [inputs] + [key md files].

**Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback.

The subagent (or the main agent, if falling back) implements [final plan] and returns [implementation report] containing changes only, with no explanations.

### Step 7 - Main-Agent Code Review and Validation
The main agent reads [implementation report] and all changed files. Review refactor correctness, behavior preservation, integration quality, maintainability, and whether [inputs] and [final plan] are fully satisfied.

Create **QA Engineer** subagent (`agents/qa-engineer.agent.md`). Pass [inputs] + [final plan] + [implementation report] + changed files. The subagent validates the refactor from a QA perspective and, if the user requested script runs, executes the relevant pipeline. Return [QA report].

If the main-agent code review or [QA report] finds issues, revise [final plan] and repeat from Step 6 until the refactor is correct and complete.

### Step 8 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Refactor Update===============================}
{Refactor Summary + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
