---
name: 'Fast Debug Workflow (Claude Code)'
description: 'Fast debugging for Claude Code: optional reproduction, main-agent diagnosis and fix plan, parallel challenge + research subagents, direct fix, and /simplify + /code-review review'
---
# Debug Instructions

[inputs]:
- input 1: target bug
- input 2: suspected reasons (optional)
- input 3: important scripts (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents read repo_info/codebase_overview.md and repo_info/scripts_overview.md directly.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

## CREATE ONE TODO PER STEP

### Step 0 (Optional) - Reproduce the Bug
Skipped by default; run only if `reproduce: true` is set in the debug request.

The main agent identifies the target scripts and entry points, runs the relevant bug path in the correct order per scripts_overview.md, and captures stdout, stderr, exit codes, error messages, and tracebacks into [reproduction report].

### Step 1 - Context Gathering
Read [key md files]. If suspected scripts are specified in [inputs], read them. Condense into a [repo context digest].

### Step 2 - Diagnosis and Fix Plan
Based on [repo context digest] + [inputs] + [reproduction report] (if any), the main agent:
1. Checks update_logs.md and known_issues.md for whether this bug was previously addressed and, if so, why the prior fix failed.
2. Reads the associated scripts and identifies the most likely root cause(s) with evidence and affected scripts, recorded as [bug info].
3. Proposes a [plan] that fixes the bug without breaking the codebase or repeating known_issues.md issues.

### Step 3 - Plan Challenge and Research
**Spawn 2 subagents in parallel.** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [repo context digest] + [bug info] + [plan] + [inputs]. Read additional files if needed. Assume the diagnosis and [plan] are wrong and flawed; identify overlooked root causes, side effects, integration risks, and regressions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [repo context digest] + [bug info] + [plan] + [inputs]. Search online for error references, known solutions, and reliable resources. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
The main agent implements [final plan] directly and records [implementation report] containing changes only, with no explanations.

### Step 6 - Code Review and Validation
1. The main agent reviews the changes directly (correctness, integration, unintended edits).
2. Run the native review skills using the skill at `skills/claude-native-skills-subagents/SKILL.md`: `/simplify` first, then `/code-review` (review-only, medium effort) on the resulting diff. If the native `/code-review` skill is unavailable, review the code directly instead.
3. The main agent validates the final diff against [final plan] and [implementation report]. Checklist: root cause addressed and bug fixed, no regressions, existing tests/behavior intact. When a reproduction path exists (Step 0) or the user requested runs, re-run the failing path to confirm the bug no longer occurs.

If validation fails, perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================BUG FIX===============================}
{Bug Name + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
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
4. Summarize changes in bullet points to chat.
