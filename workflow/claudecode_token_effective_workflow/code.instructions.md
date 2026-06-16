---
name: 'Fast Code Implementation (Claude Code)'
description: 'Fast new-feature implementation for Claude Code: main-agent plan, parallel challenge + research subagents, direct implementation, and /simplify + /code-review review'
---
# Add New Functions to an Existing Repo

**Safety: follow `_lib/safety_rules.md` (no commit without approval, no spam files, no sudo).**

[inputs]:
- input 1: [target functionalities]
- input 2: [important files] (optional)
- input 3: [target repo] (optional, default to current repo)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents read repo_info/codebase_overview.md and repo_info/scripts_overview.md directly.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Condense into a [repo context digest].

### Step 2 - Implementation Planning
**Local skill discovery (before drafting [plan]):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` — scan `skills/index.md` for any local skill whose trigger fits this task; on a confirmed match, read its `SKILL.md` and integrate it into [plan]. Record the result as [local skills] (or "none relevant").

Based on [repo context digest] + [inputs], read the relevant files and propose a [plan] for integrating the target functionalities (files to add/change, integration points, dependencies) + notes on keeping existing behavior and tests stable.

### Step 3 - Plan Challenge and Research
**Spawn 2 subagents in parallel.** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [repo context digest] + [plan] + [inputs]. Read additional files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify overlooked side effects, integration risks, incorrect assumptions, over-engineering and regressions. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [repo context digest] + [plan] + [inputs]. Search online for reliable references, established solutions, and available resources. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
The main agent implements [final plan] directly and records [implementation report] containing changes only, with no explanations.

### Step 6 - Code Review and Validation
1. Run the native review skills using the skill at `skills/claude-native-skills-subagents/SKILL.md`: `/simplify` first on the resulting diff, record results as [simplify]. Then `/code-review` on the resulting diff, record as [code-review]. If the native skills are unavailable, skip this step. 
2. The main agent should claim everything item in the [implementation report] is wrong, and start explaining why it is wrong. After done explaining all the items, the main agent should then draft a [post-impl challenge report]
3. The main agent reviews the changes directly, save the conclusion as [direct review].

Based on [simplify] + [code-review] + [post-impl challenge report] + [direct review], perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Function Update===============================}
{Functionality Name + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
