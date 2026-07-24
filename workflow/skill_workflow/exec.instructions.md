---
name: 'Skill-Based Goal Exec'
description: 'Unified skill-backed (skill mode) goal-execution workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast workflow, but the challenge, research, and post-execution self-challenge instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback.'
---
# Execute Toward a Goal in a Repo

> **Scope.** This workflow executes **actions toward a goal** in a single plan → challenge → execute → validate pass. An **action** is any executable step toward the goal — a shell command, a skill invocation, a script run, a tool/API call, or an ops operation. If the goal needs *iteration to converge* (repeat until a condition holds), use the **loop** family instead; if the deliverable is *new or changed source code*, use the **code** family. This workflow runs once (plus the single remediation pass defined in Step 6) and never becomes a convergence loop.

**Safety: follow `_lib/safety_rules.md`.**

**Derived-action guard.** When [inputs] input 2 is absent and the actions are **derived** from the goal rather than specified by the user, the main agent must print the derived action list before executing it, and must treat any derived action that is destructive, irreversible, or outward-facing as a pause point per [`_lib/approval_gate.md`](../../_lib/approval_gate.md) §Mode 2 and `_lib/safety_rules.md` — the user authorized a *goal*, not those specific actions.

**Stay active: follow `_lib/stay_active.md`.** The main agent never stands by while a command or subagent is in flight, and any unavoidable wait must arm **two wake triggers through two different mechanisms** before it begins — wake safety is **per-wait**: a fired trigger is consumed, and a fresh pair must be armed (never extending the wait's absolute deadline) before waiting again.

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: the main agent builds a condensed **[repo context digest]** from **[key md files]**, keeps the files themselves as **[full repo context]**, and passes the digest — plus the excerpts of [full repo context] each subagent's task needs — inline to subagents.

> **Skill-backed variant (skill mode).** The challenge, research, and post-execution self-challenge step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). The execution-planning and execution steps have no qualifying skill (goal execution is not a code-implementation plan) and are unchanged. Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue. Verified star counts and verification dates live **only** in that registry (single source — re-verify there); do not restate them in this file.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/stay_active.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - _lib/local_skill_discovery.md
  - skills/skill_workflow_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - skills/claude-native-skills-subagents/SKILL.md
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

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). **Every spawn carries two dials, not one:** model from the `subagent_model` header, effort from the `subagent_effort` header (and from `online_researcher_effort` for the Online Researcher). Unless the resolved effort is `inherit`, set the platform effort field where the spawn exposes one, otherwise put the line `effort: <level> — binding budget, not a hint` in the subagent prompt. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, condense the understanding into a **[repo context digest]** (a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes) and pass it, plus the excerpts of [full repo context] each subagent's task needs, inline to subagents.

### Step 2 - Execution Planning
*(Unchanged — no qualifying skill fits goal-execution planning.)*
**Local Skill Discovery (before drafting [plan]):** When the goal or any specified action involves a named skill, or the goal could be accomplished or aided by a local skill, perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`), recorded as [local skills]. Skip when the goal is served by plain commands with no relevant skill ([local skills]: none relevant).

Based on the repo context (per §Context Passing) + [inputs] + [local skills], the main agent reads the relevant files and proposes a [plan] covering the goal, the exact actions to run (validating any actions specified in [inputs] and deriving the rest), preconditions, expected outputs, the success criteria that prove the goal was met, failure modes, and rollback strategy.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | **Skill-backed:** run the challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) — a structured devil's-advocate / pre-mortem over the repo context (per §Context Passing) + [plan] + [inputs], reading relevant scripts/files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify wrong flags, destructive or irreversible side effects, missing prerequisites, environment assumptions, over-engineering, regressions, and actions that do not actually achieve the stated goal; report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate task as written in the fast workflow. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | **Skill-backed:** draft [online resource] by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`) — plan/search/read/synthesize a **cited report** of reliable references for the planned actions (command/skill/tool syntax), known issues, and version compatibility for [plan] + [inputs]. The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof (see `agents/online-researcher.agent.md`). **Fallback if `deep-research` is unavailable:** perform the Online Researcher task as written in the fast workflow. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no changes or a plan-only review.

### Step 5 - Execution
*(Unchanged — goal execution with captured output, not a code-implementation plan.)*
The main agent validates preconditions (environment, dependencies, required files), executes the planned actions per [final plan] directly, and captures stdout, stderr, exit codes/statuses, and pass/fail state into [execution report] with no explanations.

**Stay active through execution (`_lib/stay_active.md`).** The main agent stays engaged from the first action to the last: it does not end its turn, idle, or hand back to the user while an action is still running, and it never asks the user to report when something finishes. Any action that blocks on a background process, a long build, or an external event must be **bounded** and must follow the `_lib/stay_active.md` Rule 2 wait protocol: reconcile real state, arm **two wake triggers through two different mechanisms** — one event-driven (completion notification / condition watch) and one time-driven fallback (a renewable watchdog tick or bounded polling re-check under one immutable absolute deadline that re-arming never extends) — reconcile again, then persist the pending-wait record (generation, awaited work, start time + deadline, last reconciliation result) to a scratch note **before the wait begins**. Whichever fires first, re-verify the real state (exit code, output, files) rather than trusting the trigger — a fired trigger is consumed, so re-arm a fresh pair before waiting again. On resume, accept a cached result only if its work identity matches the pending-wait record and validation passes, else re-execute safely per [final plan]. If the absolute deadline expires, record it as a hard blocker and escalate — never wait indefinitely. Record each completed wait (what was awaited, both triggers, which fired, duration) in [execution report].

### Step 6 - Review and Validation
1. **Review skills** (`true` = Claude Code native · `local` = the pack's local skills; see [`_lib/review_skills.md`](../../_lib/review_skills.md)):
   - **Review skills (opt-in; both headers default to `false`):** only when the execution edited source files, resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely. When a header is **`true`** and the main agent is Claude Code (or another Claude agent with Claude Code skills available), run the native review **once** via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — that skill is the only caller of `/simplify` and `/code-review`; do not run either yourself in addition to it. When a header is **`local`**, skip that wrapper and spawn the local-skill subagent directly (`skills/code-simplification/SKILL.md`, resp. `skills/code-review-and-quality/SKILL.md`) — this works on every platform. Record [simplify] and/or [code-review] for whichever ran. If a `true` header's native skill is unavailable, skip it. Skip the whole sub-step when the execution only ran actions without editing source; in that case the main agent still reviews any edited source directly.
2. **Skill-backed self-challenge:** run **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) over the [execution report] — claim every item is wrong, explain why, then draft a [post-impl challenge report]. **Fallback if unavailable:** the main agent performs this self-challenge inline.
3. The main agent validates [execution report] against [final plan]: the goal is achieved per its success criteria, outputs match expectations, side effects and state changes are intended, and modified files are inspected when applicable. Save the conclusion as [direct review].
4. Based on whichever of [simplify] + [code-review] + [post-impl challenge report] + [direct review] were produced, if any validation fails, perform **one** remediation pass (revise [final plan] and re-execute once, only when another attempt is safe); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. If execution changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes.
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
3. Summarize execution results in bullet points to chat.
