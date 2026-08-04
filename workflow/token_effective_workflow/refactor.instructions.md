---
name: 'Fast Refactor'
description: 'Unified token-effective (fast) refactor workflow for Claude Code, Codex, and VS Code Copilot: main-agent plan, one parallel challenge + research subagent step, opt-in approval gate, direct implementation, platform-conditional native-skills review with self-challenge, and behavior-preservation validation'
---
# Refactor an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - _lib/subagent_effectiveness.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - agents/diversifier.agent.md
-->

[inputs]:
- input 1: target refactor functionalities/repository/scripts
- input 2: target files (optional)
- input 3: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under repo_info/). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If target files are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Condense [key md files] (plus any target files read) into a [repo context digest] per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: pass [inputs], [repo context digest], and the excerpts of [full repo context] each subagent's task needs.

### Step 2 - Refactor Analysis

Based on the repo context ([key md files] and [target files]) + [inputs], the main agent reads the relevant files. Then the main agent proposes a [plan] for addressing the target refactors + a [comparison] report (before/after) indicating the changes + behavior-preservation notes.

based on the request, after the plan is done, double check, make sure the plan covers:
   - What functionalities/scripts must be refactored and why.
   - What is inappropriately designed/placed in the existing codebase and why.
   - How to improve the code architecture and what the improvements are.
   - What functionalities/scripts must be refactored and why.
   - What is inappropriately designed/placed in the existing codebase and why.
   - How to improve the code architecture and what the improvements are.
   - What functionalities/scripts have redundancy and why.
   - Whether there are overlapped implementations and why they overlap.
   - How to reduce redundancy and what the improvements are.
   - What functionalities/scripts have robustness issues and why.
   - Whether there are potential bugs or issues and why.
   - How to improve robustness and what the improvements are.
ignore the questions that are irrelevant to the refactor request.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]**

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Receive the repo context (per §Context Passing) + [plan] + [comparison] + [inputs], and read additional files/scripts if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify overlooked side effects, integration risks, incorrect assumptions, over-engineering, and regressions. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Receive the repo context (per §Context Passing) + [plan] + [comparison] + [inputs]. Search online for reliable references, established solutions, and available resources. Return [online resource]. |
| Diversify | **Diversifier** (`agents/diversifier.agent.md`) | `diversifier: on` · default `on` | Receive the repo context (per §Context Passing) + [plan] + [comparison] + [inputs], and read additional files if needed. Propose 5 alternative refactor plans that each achieve the refactor targets — including one **risky**, one **aggressive**, and one **rare** — each structurally different from [plan] and from each other, each carrying a calibrated `P(better)` that it beats [plan]. Return [diverse plans]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]; when [diverse plans] was produced, it adopts any alternative from them whose `P(better)` and evidence beat the current plan (otherwise keeping it, with a one-line note why). Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
The main agent implements [final plan] and records an [implementation report] containing changes only, with no explanations.

### Step 6 - Code Review and Validation

**[PARALLEL EXECUTION — launch the review-skill subagents in one batch; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Issue every enabled subagent invocation below before waiting on any result, and perform the main agent's own direct review while they run. **Speed-for-accuracy trade:** simplify writes the working tree while the other reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before the remediation pass. Degrade to sequential (simplify first) only if parallel launch is unavailable.
1. **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `false` skips, `true` runs Claude Code's native `/simplify` / `/code-review medium`, `local` runs the pack's local `code-simplification` / `code-review-and-quality` skills (portable to every platform). Spawn one subagent per enabled skill **in parallel — issue both invocations before waiting on either** (per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback; degrade to sequential, simplify first, only if parallel launch is unavailable), following the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) (subagents use the `subagent_model` header; keep an activity log and record fallbacks). Pass each the changed files (the current diff) + [final plan] + [implementation report] plus the relevant repo context. Record [simplify] and/or [code-review] for whichever ran; leave a skipped skill's label unproduced.
2. **While those subagents run**, the main agent reviews the changes directly, and reports the conclusion as [direct review].
Based on whichever of [simplify] + [code-review] + [direct review] were produced, the main agent analyzes and validates them all — reconciling [simplify] against [code-review] per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats when both ran — and generates a [final report]. Then the main agent applies the clearly-correct, low-risk findings (do not auto-apply uncertain or behavior-changing ones), then records any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes and [final report].
2. Write to update_logs.md per `_lib/doc_logging.md` (timestamps, IDs, two-file rule):
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

### Step 8 - Subagent Effectiveness Record
Record [subagent effectiveness] per [`_lib/subagent_effectiveness.md`](../../_lib/subagent_effectiveness.md): for each opt-in helper this workflow actually ran — Devils Advocate, Diversifier, Online Researcher, `simplify`, `code_review` — write exactly two sentences (what it contributed, anchored to the accept/reject adjudication already recorded; then a `useful` / `partly useful` / `not useful` verdict in a few words), then append the entry to `repo_info/subagent_effectiveness.md`.
