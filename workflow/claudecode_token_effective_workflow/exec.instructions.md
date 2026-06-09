---
name: 'Fast Cmd/Skill Execution (Claude Code)'
description: 'Fast command/skill execution for Claude Code: lean planning with destructive-action safety challenge, approval gate, and captured output'
---
# Execute Cmds/Skills in a Repo

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - workflow/claudecode_token_effective_workflow/_fast_rules.md
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
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.
> **Fast-tier rules (apply to every step below):** See `workflow/claudecode_token_effective_workflow/_fast_rules.md` — no Broad Analyst, no QA subagent (main validates), main-plans-directly default, Devils Advocate default-on for destructive commands, conditional Online Researcher.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If important files are specified in [inputs], read them. Combine with [key md files] into [repo context digest].

### Step 2 - Execution Planning
exec usually runs known commands, so by default the **main agent plans directly** (proceed to Step 3). Launch **one Free Analyst** (`agents/free-analyst.agent.md`) only when the command set, preconditions, or dependencies are unclear: pass [repo context digest] + [inputs]; it identifies associated scripts/files and drafts [plan] covering preconditions, commands to run, expected outputs, and failure modes.

### Step 3 - Main-Agent Final Execution Plan
The main agent reviews [plan] (if any), reads any necessary files, and drafts [final plan] covering exact commands to run, preconditions, expected outputs, validation criteria, and rollback strategy. The plan must be feasible, safe, and correct.

### Step 4 - Final Plan Challenge and Research
Spawn **Devils Advocate by default when [final plan] includes any destructive or irreversible command** (write/delete/install/network/migration — _fast_rules §5 default-on). Spawn **Online Researcher only** for unknown command syntax/flags or version compatibility (_fast_rules §4).

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | plan contains a destructive/irreversible/state-changing command | Read relevant scripts + [final plan] + [inputs]. Identify wrong flags, destructive side effects, missing prerequisites, and environment assumptions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | unfamiliar command syntax, flags, or version-compat questions | Read [final plan] + [inputs]. Search online for reliable command references and known issues. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into [final plan]. Print [final plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - Execution
Create **Executor** subagent (`agents/executor.agent.md`). Pass [final plan] + [inputs] + [repo context digest].

**Executor Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback (skip retry loop in Claude Code — model is inherited automatically).

The Executor validates preconditions, executes commands or skills per [final plan], captures stdout, stderr, exit codes, and pass/fail state, then returns [execution report] with no explanations.

### Step 7 - Main-Agent Review and Validation
The main agent reads [execution report], validates outputs against [final plan], checks side effects and state changes, and inspects modified files when applicable.

If the review finds issues, revise [final plan] and repeat from Step 6 when another execution attempt is safe.

### Step 7.5 - Claude Code Native Skills (only if source was edited)
If the execution modified source files, search `skills/index.md` for `claude-native-skills-subagents` and use the skill at `skills/claude-native-skills-subagents/SKILL.md` (it runs `/simplify` automatically — do not invoke it separately). If the execution only ran commands without editing source, skip this step.

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
