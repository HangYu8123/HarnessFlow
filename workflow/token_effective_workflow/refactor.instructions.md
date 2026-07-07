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
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]**

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
1. **Native review skills (platform-conditional):**
   - **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** run the native review as **two subagents, one skill each — no orchestration wrapper**, following the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) (subagents inherit [main agent model] / the `subagent_model` header; keep an activity log and record fallbacks). Run them **sequentially, not in parallel**, and invoke each skill exactly once: **(1)** **`/simplify` is opt-in — run step (1) only when the request's `simplify` header is `true`; when it is `false`, absent, or unset (the default), skip step (1) entirely and leave [simplify] unproduced.** spawn a **simplify subagent** — pass it the changed files (the current diff) + [final plan] + [implementation report] plus the relevant repo context and have it run `/simplify` to cut complexity and redundancy without changing behavior (it applies its edits to the working tree); record [simplify]. **(2)** **`/code-review` is opt-in — run step (2) only when the request's `code_review` header is `true`; when it is `false`, absent, or unset (the default), skip step (2) entirely and leave [code-review] unproduced (step (1) `/simplify` runs only when the request's `simplify` header is `true`).** *after that subagent returns*, spawn a **code-review subagent** — pass it the resulting post-simplify diff + [final plan] + [implementation report] plus the relevant repo context and have it run **`/code-review medium`** (`medium` is the skill's own effort level on its `low|medium|high|max|ultra` scale — a property of the skill call, not the subagent's model), **review-only** (never `--fix` or `--comment`), for correctness bugs and reuse/simplification/efficiency cleanups; record [code-review]. The `medium` gate is the skill's own argument — a per-subagent model reasoning-effort override is not settable on an ad-hoc Task spawn. When step (2) runs, order matters: `/simplify` writes the working tree and `/code-review` reads the resulting diff. **Fallback:** if a subagent cannot invoke its slash command or fails to spawn, the main agent runs that skill directly — or reviews the diff inline if the skill itself is unavailable — and records a `[fallback result]` (`status: fallback-single-agent`). If neither native skill is available, skip this sub-step.
   - **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the native skills.
2. The main agent reviews the changes directly, validates the implementation with [final plan] + [implementation report], and reports the conclusion as [direct review].
Based on whichever of [simplify] + [code-review] + [devils-advocate review] + [direct review] were produced, the main agent analyzes and validates them all, and generates a [final report]. Then the main agent applies the clearly-correct, low-risk findings (do not auto-apply uncertain or behavior-changing ones), then records any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes and [final report].
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
3. Summarize changes in bullet points to chat, and a yes/no answer indicating whether the refactor completed with no issues. If there are gaps, describe them.
