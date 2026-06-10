---
name: 'Fast Debug Workflow (Claude Code)'
description: 'Fast debugging for Claude Code: optional reproduction, lean root-cause diagnosis, /simplify + /code-review native-skill review, and fix verification'
---
# Debug Instructions

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: target bug
- input 2: suspected reasons (optional)
- input 3: important scripts (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.
> **Fast-tier rules (apply to every step below):** See `workflow/claudecode_token_effective_workflow/_fast_rules.md` — no Broad Analyst, no QA/Principal/Senior subagents (main reviews), single-analyst default, default-on Devils Advocate, conditional Online Researcher.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 0 (Optional) - Reproduce the Bug
This step is skipped by default; only run it if `reproduce: true` is set in the debug request.

Create a **Bug Reproducer** subagent (`agents/bug-reproducer.agent.md`). Pass [inputs] + [repo context digest]. The subagent identifies target scripts and entry points, runs the relevant bug path in the correct order per scripts_overview.md, captures stdout, stderr, exit codes, error messages, and tracebacks, then returns [reproduction report]. The main agent stores [reproduction report] and passes it to later analysis. When this step runs, build [repo context digest] from [key md files] + [inputs] here; Step 1 reuses it.

### Step 1 - Diagnosis
The main agent reuses [repo context digest] from Step 0 if it exists; otherwise it builds the digest from [key md files] + [inputs]. If a narrow set of suspected scripts is named, the main agent may diagnose directly and skip the subagent.

Otherwise create **one Free Analyst** subagent (`agents/free-analyst.agent.md`). Pass [repo context digest] + [inputs] + [reproduction report] (if any). The analyst:
- Checks update_logs.md / known_issues.md for whether this bug was previously addressed and, if so, infers why the prior fix failed.
- Decides its own reading strategy across associated scripts and identifies the most likely root cause(s).

Return [bug reasons].

### Step 2 - Main-Agent Bug Analysis
The main agent reads [reproduction report] (if any) and [bug reasons], rejects redundant or incorrect parts, reads any necessary files, and drafts precise [bug info] (root cause, evidence, affected scripts).

### Step 3 - Main-Agent Final Bug Fix Plan
The main agent reads all scripts associated with [bug info] and [inputs] and drafts [final bug fix plan] that fixes the bug without breaking the codebase or repeating known_issues.md issues.

### Step 4 - Final Plan Challenge and Research
**Devils Advocate is default-on for debug** (_fast_rules §5 — a wrong root cause is expensive). Skip it only when none of §5's triggers hold AND the root cause was reproduced or directly evidenced with a fix of ≤ ~2 files. **Online Researcher is conditional** (_fast_rules §4): spawn for an unfamiliar error string, external dependency, or version question; skip for routine internal logic bugs.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | default-on; skip only per the rule above | Read [repo context digest] + relevant scripts + [final bug fix plan] + [bug info] + [inputs]. Identify overlooked root causes, side effects, integration risks, and regressions. Return [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | unfamiliar error / external dependency / version question (§4) | Read [repo context digest] + [final bug fix plan] + [bug info] + [inputs]. Search online for error references and known solutions. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [valid criticisms] and [online resource] (when produced) into [final bug fix plan]. Print [final bug fix plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - Implementation
Per _fast_rules §2: the main agent implements [final bug fix plan] directly for changes within the §2 thresholds; above them, create an **Implementer** subagent (`agents/implementer.agent.md`) and pass [final bug fix plan] + [inputs] + [repo context digest]. Record [implementation report] containing changes only, with no explanations.

### Step 7 - Code Review and Validation (mandatory — never skip)
Run the native review skills per _fast_rules §6, using the skill at `skills/claude-native-skills-subagents/SKILL.md` directly: `/simplify` first, then `/code-review` (review-only, medium effort) on the resulting diff; if the native `/code-review` skill is unavailable, follow the §6 fallback chain. Apply clearly-correct, low-risk findings in one editing pass; record which review tier ran.

Then the main agent validates the fix against [final bug fix plan] and the §6 validation checklist, and — when a reproduction path exists (Step 0) or the user requested runs — re-runs the failing path to confirm the bug no longer occurs. If validation fails, perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 8.

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
4. Summarize in bullet points to chat, including any deferred [code-review report] findings and unresolved gaps.
