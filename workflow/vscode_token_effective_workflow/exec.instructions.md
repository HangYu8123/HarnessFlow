---
name: 'Fast Cmd/Skill Execution'
description: 'Streamlined instructions for executing commands and skills with maximum parallelization'
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
If important files are specified in [inputs], read them. Combine with [key md files].

### Step 2 - Parallel Execution Planning
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + [inputs]. Identify associated scripts/files, read them, and draft [plan 1] + [diagram 1] covering preconditions, commands to run, expected outputs, and failure modes. |
| Plan B | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [inputs]. Decide the reading strategy and draft [plan 2] with execution approach and validation criteria. |

### Step 3 - Main-Agent Final Execution Plan
The main agent reviews [plan 1], [plan 2], and [diagram 1], then reads any necessary files. Reject incorrect or redundant parts. Draft [final plan] covering exact commands to run, preconditions, expected outputs, validation criteria, and rollback strategy. The plan must be feasible, safe, and 100% correct.

### Step 4 - Final Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + all relevant scripts + [final plan] + [inputs]. Identify wrong flags, destructive side effects, missing prerequisites, and environment assumptions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + [final plan] + [inputs]. Identify needs for tools, command syntax, known issues, version compatibility, or reliable references. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] into [final plan]. Print [final plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - Execution
Create **Executor** subagent (`agents/executor.agent.md`). Pass [final plan] + [inputs] + [key md files].

**Executor Model Verification (see #file:../../_lib/workflow_contract.md):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon that subagent and perform the execution directly itself, recording a [fallback result] with `status: fallback-single-agent` and `reason: executor-model-mismatch`.

The Executor validates preconditions, executes commands or skills per [final plan], captures stdout, stderr, exit codes, and pass/fail state, then returns [execution report] with no explanations.

### Step 7 - Main-Agent Review and QA
The main agent reads [execution report], validates outputs against [final plan], checks side effects, and inspects modified files when applicable.

Create **QA Engineer** subagent (`agents/qa-engineer.agent.md`) if additional validation is needed. Pass [inputs] + [final plan] + [execution report] + changed files if any. The subagent checks side effects, state changes, file modifications, and validation scripts requested by the user. Return [execution QA report].

If the main-agent review or [execution QA report] finds issues, revise [final plan] and repeat from Step 6 when another execution attempt is safe.

### Step 8 - Documentation and Summary
1. If execution changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Execution Update===============================}
{Cmd/Skill Name + Execution ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Commands/Skills executed (what was run and parameters)}
{Result (success/failure, key outputs, side effects)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize execution results in bullet points to chat.
