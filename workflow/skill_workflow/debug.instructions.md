---
name: 'Skill-Based Debug'
description: 'Unified skill-backed (skill mode) debug workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast workflow, but the reproduction, diagnosis, challenge, research, and fix instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback.'
---
# Debug Instructions

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - _lib/local_skill_discovery.md
  - skills/skill_workflow_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

> **Skill-backed variant (skill mode).** Selected step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue — never block on a missing external skill.

[inputs]:
- input 1: target bug
- input 2: suspected reasons (optional)
- input 3: important scripts (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 0 (Optional) - Reproduce the Bug
Skipped by default; run only if `reproduce: true` is set in the debug request.

**Skill (replaces this step's instructions):** Establish reproduction by following the **reproduction phase** of **`systematic-debugging`** (`obra/superpowers:skills/systematic-debugging/SKILL.md`, 229,665★ verified 2026-06-16) — find the cheapest reliable way to trigger the bug before any fix. Capture stdout, stderr, exit codes, error messages, and tracebacks into [reproduction report].
**Fallback if the skill is unavailable:** the main agent identifies the target scripts and entry points, runs the relevant bug path in the correct order per scripts_overview.md, and captures stdout, stderr, exit codes, error messages, and tracebacks into [reproduction report].

### Step 1 - Context Gathering
Read [key md files]. If suspected scripts are specified in [inputs], read them. Condense them into a **[repo context digest]** — a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues — for use in later steps and for handoff to subagents per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents.

### Step 2 - Diagnosis and Fix Plan
**Skill (replaces this step's diagnosis instructions):** Diagnose the root cause by following **`systematic-debugging`** (`obra/superpowers:skills/systematic-debugging/SKILL.md`, 229,665★) — which forces reproduce → isolate → evidence-backed root cause **before** proposing fixes. Then, based on [repo context digest] + [inputs] + [reproduction report] (if any), the main agent:
1. Checks update_logs.md and known_issues.md for whether this bug was previously addressed and, if so, why the prior fix failed.
2. Records the most likely root cause(s) with evidence and affected scripts as [bug info] (the output of `systematic-debugging`'s root-cause phase).
3. Proposes a [plan] that fixes the bug without breaking the codebase or repeating known_issues.md issues.
**Fallback if the skill is unavailable:** perform Local Skill Discovery per `_lib/local_skill_discovery.md` (record [local skills]); then read the associated scripts, identify the most likely root cause(s) with evidence ([bug info]), and propose the fix [plan] as in the fast workflow.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | **Skill-backed:** run the challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`, 9,938★ verified 2026-06-16) — a structured devil's-advocate / pre-mortem over [repo context digest] + [bug info] + [plan] + [inputs], reading additional scripts if needed. Assume every step in the diagnosis and [plan] is wrong, flawed, and over-engineered; identify overlooked root causes, side effects, integration risks, over-engineering and regressions; report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate task as written in the fast workflow. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | **Skill-backed:** draft [online resource] by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`, 28,103★ verified 2026-06-16) — plan/search/read/synthesize a **cited report** of error references, known solutions, and reliable resources for [bug info] + [plan] + [inputs]. The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof (see `agents/online-researcher.agent.md`). **Fallback if `deep-research` is unavailable:** perform the Online Researcher task as written in the fast workflow. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
**Skill (replaces this step's instructions):** Implement the fix in [final plan] by following **`executing-plans`** (`obra/superpowers:skills/executing-plans/SKILL.md`, 229,665★) — reinforced by **`test-driven-development`** (`obra/superpowers:skills/test-driven-development/SKILL.md`): write a failing test that reproduces the bug, make it pass, then refactor. Record [implementation report] containing changes only, with no explanations.
**Fallback if the skills are unavailable:** the main agent implements [final plan] directly and records [implementation report] (changes only, no explanations).

### Step 6 - Code Review and Validation
1. **Native review skills (platform-conditional):**
   - **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** run the native review skills using the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — `/simplify` first on the resulting diff, record results as [simplify]; then `/code-review` on the resulting diff, record as [code-review]. If the native skills are unavailable, skip them.
   - **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the native skills.
2. **Skill-backed self-challenge:** run **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) over the [implementation report] — claim every item is wrong, explain why, then draft a [post-impl challenge report]. **Fallback if unavailable:** the main agent performs this self-challenge inline.
3. The main agent reviews the changes directly, save the conclusion as [direct review]. When a reproduction path exists (Step 0) or the user requested runs, re-run the failing path to confirm the bug no longer occurs.

Based on whichever of [simplify] + [code-review] + [post-impl challenge report] + [direct review] were produced, perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 7.

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
