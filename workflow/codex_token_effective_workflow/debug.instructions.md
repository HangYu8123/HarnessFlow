---
name: 'Token-Effective Debug Workflow (Codex)'
description: 'Token-effective Codex instructions for debugging with Codex agent workers, Codex-in-VS-Code compatibility, and sequential fallback'
---
# Debug Instructions

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

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target bug
- input 2: suspected reasons (optional)
- input 3: important scripts (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in _lib/workflow_contract.md.
- Before creating any subagent, the main agent must identify [main agent model].
- Every subagent prompt must include [inputs], exact task, expected output label, required context files, and: "**Create subagent with the exact [main agent model] - do not downgrade.**"
- Subagents must use [main agent model].
- After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.
- If a subagent is not created, uses a different model, fails, or returns a low-quality or irrelevant result, retry that same subagent up to 3 times. If it still fails, the main agent performs that subagent's task directly and records a [fallback result].

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using Codex agent workers when available. This applies to Codex CLI and Codex running in VS Code; if worker spawning or model parity is unavailable, run the same tasks sequentially or perform the documented fallback in the main agent.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/harness_coding_instructions/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 0 (Optional) - Reproduce the Bug
This step is skipped by default; only run it if `reproduce: true` is set in the debug request.

Create a **Bug Reproducer** subagent (`agents/bug-reproducer.agent.md`). Pass [inputs] + [key md files]. The subagent identifies target scripts and entry points, runs the relevant bug path in the correct order per scripts_overview.md, captures stdout, stderr, exit codes, error messages, and tracebacks, then returns [reproduction report]. The main agent stores [reproduction report] and passes it to all later analysis.

### Step 1 - Parallel Diagnosis
**[PARALLEL EXECUTION - launch ALL four subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Code A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | History check | Read [key md files] + [inputs]. Check whether the bug was previously addressed. If yes, follow the codebase diagram through associated scripts and infer why the prior fix failed. Return [history report]. |
| Code B | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + [inputs] + important scripts. Check potential bug causes from suspected reasons and specified scripts. Return [bug reason 1]. |
| Code C | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files] + [inputs]. Follow the pipeline upstream->downstream and check potential bug causes from a broader perspective. Return [bug reason 2]. |
| Code D | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [inputs]. Decide the reading strategy and identify potential bug causes. Return [bug reason 3]. |

### Step 2 - Main-Agent Bug Analysis
The main agent reads [reproduction report] if it exists, [history report], [bug reason 1], [bug reason 2], and [bug reason 3]. Combine insights, reject redundant or incorrect parts, read any necessary files, and draft precise [bug info].

### Step 3 - Main-Agent Final Bug Fix Plan
The main agent reads all scripts associated with [bug info] and [inputs]. Draft [final bug fix plan] that fixes the bug without breaking the codebase or repeating known_issues.md issues.

### Step 4 - Final Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + all relevant scripts + [final bug fix plan] + [bug info] + [inputs]. Identify overlooked root causes, side effects, integration risks, incorrect assumptions, and regressions. Return [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | External resource lookup | Read [key md files] + [final bug fix plan] + [bug info] + [inputs]. Identify extra needs for tools, packages, logs, error references, or reliable external documentation. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [valid criticisms] and [online resource] into [final bug fix plan]. Print [final bug fix plan].

**If user requested no code changes, STOP here. Otherwise continue.**

### Step 6 - Implementation
Create **Implementer** subagent (`agents/implementer.agent.md`). Pass [final bug fix plan] + [bug info] + [inputs] + [key md files].

**Implementer Model Verification (see _lib/workflow_contract.md):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon the subagent and perform the implementation directly itself, recording a [fallback result] with `status: fallback-single-agent` and `reason: implementer-model-mismatch`.

The subagent (or the main agent, if falling back) implements [final bug fix plan] and returns [implementation report] containing changes only, with no explanations.

### Step 7 - Main-Agent Code Review and Validation
The main agent reads [implementation report] and all changed files. Review fix correctness, code quality, side effects, and whether the target bug is actually fixed.

Create **QA Engineer** subagent (`agents/qa-engineer.agent.md`). Pass [inputs] + [bug info] + [final bug fix plan] + [implementation report] + changed files. The subagent validates the bug fix from a QA perspective and, if the user requested script runs, executes the relevant pipeline. Return [QA report].

If the main-agent code review or [QA report] finds issues, revise [final bug fix plan] and repeat from Step 6 until the fix is correct and complete.

### Step 8 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================BUG FIX===============================}
{Bug Name + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Fixed (yes/no, gaps if any)}
```
3. If recurring failed fix, write to known_issues.md:
```md
{Problem Title}
a. What was not fixed
b. Last attempt summary
c. Why last fix failed
d. Current fix
```
4. Summarize in bullet points to chat.
