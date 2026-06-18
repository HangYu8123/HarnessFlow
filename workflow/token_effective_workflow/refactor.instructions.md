---
name: 'Fast Refactor'
description: 'Unified token-effective (fast) refactor workflow for Claude Code, Codex, and VS Code Copilot: main-agent plan, one parallel challenge + research subagent step, opt-in approval gate, direct implementation, platform-conditional native-skills review with self-challenge, and behavior-preservation validation'
---
# Refactor an Existing Repo

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
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
-->

[inputs]:
- input 1: target refactor functionalities/repository/scripts
- input 2: target files (optional)
- input 3: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under repo_info/).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If target files are specified in [inputs], read them. Condense [key md files] (plus any target files read) into a [repo context digest] per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: pass [inputs], [key md files], and [repo context digest].

### Step 2 - Refactor Analysis

Based on the repo context ([key md files] and [target files]) + [inputs], the main agent reads the relevant files. Then the main agent proposes a [plan] for addressing the target refactors + a [comparison] report (before/after) indicating the changes + behavior-preservation notes.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Receive the repo context (per §Context Passing) + [plan] + [comparison] + [inputs], and read additional files/scripts if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify overlooked side effects, integration risks, incorrect assumptions, over-engineering, and regressions. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Receive the repo context (per §Context Passing) + [plan] + [comparison] + [inputs]. Search online for reliable references, established solutions, and available resources. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
The main agent implements [final plan] and records an [implementation report] containing changes only, with no explanations.

### Step 6 - Code Review and Validation
1. The main agent first reviews the changes, save the conclusion as [direct review].
2. **Native review skills (platform-conditional):**
   - **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** run the native review skills via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — `/simplify` first on the resulting diff, record as [simplify]; then `/code-review` on the resulting diff, record as [code-review]. If the native skills are unavailable, skip this sub-step.
   - **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the native skills.
3. The main agent should claim every item in the [implementation report] is wrong, and start explaining why it is wrong. After explaining all the items, the main agent should then draft a [post-impl challenge report].


Based on whichever of [simplify] + [code-review] + [post-impl challenge report] + [direct review] were produced, perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Refactor Update===============================}
{Refactor Summary + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
