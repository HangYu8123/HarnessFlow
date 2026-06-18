---
name: 'Fast Code Implementation'
description: 'Unified token-effective (fast) code-implementation workflow for Claude Code, Codex, and VS Code Copilot: main-agent plan, one parallel challenge + research subagent step, direct implementation, and a platform-conditional review.'
---
# Add New Functions to an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
-->

[inputs]:
- input 1: [target functionalities]
- input 2: [important files] (optional)
- input 3: [target repo] (optional, default to current repo)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved via Pack Path Resolution).

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Condense them (plus any target files) into a **[repo context digest]** for use in later steps, and hand off repo context to subagents per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent passes [repo context digest] inline; on **Codex** and **VS Code Copilot** subagents read [key md files] directly.

### Step 2 - Implementation Planning
Based on the repo context (per §Context Passing) + [inputs], the main agent reads the relevant files and proposes a [plan] for integrating the target functionalities (files to add/change, integration points, dependencies) + notes on keeping existing behavior and tests stable.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read the repo context (per §Context Passing) + [plan] + [inputs], and additional files/scripts if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify overlooked side effects, integration risks, incorrect assumptions, over-engineering and regressions. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read the repo context (per §Context Passing) + [plan] + [inputs]. Search online for reliable references, established solutions, and available resources. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
The main agent implements [final plan] directly and records [implementation report] containing changes only, with no explanations.

### Step 6 - Code Review and Validation
1. **Native review skills (platform-conditional):**
   - **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** run the native review skills via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — run `/simplify` first on the resulting diff, record results as [simplify]; then run `/code-review` on the resulting diff, record as [code-review]. If the native skills are unavailable, skip this sub-step.
   - **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the native skills.
2. The main agent should claim every item in the [implementation report] is wrong, and start explaining why it is wrong. After explaining all the items, the main agent should then draft a [post-impl challenge report].
3. The main agent reviews the changes directly, save the conclusion as [direct review].

Based on whichever of [simplify] + [code-review] + [post-impl challenge report] + [direct review] were produced, perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 7.

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
