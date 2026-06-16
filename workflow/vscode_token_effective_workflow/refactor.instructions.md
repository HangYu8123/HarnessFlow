---
name: 'Fast Refactor'
description: 'Streamlined refactoring: main-agent plan, one parallel challenge + research subagent step, direct implementation, main-agent review with self-challenge, and behavior-preservation validation'
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

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If target files are specified in [inputs], read them. Condense the understanding for use in later steps.

### Step 2 - Refactor Analysis
**Local skill discovery (before drafting [plan]):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` — scan `skills/index.md` for any local skill whose trigger fits this task; on a confirmed match, read its `SKILL.md` and integrate it into [plan]. Record the result as [local skills] (or "none relevant").

Based on [key md files] + [inputs], the main agent reads the relevant files and proposes a [plan] for addressing the target refactors + a [comparison] (before/after) indicating the changes + behavior-preservation notes.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [key md files] + [plan] + [comparison] + [inputs], and additional scripts if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify overlooked side effects, integration risks, incorrect assumptions, over-engineering and regressions. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [key md files] + [plan] + [comparison] + [inputs]. Search online for reliable references, established solutions, and available resources. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
The main agent implements [final plan] directly and records [implementation report] containing changes only, with no explanations.

### Step 6 - Code Review and Validation
1. The main agent should claim every item in the [implementation report] is wrong, and start explaining why it is wrong. After explaining all the items, the main agent should then draft a [post-impl challenge report].
2. The main agent reviews the changes directly, save the conclusion as [direct review].

Based on [post-impl challenge report] + [direct review], perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Refactor Update===============================}
{Refactor Summary + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
