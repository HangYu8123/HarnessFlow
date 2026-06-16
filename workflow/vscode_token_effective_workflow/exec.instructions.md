---
name: 'Fast Cmd/Skill Execution'
description: 'Streamlined command/skill execution: main-agent plan, one parallel challenge + research subagent step, and direct execution with captured-output validation'
---
# Execute Cmds/Skills in a Repo

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
-->

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: target cmds/skills to execute
- input 2: important files (optional)
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
Read [key md files]. If important files are specified in [inputs], read them. Condense the understanding for use in later steps.

### Step 2 - Execution Planning
**Local skill discovery (before drafting [plan]):** When the target involves a named skill, or the task could be accomplished or aided by a local skill, perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`), recorded as [local skills]. Skip when the target is plainly shell commands with no relevant skill ([local skills]: none relevant).

Based on [key md files] + [inputs] + [local skills], the main agent reads the relevant files and proposes a [plan] covering exact commands/skills to run, preconditions, expected outputs, validation criteria, failure modes, and rollback strategy.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [key md files] + [plan] + [inputs], and all relevant scripts if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify wrong flags, destructive or irreversible side effects, missing prerequisites, environment assumptions, over-engineering and regressions. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [key md files] + [plan] + [inputs]. Search online for reliable command/skill references, known issues, and version compatibility. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no changes or a plan-only review.

### Step 5 - Execution
The main agent validates preconditions, executes the commands or skills per [final plan] directly, and captures stdout, stderr, exit codes, and pass/fail state into [execution report] with no explanations.

### Step 6 - Review and Validation
1. The main agent should claim every item in the [execution report] is wrong, and start explaining why it is wrong. After explaining all the items, the main agent should then draft a [post-impl challenge report].
2. The main agent validates [execution report] against [final plan]: outputs match expectations, side effects and state changes are intended, and modified files are inspected when applicable. If the execution edited source files, the main agent reviews the edits directly for correctness and unintended changes. Save the conclusion as [direct review].
3. Based on [post-impl challenge report] + [direct review], if any validation fails, perform **one** remediation pass (revise [final plan] and re-execute once, only when another attempt is safe); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. If execution changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Execution Update===============================}
{Cmd/Skill Name + Execution ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
{Commands/Skills executed (what was run and parameters)}
{Result (success/failure, key outputs, side effects)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize execution results in bullet points to chat.
