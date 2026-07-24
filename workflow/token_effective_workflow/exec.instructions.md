---
name: 'Fast Goal Exec'
description: 'Unified token-effective (fast) goal-execution workflow for Claude Code, Codex, and VS Code Copilot: main-agent plan through the general-family analyst lenses, one parallel Devils Advocate + Online Researcher subagent step, and direct execution with captured-output validation.'
---
# Execute Toward a Goal in a Repo

> **Scope.** This workflow executes **actions toward a goal** in a single plan → challenge → execute → validate pass. An **action** is any executable step toward the goal — a shell command, a skill invocation, a script run, a tool/API call, or an ops operation. If the goal needs *iteration to converge* (repeat until a condition holds), use the **loop** family instead; if the deliverable is *new or changed source code*, use the **code** family. This workflow runs once and never becomes a convergence loop.

**Safety: follow `_lib/safety_rules.md`.**

**Derived-action guard.** When [inputs] input 2 is absent and the actions are **derived** from the goal rather than specified by the user, the main agent must print the derived action list before executing it, and must treat any derived action that is destructive, irreversible, or outward-facing as a pause point per [`_lib/approval_gate.md`](../../_lib/approval_gate.md) §Mode 2 and `_lib/safety_rules.md` — the user authorized a *goal*, not those specific actions.

**Stay active: follow `_lib/stay_active.md`.** The main agent never stands by while a command or subagent is in flight, and any unavoidable wait must arm **two wake triggers through two different mechanisms** before it begins — wake safety is **per-wait**: a fired trigger is consumed, and a fresh pair must be armed (never extending the wait's absolute deadline) before waiting again.

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

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
  - skills/index.md
  (role emulation — see workflow_contract.md §Main-Agent Role Emulation)
  - agents/focus-analyst.agent.md
  - agents/free-analyst.agent.md
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

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). **Every spawn carries two dials, not one:** model from the `subagent_model` header, effort from the `subagent_effort` header (and from `online_researcher_effort` for the Online Researcher). Unless the resolved effort is `inherit`, set the platform effort field where the spawn exposes one, otherwise put the line `effort: <level> — binding budget, not a hint` in the subagent prompt. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, condense the understanding into a **[repo context digest]** (a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues) to pass inline to subagents; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.

**Local Skill Discovery (before any plan drafting):** When the goal or any specified action involves a named skill, or the goal could be aided by a local skill, perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`); fold the result [local skills] into the repo context (per §Context Passing) so the Step 3 subagents receive it, and integrate it when the main agent drafts [plan]/[final plan]. Skip when the goal is served by plain commands with no relevant skill ([local skills]: none relevant).

### Step 2 - Execution Planning
Based on the repo context (per §Context Passing) + [inputs], the main agent reads the relevant files and proposes a [plan] covering the goal, the exact actions to run (validating any actions specified in [inputs] and deriving the rest), preconditions, expected outputs, the success criteria that prove the goal was met, failure modes, and rollback strategy.

**Role emulation** (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Main-Agent Role Emulation): read `agents/focus-analyst.agent.md` and `agents/free-analyst.agent.md`, and apply each as a lens on the files read in this step — depth on the scripts and entry points the actions touch, and a free-judgment pass on what else the goal actually requires — into [plan].

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]**

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Receive the repo context (per §Context Passing) + [plan] + [inputs], and read all relevant scripts/files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify wrong flags, destructive or irreversible side effects, missing prerequisites, environment assumptions, over-engineering, regressions, and actions that do not actually achieve the stated goal. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Receive the repo context (per §Context Passing) + [plan] + [inputs]. Search the live internet for reliable references for the planned actions (command/skill/tool syntax), known issues, and version compatibility; the subagent MUST actually call its platform's web search/fetch tool(s) and return source URLs as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no changes or a plan-only review.

### Step 5 - Execution
The main agent validates preconditions (environment, dependencies, required files), executes the planned actions per [final plan] directly, and captures stdout, stderr, exit codes/statuses, and pass/fail state into [execution report] with no explanations.

**Stay active through execution (`_lib/stay_active.md`).** The main agent stays engaged from the first action to the last: it does not end its turn, idle, or hand back to the user while an action is still running, and it never asks the user to report when something finishes. Any action that blocks on a background process, a long build, or an external event must be **bounded** and must follow the `_lib/stay_active.md` Rule 2 wait protocol: reconcile real state, arm **two wake triggers through two different mechanisms** — one event-driven (completion notification / condition watch) and one time-driven fallback (a renewable watchdog tick or bounded polling re-check under one immutable absolute deadline that re-arming never extends) — reconcile again, then persist the pending-wait record (generation, awaited work, start time + deadline, last reconciliation result) to a scratch note **before the wait begins**. Whichever fires first, re-verify the real state (exit code, output, files) rather than trusting the trigger — a fired trigger is consumed, so re-arm a fresh pair before waiting again. On resume, accept a cached result only if its work identity matches the pending-wait record and validation passes, else re-execute safely per [final plan]. If the absolute deadline expires, record it as a hard blocker and escalate — never wait indefinitely. Record each completed wait (what was awaited, both triggers, which fired, duration) in [execution report].

### Step 6 - Review and Validation
1. **Review skills (opt-in; both headers default to `false`):** only when the execution edited source files, resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `false` skips, `true` runs Claude Code's native `/simplify` / `/code-review medium`, `local` runs the pack's local `code-simplification` / `code-review-and-quality` skills (portable to every platform). Spawn one subagent per enabled skill, **sequentially, simplify first**, following the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) (subagents use the `subagent_model` header; keep an activity log and record fallbacks). Pass each the edited source files (the current diff) + [final plan] + [execution report] plus the relevant repo context. Record [simplify] and/or [code-review] for whichever ran; leave a skipped skill's label unproduced. Skip entirely when the execution only ran actions without editing source.
2. The main agent reviews the changes directly, validates the execution against [final plan] + [execution report] — including whether the goal was achieved per its success criteria — and reports the conclusion as [direct review].
Based on whichever of [simplify] + [code-review] + [direct review] were produced, the main agent analyzes and validates them all, and generates a [final report]. Then the main agent applies the clearly-correct, low-risk findings (do not auto-apply uncertain or behavior-changing ones), then records any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. If execution changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes and [final report].
2. Write to update_logs.md:
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
