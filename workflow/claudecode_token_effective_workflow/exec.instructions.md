---
name: 'Fast Cmd/Skill Execution (Claude Code)'
description: 'Fast command/skill execution for Claude Code: main-agent plan, parallel safety challenge + research subagents, and direct execution with captured-output validation'
---
# Execute Cmds/Skills in a Repo

[inputs]:
- input 1: target cmds/skills to execute
- input 2: important files (optional)
- input 3: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents read repo_info/codebase_overview.md and repo_info/scripts_overview.md directly.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Condense into a [repo context digest].

### Step 2 - Execution Planning
Based on [repo context digest] + [inputs], read the relevant files (and `skills/index.md` when a skill is named) and propose a [plan] covering exact commands/skills to run, preconditions, expected outputs, validation criteria, failure modes, and rollback strategy.

### Step 3 - Plan Challenge and Research
**Spawn 2 subagents in parallel.** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [repo context digest] + [plan] + [inputs]. Read additional files if needed. Assume the [plan] is wrong and flawed; identify wrong flags, destructive or irreversible side effects, missing prerequisites, and environment assumptions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [repo context digest] + [plan] + [inputs]. Search online for reliable command/skill references, known issues, and version compatibility. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no changes or a plan-only review.

### Step 5 - Execution
The main agent validates preconditions, executes the commands or skills per [final plan] directly, and captures stdout, stderr, exit codes, and pass/fail state into [execution report] with no explanations.

### Step 6 - Review and Validation
1. The main agent validates [execution report] against [final plan]: outputs match expectations, side effects and state changes are intended, and modified files are inspected when applicable.
2. If the execution edited source files, run the native review skills using the skill at `skills/claude-native-skills-subagents/SKILL.md`: `/simplify` first, then `/code-review` (review-only, medium effort) on the resulting diff; if the native `/code-review` skill is unavailable, review the edits directly. Skip this item when the execution only ran commands without editing source.
3. If validation fails, perform **one** remediation pass (revise [final plan] and re-execute once, only when another attempt is safe); record any remaining gaps for Step 7.

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
