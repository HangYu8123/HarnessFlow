---
name: 'Fast Code Implementation (Claude Code)'
description: 'Fast new-feature implementation for Claude Code: lean exploration, conditional review/research, approval gate, and /simplify cleanup'
---
# Add New Functions to an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: [target functionalities]
- input 2: [important files] (optional)
- input 3: [target repo] (optional, default to current repo)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.
> **Fast-tier rules (apply to every step below):** See `workflow/claudecode_token_effective_workflow/_fast_rules.md` — no Broad Analyst, no QA/Principal/Senior subagents (main reviews), single-analyst default, conditional Devils Advocate / Online Researcher.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If important files are specified in [inputs], read them. Combine that understanding with [key md files] into a condensed [repo context digest] to pass inline to any subagent.

### Step 2 - Planning
Per _fast_rules §1: if [inputs] is narrowly scoped (≤ ~3 named files / a single function), the main agent reads those files and drafts the plan directly — skip to Step 3. Otherwise launch **at most two** analysts.

**[PARALLEL EXECUTION - launch both subagents in parallel via Claude Code Agent tool; if parallel not supported, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [repo context digest] + [inputs]. Identify highly associated scripts/files, read them, and draft [plan 1] + [diagram 1] for integrating the new functionalities while keeping the codebase stable. |
| Plan B | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [repo context digest] + [inputs]. Decide the reading strategy and draft [plan 2] with the integration approach. |

### Step 3 - Main-Agent Final Plan
The main agent reviews the plan(s) from Step 2 (or its own direct analysis), reads any necessary files, rejects incorrect or redundant parts, and drafts [final plan] that is feasible, stable, and correct against existing tests and behavior.

### Step 4 - Final Plan Challenge and Research
Always spawn both agents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [repo context digest] + relevant scripts + [final plan] + [inputs]. Identify overlooked side effects, integration risks, incorrect assumptions, and regressions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [repo context digest] + [final plan] + [inputs]. Search online for reliable resources and better solutions. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into [final plan]. Print the updated [final plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - Implementation
The main agent implements [final plan] directly and records [implementation report] containing changes only, with no explanations.

### Step 7 - Code Review and Validation
Skipped — covered by Step 7.5 native skill review.

### Step 7.5 - Claude Code Native Skills
Since this is a Claude Code environment, search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at `skills/claude-native-skills-subagents/SKILL.md`. (That skill runs `/simplify` automatically — do not invoke it separately.)

### Step 8 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Function Update===============================}
{Functionality Name + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
