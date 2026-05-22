---
name: 'Fast Debug Workflow'
description: 'Streamlined instructions for debugging with maximum parallelization'
---
# Debug Instructions

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
-->

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target bug
- input 2: suspected reasons (optional)
- input 3: important scripts (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in #file:../../_lib/workflow_contract.md.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using VS Code Copilot's native `agent` tool. Coordinator agents declare `tools: ['agent']` and `agents: [...]` to orchestrate subagent invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/harness_coding_instructions/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 0 (Optional) — Reproduce the Bug
*(This step is **skipped by default**; only run it if `reproduce: true` is set in the debug request.)*

Create a **Bug Reproducer** subagent (`agents/bug-reproducer.agent.md`). The subagent must: (1) read [key md files] and [inputs] to identify the target scripts and entry points associated with the bug; (2) run those scripts in the correct order per `scripts_overview.md` to exercise the bug path; (3) capture all output (stdout, stderr, exit codes, error messages, tracebacks); (4) summarize whether the bug was reproduced, what output was observed, and any relevant runtime state; (5) return the summary as **[reproduction report]**. The main agent stores [reproduction report] and passes it to all subsequent analysis subagents.

### Step 1 — Parallel Diagnosis
**[PARALLEL EXECUTION — launch ALL FIVE subagents in parallel via VS Code Copilot `agent` tool; if parallel subagents are not supported, run them sequentially instead (results are equivalent)]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Code A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | History check | Read [key md files]. Check if bug was previously addressed. If yes, follow codebase diagram through associated scripts, infer why prior fix failed. Return [history report]. |
| Code B | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + important scripts. Check potential bug causes from suspected reasons and specified scripts. Return [bug reason 1]. |
| Code C | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files]. Follow pipeline upstream->downstream, read all scripts. Check potential bug causes from broader perspective. Return [bug reason 2]. |
| Code D | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files]. Decide own reading strategy. Check potential bug causes from unconstrained perspective. Return [bug reason 3]. |
| Debug E | — | `/debug` skill | Run only if the main agent is Claude Code or another Claude agent with Claude Code skills available. Pass bug description + suspected reasons. Use `/debug` to enable debug logging and read logs to identify exactly what went wrong. Provide concrete log-level evidence. Return [debug log analysis]. |

### Step 2 — Synthesize Bug Analysis
Main agent reads [reproduction report] if it exists, [history report], [bug reason 1], [bug reason 2], [bug reason 3], and [debug log analysis] if it exists. Combine insights, reject redundant/incorrect parts. Incorporate concrete evidence from [debug log analysis] when present. Draft precise [bug info].

### Step 2.5 — Challenge and Research (Parallel)
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool; if parallel subagents are not supported, run them sequentially instead (results are equivalent)]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files], then critically challenge [bug info] — looking for overlooked root causes, misattributed blame, or incorrect assumptions. Return [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | External resource lookup | Read [key md files] and [bug info], then identify extra needs for skills, tools, packages, logs, error messages, or external references. Search online for reliable resources and solutions. Return [online resource]. |

### Step 2.75 — Incorporate Feedback
Main agent incorporates [valid criticisms] and [online resource], and updates [bug info] accordingly.

### Step 3 — Plan then Review (sequential)

**Step 3a — Plan:**
Create **Focus Analyst** subagent (`agents/focus-analyst.agent.md`) in plan mode. Read [key md files] + all scripts associated with bug. Draft [bug fix plan] that fixes bug without breaking codebase or repeating known_issues.md issues. Return [bug fix plan] to main agent.

**Step 3b — Review:**
Create **Senior Engineer** subagent (`agents/senior-engineer.agent.md`). Read [key md files] + all repo scripts. Build comprehensive codebase understanding. Assess [bug fix plan] for correctness/feasibility/side effects. Return [plan review].

Main agent combines [bug info], [bug fix plan], [plan review]. Draft [final bug fix plan]. Finalize.

### Step 3c — Challenge Final Plan (Parallel)
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool; if parallel subagents are not supported, run them sequentially instead (results are equivalent)]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] and all relevant scripts, then critically challenge [final bug fix plan] — looking for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions. Return [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | External resource lookup | Read [key md files] and [final bug fix plan], then identify extra needs for skills, tools, and packages. Search online for reliable resources and solutions. Return [online resource]. |

### Step 3d — Incorporate Final Feedback
Main agent incorporates [valid criticisms] and [online resource], and updates [final bug fix plan] accordingly.

Print [final bug fix plan]. **If user requested no code changes → STOP here.**

### Step 4 — Implementation
Create **Implementer** subagent (`agents/implementer.agent.md`). **Implementer Model Verification (see `_lib/workflow_contract.md`):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon the subagent and perform the implementation directly itself, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`. Pass [final bug fix plan] + [bug info] + [key md files]. The subagent (or the main agent, if falling back) implements [final bug fix plan]. Returns [implementation report] (changes only, no explanations).

### Step 4.5 — Claude Native Skills
If and only if the main agent is Claude Code or another Claude agent with Claude Code skills available, search .github/harness_coding_instructions/skills/index.md for `claude-native-skills-subagents`, then use the skill at .github/harness_coding_instructions/skills/claude-native-skills-subagents/SKILL.md after step 4. If the main agent is not a Claude agent, skip step 4.5 and continue to step 5.

### Step 5 — Parallel Validation
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool; if parallel subagents are not supported, run them sequentially instead (results are equivalent)]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Review A | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Senior staff engineer | Read [key md files] + code changes. Review bug fix correctness. Challenge the implementation and ensure fix works without breaking codebase. Return [code review report]. |
| Review B | **QA Engineer** (`agents/qa-engineer.agent.md`) | QA engineer | Read [key md files] + code changes. Validate the bug fix from a QA engineer perspective. If user requested script runs, execute pipeline upstream->downstream. If script fails: log error, continue to next. Return [QA report]. |

### Step 6 — Documentation & Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```
{=============================BUG FIX===============================}
{Bug Name + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Fixed (yes/no, gaps if any)}
```
3. If recurring failed fix, write to known_issues.md:
```
{Problem Title}
a. What was not fixed
b. Last attempt summary
c. Why last fix failed
d. Current fix
```
4. Summarize in bullet points to chat.
