---
name: 'Goal Execution'
description: 'Instructions for executing actions toward a goal with structured planning and validation'
---
# Execute Toward a Goal in a Repo

> **Scope.** This workflow executes **actions toward a goal** in a single plan → challenge → execute → validate pass. An **action** is any executable step toward the goal — a shell command, a skill invocation, a script run, a tool/API call, or an ops operation. If the goal needs *iteration to converge* (repeat until a condition holds), use the **loop** family instead; if the deliverable is *new or changed source code*, use the **code** family. This workflow runs once and never becomes a convergence loop.

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/stay_active.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - _lib/subagent_effectiveness.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
-->

**Safety: follow `_lib/safety_rules.md`.**

**Derived-action guard.** When [inputs] input 2 is absent and the actions are **derived** from the goal rather than specified by the user, the main agent must print the derived action list before executing it, and must treat any derived action that is destructive, irreversible, or outward-facing as a pause point per [`_lib/approval_gate.md`](../../_lib/approval_gate.md) §Mode 2 and `_lib/safety_rules.md` — the user authorized a *goal*, not those specific actions.

**Stay active: follow `_lib/stay_active.md`.** The main agent never stands by while a command or subagent is in flight, and any unavoidable wait must arm **two wake triggers through two different mechanisms** before it begins — wake safety is **per-wait**: a fired trigger is consumed, and a fresh pair must be armed (never extending the wait's absolute deadline) before waiting again.

[inputs]:
- input 1: goal / target outcome to achieve (required)
- input 2: specific actions to use (optional — commands, skills, scripts, or operations; if omitted, the plan derives them from the goal)
- input 3: success criteria / definition of done (optional but recommended — how to verify the goal was met)
- input 4: important files (optional)
- input 5: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved by the Pack Path Resolution rule). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering and Local Skill Discovery
Read [key md files]. Understand them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, create a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes — and pass it, plus the excerpts of [full repo context] each subagent's task needs, inline to every subagent.

If preferred files are specified, the main agent must read through the preferred files, then combine the understood knowledge with [key md files].

**Local Skill Discovery (before any plan drafting):** When the goal or any specified action involves a named skill, or the goal could be aided by a local skill, perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`); fold the result [local skills] into [repo context digest] and integrate it when the main agent drafts [final plan]. Skip when the goal is served by plain commands with no relevant skill ([local skills]: none relevant).

### Step 2 - Execution Analysis Panel
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [inputs] and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Focus analysis | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Always | Process [inputs] and the repo context (per §Context Passing), and determine the sequence of actions that achieves the goal — validating any actions specified in [inputs] and deriving the rest — plus what pre-conditions are needed, what scripts and files are associated with the execution, and what the expected outcomes should be. Read through the highly associated files and scripts. Draft an execution plan that covers pre-conditions, the exact actions to run, expected outputs, the success criteria that prove the goal was met, and potential failure modes, while referencing any known issues in known_issues.md. Return [plan 1] and [diagram 1]. |
| Free analysis | **Free Analyst** (`agents/free-analyst.agent.md`) | Always | Process [inputs] and the repo context (per §Context Passing), then decide what files to read and what scripts to check, following its own logic. Determine what actions achieve the goal, what dependencies exist, how to execute them safely, and what validation criteria prove the goal was met. Draft an execution plan with its own approach. Return [plan 2]. |

### Step 3 - Draft the Final Plan
The main agent reviews [plan 1], [plan 2], and [diagram 1], and reads necessary files. Reject incorrect or redundant parts. Combine all that information and draft a [final plan] that covers: the goal, the exact actions to run, pre-conditions, expected outputs, the success criteria that determine goal achievement, and rollback strategy if applicable. The [final plan] must be feasible, safe, and verified against existing tests and behavior.

### Step 4 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final plan] and the goal (plus any specified actions) from [inputs] to all three subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Receive the repo context (per §Context Passing) and all relevant scripts, then critically challenge [final plan] — looking for wrong flags, destructive side effects, missing prerequisites, environment assumptions, potential failures, and actions that do not actually achieve the stated goal. Return flaws as [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Receive the repo context (per §Context Passing), then identify extra needs for tools, packages, action and command syntax, known issues, and version compatibility. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |
| Diversify | **Diversifier** (`agents/diversifier.agent.md`) | `diversifier: on` · default `on` | Receive the repo context (per §Context Passing), [final plan], and the goal (plus any specified actions) from [inputs]. Then propose 3–5 alternative action plans that each achieve the stated goal — searching the **risky**, **aggressive**, and **rare** archetypes and reporting any archetype with no viable candidate rather than filling it — each structurally different from [final plan] and from each other, each carrying a calibrated `P(better)` that it beats [final plan] and a `graftable:` component. Return [diverse plans]. |

### Step 5 - Incorporate Criticisms
The main agent incorporates [valid criticisms] and [online resource], and updates [final plan] accordingly. When [diverse plans] was produced, it weighs them: where an alternative's `P(better)` and evidence show it beats [final plan], adopt it — or graft in the part of it that wins — and restate [final plan] on that basis; otherwise keep [final plan] and record in one line why the alternatives were not taken. Either way, before moving on, sweep the rejected alternatives' `graftable:` fields and merge any component that improves [final plan] on its own.

### Step 6 - Print Plan and Approval Gate
The main agent prints the updated [final plan], so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

### Step 7 - Execution
The main agent creates an **Executor** subagent (`agents/executor.agent.md`), passing [final plan], the goal, and the planned actions. **Executor Model Verification:** See `_lib/implementer_fallback.md`. The subagent (or the main agent, if falling back) must also receive the repo context (per §Context Passing). Then based on [final plan], validate pre-conditions (environment, dependencies, required files). Then the subagent executes the planned actions per [final plan], capturing stdout, stderr, and exit codes (or the equivalent result and status for actions that are not shell commands). If an action fails, the subagent records the failure and continues to the next action unless [final plan] specifies otherwise. After finishing the execution, the subagent must generate an [execution report] (actions run, outputs, exit codes/statuses, pass/fail — **no explanation**), and report [execution report] back to the main agent.

**Stay active through execution (`_lib/stay_active.md`).** The main agent stays engaged from the first action to the last: it does not end its turn, idle, or hand back to the user while the Executor or any action is still running, and it never asks the user to report when something finishes. Any action that blocks on a background process, a long build, or an external event must be **bounded** and must follow the `_lib/stay_active.md` Rule 2 wait protocol: reconcile real state, arm **two wake triggers through two different mechanisms** — one event-driven (completion notification / condition watch) and one time-driven fallback (a renewable watchdog tick or bounded polling re-check under one immutable absolute deadline that re-arming never extends) — reconcile again, then persist the pending-wait record (generation, awaited work, start time + deadline, last reconciliation result) to a scratch note **before the wait begins**. Whichever fires first, re-verify the real state (exit code, output, files) rather than trusting the trigger — a fired trigger is consumed, so re-arm a fresh pair before waiting again. On resume, accept a cached result only if its work identity matches the pending-wait record and validation passes, else re-execute safely per [final plan]. If the absolute deadline expires, record it as a hard blocker in [execution report] and escalate — never wait indefinitely. Record each completed wait (what was awaited, both triggers, which fired, duration) in [execution report]. Any awaited job that could outlive the session (run limit past the platform's idle-reap horizon, or spanning a possible session pause) is launched **session-detached** with a durable on-exit status marker and its own timeout backstop, and an attached watcher loop is never the only bridge to the next action — a watcher or attached task reporting "killed" means the session-side watcher died, not the work: reconcile real state before drawing any conclusion (`_lib/stay_active.md` §Session-survivable launches).

### Step 8 - Post-Execution Review (platform-conditional)
**This whole step runs only if the execution produced or modified files. If no files were modified, skip it.**

- **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely.
- **When a header is `true` and the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — it is the only caller of the native `/simplify` and `/code-review`; do not invoke either separately. (`/code-review` additionally requires that the execution changed code files.)
- **When a header is `local` (any platform, no Claude Code dependency):** skip that wrapper skill and spawn the local-skill subagent directly per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `skills/code-simplification/SKILL.md` for `simplify`, `skills/code-review-and-quality/SKILL.md` for `code_review`.
- **Otherwise (`true` on Codex, or VS Code Copilot without Claude Code skills):** the native skills do not exist — skip them; instead, the main agent performs a manual review of execution output for any anomalies before proceeding.
- **Parallel launch (speed-for-accuracy trade):** launch **every** review subagent this step spawns — the native wrapper's, or the `local` ones — **in parallel, including simplify** (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback). Simplify writes the working tree while the reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before applying anything. Degrade to sequential (simplify first) only if parallel launch is unavailable.

### Step 9 - Execution Review and QA
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final plan], the goal and its success criteria, [execution report], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Result review | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Always | Review the execution results. Analyze the execution output from a senior staff engineer perspective: assess whether the execution produced correct and expected results, validate output against the expected outcomes and success criteria defined in [final plan], judge whether the goal was actually achieved, and identify any unexpected behaviors or anomalies in the output. Return [execution review report]. |
| QA validation | **QA Engineer** (`agents/qa-engineer.agent.md`) | Always | Review the execution results. Validate the execution from a QA engineer perspective: check for side effects, state changes, file modifications, environment changes, and errors. If the user has requested to actually **run validation scripts**, run them and validate whether the execution results are as expected without errors. Return [execution QA report] based on the validation. |

### Step 10 - Update Overview Docs
The main agent reads through [final plan], [execution report], [execution review report], and [execution QA report], then understands the execution, the results, and any changes to the codebase. If the execution changed the repo state, the main agent updates codebase_overview.md and scripts_overview.md based on the actual changes (including the failures based on [execution review report] and [execution QA report]).

### Step 11 - Summarize the Execution
The main agent summarizes the execution in the following format:
```md
{=============================Execution Update===============================}
{Objective (very high level description of the goal), Timestamp (fill the current time here, YYYY-MM-DD HH:MM), and Execution Id (assign a number in order, i.e., plus 1 to the last functionality id in update_logs.md)}
{Execution description (one or two sentences of what was executed)}
{Repo involved (what local repos are involved)}
{Actions executed (what actions were run and with what parameters)}
{Result (success/failure, key outputs, side effects)}
{Achieved (whether the execution achieved the goal per its success criteria, if not achieved, what is the gap)}
```

### Step 12 - Write Logs and Chat Summary
Write the Execution Update summary to update_logs.md per `_lib/doc_logging.md` (timestamps, IDs, two-file rule). Do not add additional contents, just the execution update report from Step 11. In addition, summarize the execution results in bullet points and write them to the chat.

### Step 13 - Subagent Effectiveness Record
Record [subagent effectiveness] per [`_lib/subagent_effectiveness.md`](../../_lib/subagent_effectiveness.md): for each opt-in helper this workflow actually ran — Devils Advocate, Diversifier, Online Researcher, `simplify`, `code_review` — write one line carrying the dials it ran under (`[model · effort]`, from the launch resolution), its adoption count (`adopted n/m` plus what the accepted items changed), its novelty and importance tokens, and a `useful` / `partly useful` / `not useful` verdict — record effect, never what the helper did — then append the entry to `repo_info/subagent_effectiveness.md`.
