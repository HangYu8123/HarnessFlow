---
name: 'Fast Refactor'
description: 'Unified token-effective (fast) refactor workflow for Claude Code, Codex, and VS Code Copilot: main-agent plan, one parallel challenge + research subagent step, opt-in approval gate, direct implementation, platform-conditional native-skills review with self-challenge, and behavior-preservation validation'
---
# Refactor an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
-->

[inputs]:
- input 1: target refactor functionalities/repository/scripts
- input 2: target files (optional)
- input 3: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under repo_info/). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If target files are specified in [inputs], read them. Condense [key md files] (plus any target files read) into a [repo context digest] per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: pass [inputs], [key md files], and [repo context digest].

### Step 2 - Refactor Analysis

Based on the repo context ([key md files] and [target files]) + [inputs], the main agent reads the relevant files. Then the main agent proposes a [plan] for addressing the target refactors + a [comparison] report (before/after) indicating the changes + behavior-preservation notes.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]**

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
1. **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `false` skips, `true` runs Claude Code's native `/simplify` / `/code-review medium`, `local` runs the pack's vendored `code-simplification` / `code-review-and-quality` skills (portable to every platform). Spawn one subagent per enabled skill, **sequentially, simplify first**, following the Subagent Launch Contract in [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) (subagents use the `subagent_model` header; keep an activity log and record fallbacks). Pass each the changed files (the current diff) + [final plan] + [implementation report] plus the relevant repo context. Record [simplify] and/or [code-review] for whichever ran; leave a skipped skill's label unproduced.
2. The main agent reviews the changes directly, validates the implementation with [final plan] + [implementation report], and reports the conclusion as [direct review].
Based on whichever of [simplify] + [code-review] + [direct review] were produced, the main agent analyzes and validates them all, and generates a [final report]. Then the main agent applies the clearly-correct, low-risk findings (do not auto-apply uncertain or behavior-changing ones), then records any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes and [final report].
2. Write to update_logs.md:
```md
{=============================Refactor Update===============================}
{Refactor Summary + Timestamp (current time, YYYY-MM-DD HH:MM) + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat, and a yes/no answer indicating whether the refactor completed with no issues. If there are gaps, describe them.
