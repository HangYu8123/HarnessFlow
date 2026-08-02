---
name: 'Fast Goal Exec'
description: 'Unified token-effective (fast) goal-execution workflow for Claude Code, Codex, and VS Code Copilot: main-agent plan, one parallel Devils Advocate + Online Researcher subagent step, and direct execution with captured-output validation.'
---
# Execute Toward a Goal in a Repo

> **Scope.** This workflow executes **actions toward a goal** in a single plan → challenge → execute → validate pass. An **action** is any executable step toward the goal — a shell command, a skill invocation, a script run, a tool/API call, or an ops operation. If the goal needs *iteration to converge* (repeat until a condition holds), use the **loop** family instead; if the deliverable is *new or changed source code*, use the **code** family. This workflow runs once and never becomes a convergence loop.

**Safety: follow `_lib/safety_rules.md`.**

**Derived-action guard.** When [inputs] input 2 is absent and the actions are **derived** from the goal rather than specified by the user, the main agent must print the derived action list before executing it, and must treat any derived action that is destructive, irreversible, or outward-facing as a pause point per [`_lib/approval_gate.md`](../../_lib/approval_gate.md) §Mode 2 and `_lib/safety_rules.md` — the user authorized a *goal*, not those specific actions.

**Stay active: follow `_lib/stay_active.md`.** The main agent never stands by while a command or subagent is in flight, and any unavoidable wait must arm **two wake triggers through two different mechanisms** before it begins — wake safety is **per-wait**: a fired trigger is consumed, and a fresh pair must be armed (never extending the wait's absolute deadline) before waiting again.

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/stay_active.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - agents/diversifier.agent.md
  - skills/index.md
-->

[inputs]:
- input 1: goal / target outcome to achieve (required)
- input 2: specific actions to use (optional — commands, skills, scripts, or operations; if omitted, the plan derives them from the goal)
- input 3: success criteria / definition of done (optional but recommended — how to verify the goal was met)
- input 4: important files (optional)
- input 5: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved via Pack Path Resolution). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, condense the understanding into a **[repo context digest]** (a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes) and pass it, plus the excerpts of [full repo context] each subagent's task needs, inline to subagents.

**Local Skill Discovery (before any plan drafting):** When the goal or any specified action involves a named skill, or the goal could be aided by a local skill, perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`); fold the result [local skills] into the repo context (per §Context Passing) so the Step 3 subagents receive it, and integrate it when the main agent drafts [plan]/[final plan]. Skip when the goal is served by plain commands with no relevant skill ([local skills]: none relevant).

### Step 2 - Execution Planning
Based on the repo context (per §Context Passing) + [inputs], the main agent reads the relevant files and proposes a [plan] covering the goal, the exact actions to run (validating any actions specified in [inputs] and deriving the rest), preconditions, expected outputs, the success criteria that prove the goal was met, failure modes, and rollback strategy.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]**

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Receive the repo context (per §Context Passing) + [plan] + [inputs], and read all relevant scripts/files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify wrong flags, destructive or irreversible side effects, missing prerequisites, environment assumptions, over-engineering, regressions, and actions that do not actually achieve the stated goal. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Receive the repo context (per §Context Passing) + [plan] + [inputs]. Search the live internet for reliable references for the planned actions (command/skill/tool syntax), known issues, and version compatibility; the subagent MUST actually call its platform's web search/fetch tool(s) and return source URLs as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |
| Diversify | **Diversifier** (`agents/diversifier.agent.md`) | `diversifier: on` · default `on` | Receive the repo context (per §Context Passing) + [plan] + [inputs], and read relevant scripts/files if needed. Propose 5 alternative action plans that each achieve the stated goal — including one **risky**, one **aggressive**, and one **rare** — each structurally different from [plan] and from each other, each carrying a calibrated `P(better)` that it beats [plan]. Return [diverse plans]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]; when [diverse plans] was produced, it adopts any alternative from them whose `P(better)` and evidence beat the current plan (otherwise keeping it, with a one-line note why). Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no changes or a plan-only review.

### Step 5 - Execution
The main agent validates preconditions (environment, dependencies, required files), executes the planned actions per [final plan] directly, and captures stdout, stderr, exit codes/statuses, and pass/fail state into [execution report] with no explanations.

**Stay active through execution (`_lib/stay_active.md`).** The main agent stays engaged from the first action to the last: it does not end its turn, idle, or hand back to the user while an action is still running, and it never asks the user to report when something finishes. Any action that blocks on a background process, a long build, or an external event must be **bounded** and must follow the `_lib/stay_active.md` Rule 2 wait protocol: reconcile real state, arm **two wake triggers through two different mechanisms** — one event-driven (completion notification / condition watch) and one time-driven fallback (a renewable watchdog tick or bounded polling re-check under one immutable absolute deadline that re-arming never extends) — reconcile again, then persist the pending-wait record (generation, awaited work, start time + deadline, last reconciliation result) to a scratch note **before the wait begins**. Whichever fires first, re-verify the real state (exit code, output, files) rather than trusting the trigger — a fired trigger is consumed, so re-arm a fresh pair before waiting again. On resume, accept a cached result only if its work identity matches the pending-wait record and validation passes, else re-execute safely per [final plan]. If the absolute deadline expires, record it as a hard blocker and escalate — never wait indefinitely. Record each completed wait (what was awaited, both triggers, which fired, duration) in [execution report].

### Step 6 - Review and Validation

**[PARALLEL EXECUTION — launch the review-skill subagents in one batch; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Issue every enabled subagent invocation below before waiting on any result, and perform the main agent's own direct review while they run. **Speed-for-accuracy trade:** simplify writes the working tree while the other reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before the remediation pass. Degrade to sequential (simplify first) only if parallel launch is unavailable.
1. **Review skills (opt-in; both headers default to `false`):** only when the execution edited source files, resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `false` skips, `true` runs Claude Code's native `/simplify` / `/code-review medium`, `local` runs the pack's local `code-simplification` / `code-review-and-quality` skills (portable to every platform). Spawn one subagent per enabled skill **in parallel — issue both invocations before waiting on either** (per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback; degrade to sequential, simplify first, only if parallel launch is unavailable), following the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) (subagents use the `subagent_model` header; keep an activity log and record fallbacks). Pass each the edited source files (the current diff) + [final plan] + [execution report] plus the relevant repo context. Record [simplify] and/or [code-review] for whichever ran; leave a skipped skill's label unproduced. Skip entirely when the execution only ran actions without editing source.
2. **While those subagents run**, the main agent reviews the changes directly, validates the execution against [final plan] + [execution report] — including whether the goal was achieved per its success criteria — and reports the conclusion as [direct review].
Based on whichever of [simplify] + [code-review] + [direct review] were produced, the main agent analyzes and validates them all — reconciling [simplify] against [code-review] per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats when both ran — and generates a [final report]. Then the main agent applies the clearly-correct, low-risk findings (do not auto-apply uncertain or behavior-changing ones), then records any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. If execution changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes and [final report].
2. Write to update_logs.md per `_lib/doc_logging.md` (timestamps, IDs, two-file rule):
```md
{=============================Execution Update===============================}
{Objective + Timestamp (current time, YYYY-MM-DD HH:MM) + Execution ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested — the goal and its success criteria)}
{Actions executed (what was run and parameters)}
{Result (success/failure, key outputs, side effects)}
{Achieved (yes/no per the success criteria, gaps if any)}
```
3. Summarize execution results in bullet points to chat, and a yes/no answer indicating whether the goal was achieved and the execution completed with no issues. If there are gaps, describe them.
