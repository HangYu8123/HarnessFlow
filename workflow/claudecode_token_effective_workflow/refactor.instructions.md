---
name: 'Fast Code Refactor (Claude Code)'
description: 'Fast refactor for Claude Code: one specialist-lens analysis, main-agent behavior-preservation review, approval gate, and /simplify'
---
# Refactor an Existing Repo

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
-->

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: target refactor functionalities/repository/scripts
- input 2: target files (optional)
- input 3: target repo (optional)

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
If target files are specified in [inputs], read them. Combine that understanding with [key md files] into a condensed [repo context digest].

### Step 2 - Refactor Analysis
Launch **one** specialist analyst matched to the refactor intent in [inputs] (default to Complexity Analyst when unspecified):

| Intent | Agent |
|--------|-------|
| simplify / reduce complexity (default) | **Complexity Analyst** (`agents/complexity-analyst.agent.md`) |
| remove duplication / overlap | **Redundancy Analyst** (`agents/redundancy-analyst.agent.md`) |
| restructure design / architecture | **Architecture Analyst** (`agents/architecture-analyst.agent.md`) |
| harden robustness / fix fragility | **Robustness Analyst** (`agents/robustness-analyst.agent.md`) |

Pass [repo context digest] + [inputs]. The analyst reads relevant files and returns [plan] + [comparison] (before/after) plus behavior-preservation notes. For narrowly-scoped [inputs] (≤ ~3 files), the main agent may skip the subagent and analyze directly.

### Step 3 - Main-Agent Final Plan
The main agent reads the necessary target files and performs the code-quality review directly (maintainability, robustness, readability, behavioral risks). It combines [plan] + [comparison] with its own review, rejects incorrect or redundant parts, and drafts [final plan], verifying each step against target files, known_issues.md conflicts, upstream/downstream dependencies, and behavior preservation.

### Step 4 - Final Plan Challenge and Research
Spawn **Devils Advocate by default** (refactors silently break behavior — _fast_rules §5 default-on). Spawn **Online Researcher only** if the refactor needs migration guides / library references (_fast_rules §4).

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | default-on; skip only for a trivial single-file rename | Read [repo context digest] + relevant scripts + [final plan] + [inputs]. Identify overlooked side effects, integration risks, incorrect assumptions, and regressions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | refactor depends on a migration/library/pattern reference | Read [repo context digest] + [final plan] + [inputs]. Search online for reliable migration references and solutions. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into [final plan]. Print [final plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - Implementation
Create **Implementer** subagent (`agents/implementer.agent.md`). Pass [final plan] + [inputs] + [repo context digest].

**Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback (skip retry loop in Claude Code — model is inherited automatically).

The subagent (or the main agent, if falling back) implements [final plan] and returns [implementation report] containing changes only, with no explanations.

### Step 7 - Main-Agent Code Review and Validation
The main agent reads [implementation report] and all changed files, then reviews refactor correctness, behavior preservation, integration quality, maintainability, and whether [inputs] and [final plan] are fully satisfied. If runnable tests exist or the user requested runs, the main agent runs them directly to confirm behavior is unchanged.

If the review or run finds issues, revise [final plan] and repeat from Step 6 until the refactor is correct and complete.

### Step 7.5 - Claude Code Native Skills
Since this is a Claude Code environment, search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at `skills/claude-native-skills-subagents/SKILL.md`. (That skill runs `/simplify` automatically — do not invoke it separately.)

### Step 8 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Refactor Update===============================}
{Refactor Summary + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
