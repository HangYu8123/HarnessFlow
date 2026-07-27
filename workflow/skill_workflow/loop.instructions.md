---
name: 'Skill-Based Loop'
description: 'Unified skill-backed (skill mode) loop meta-workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast loop, but the iteration-plan, challenge, research, and body instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback. Loop control (spec parsing, exit-condition evaluation, write-guard, ledger) stays inline — no qualifying skill exists.'
---
# Loop Until Goal or Exit Condition

**Safety: follow `_lib/safety_rules.md`.**

**Stay active: follow `_lib/stay_active.md`.** The controller never stands by while work is in flight, and any unavoidable wait must arm **two wake triggers through two different mechanisms** before it begins — wake safety is **per-wait**: a fired trigger is consumed, and a fresh pair must be armed (never extending the wait's absolute deadline) before waiting again.

**Loop control: follow `_lib/loop_control.md`.** Progress accounting (`raw_score` / `direction` / `total_delta` / `step_delta` / `best_delta`), exploration mode (fast probe iterations when stalled), the durable goal record, and the opt-in native-goal bridge are canonical there — this file deliberately does not restate them.

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: the main agent builds a condensed **[repo context digest]** from **[key md files]**, keeps the files themselves as **[full repo context]**, and passes the digest — plus the excerpts of [full repo context] each subagent's task needs — inline to subagents.

> **Loop meta-workflow.** The main agent is a **controller**, not a doer. It parses the spec; then for each iteration it **observes** the delegated result, **checks** the exit conditions, and **reflects & ledgers** — it never performs the body work itself. The *act* is **always delegated**. Exit conditions form an **OR-set** ("stop when ANY fires") with **always-on safety caps**, so the loop can never run away.

> **Skill-backed variant (skill mode).** Selected step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue — never block on a missing external skill. Verified star counts and verification dates live **only** in that registry (single source — re-verify there); do not restate them in this file. **Loop control** (spec parsing, the write-guard, exit-condition evaluation, the ledger) has **no qualifying ≥1000★ skill and stays inline** in all modes.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/stay_active.md
  - _lib/loop_control.md
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
  - agents/implementer.agent.md
  - agents/executor.agent.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
  - (dispatch only) workflow/<mode dir>/<family>.instructions.md for the dispatched family (<mode dir>: general → general_workflow, fast → token_effective_workflow, skill → skill_workflow)
-->

[inputs]:
- input 1: **[goal]** — *required*; a single concrete sentence (with a specific term/quantity, not a vague "improve").
- input 2: **[success criteria + exit conditions]** — *required*; the verifiable check(s) that define "done", plus any extra exit conditions (budget / human checkpoint). The `max_iterations` / `no_progress_k` caps come from the header (defaults below).
- input 3: **[loop body]** — *optional*; a free-form action to perform each iteration, **or** `dispatch: family=<code|debug|exec|refactor|query|correctness_check|pr|initialize> mode=<fast|general|skill>`. **If omitted, the controller decides the body from [goal] + [success criteria]** (see Step 1).
- input 4: **[starting state]** — *optional*; files / target repo / baseline notes. **Defaults to the current repo/workspace state** if omitted.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved via Pack Path Resolution). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Model & effort headers** (read from the request header; governed by [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Launch Contract — templates ship Opus 5 + low; `inherit` never downgrades):
- `subagent_model` — model for the loop's own workers (the body-worker, Devils Advocate, Online Researcher).
- `dispatch_main_model` — *dispatch only:* model for the sub-main agent that runs the dispatched family.
- `dispatch_subagent_model` — *dispatch only:* model for that family's own subagents.
- `subagent_effort` — reasoning-effort budget for those same workers (`inherit` | `low` | `medium` | `high` | `xhigh` | `max`; request templates ship `low`). Applied per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent effort — the platform effort field where the spawn exposes one, otherwise an `effort: <level> — binding budget, not a hint` line in the worker's prompt. `inherit` means add neither.
- `online_researcher_effort` — replaces `subagent_effort` for the Online Researcher only (request templates ship `medium`); honor it even when it is lower.
- *Dispatch:* there is no separate `dispatch_*_effort` header — both effort levels **cross the dispatch boundary unchanged**, and the sub-main agent applies them to every subagent it spawns, just as `loop_strategy` is passed down.

**Safety-cap headers** (read from the request header; always enforced — these are the always-on stops):
- `max_iterations` — hard iteration cap (default **10** if absent). The loop MUST stop here regardless of any other condition.
- `no_progress_k` — stop after this many consecutive iterations with no measurable progress (default **3** if absent).

**Strategy header** (read from the request header; semantics canonical in [`_lib/loop_control.md`](../../_lib/loop_control.md) §Loop Strategy — this file does not restate them):
- `loop_strategy` — how iterations advance: `aggressive` | `fast_iteration` | `stable_advancing` (default **`stable_advancing`** if absent/unrecognized). Strategy modulates body-work style only — it never weakens the success criteria, exit conditions, safety caps, or write-guard.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). **Every spawn carries two dials, not one:** model from the `subagent_model` header, effort from the `subagent_effort` header (and from `online_researcher_effort` for the Online Researcher). Unless the resolved effort is `inherit`, set the platform effort field where the spawn exposes one, otherwise put the line `effort: <level> — binding budget, not a hint` in the subagent prompt. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering & Loop-Spec Parsing
*(Loop control — inline; no qualifying skill.)*
Read [key md files]. If important files are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, condense the understanding into a **[repo context digest]** and pass it, plus the excerpts of [full repo context] each subagent's task needs, inline to subagents.

**Parse [inputs] into a draft [loop spec]** (decompose, then formalize so each field is machine-checkable):
- **goal** — the single-sentence target from [input 1].
- **success criteria → verifiable checks** — each criterion as an **objective, tool-based check**; never model self-assessment alone. **Capture the verifier's own exit status** (run it directly, not through a pipe), pin the pass to **`exit == 0`**, and **treat a vacuous result as failure** (empty / all-skipped / no items collected, e.g. `pytest` exit **5**). Add a one-line **constraints that must not change** element — invariants that must hold throughout (e.g. "no other test file is modified", "the public API is unchanged"), feeding the durable goal record's Exclusions (`_lib/loop_control.md`). Every goal-met check must be **demonstrable from the worker's returned output** (a transcript-only evaluator, e.g. native `/goal`, can only judge what was surfaced).
- **baseline** — the starting state ([input 4], or current repo/workspace state by default) + the progress-metric baseline before iteration 1; when the verifier is a test/script suite, also a **hash of each verifier/test file** and the **collected-item count**.
- **progress metric** — one cheap proxy tied to ≥1 success criterion, hard to game; declare its **`direction`** (`minimize` | `maximize`) — plus, when the goal names a quantitative target, the metric's **target value** (the value at which goal-met fires) — and record it per [`_lib/loop_control.md`](../../_lib/loop_control.md) §Progress Accounting (`raw_score`, `total_delta`, `step_delta`, `best_delta` — defined there, not restated here). **Anti-gaming write-guard (MANDATORY for test/script verifiers):** the body may edit **only non-verifier files**; the controller asserts verifier/test files unchanged vs. baseline hash + collected-item count invariant each iteration (reject/revert otherwise).
- **exit conditions** — an OR-set of **concrete boolean predicates** in **priority order**: (1) goal-met = all checks pass; (2) hard blocker = verifier error status (e.g. `pytest` 2/3/4/5) or unrecoverable worker blocker → escalate; (3) budget / `max_iterations`; (4) no-progress = **no new best** for `no_progress_k` consecutive committed iterations (best-relative and direction-aware per `_lib/loop_control.md` §Progress Accounting, never `total_delta`; before this exit may fire, a stalled loop first runs one bounded exploration episode of cheap single-idea probes per `_lib/loop_control.md` §Exploration Mode, which defers it); (5) divergence = `step_delta` strictly worse (direction-aware) for 2 consecutive accepted iterations; plus optional human checkpoint. Drop any predicate you cannot instantiate.
- **loop body** — use [input 3] if given; otherwise the controller decides (classify intent → `dispatch: family=… mode=…` when a family fits, else a free-form action) with a one-line rationale.
- **strategy** — the `loop_strategy` header value, copied verbatim (default `stable_advancing`); its directives and invariant are canonical in `_lib/loop_control.md` §Loop Strategy.

**Local Skill Discovery (before any plan drafting):** per `_lib/local_skill_discovery.md`, scan `skills/index.md`; on a confirmed match read its `SKILL.md`. Record [local skills] (or "none relevant") and fold it into the repo context.

### Step 2 - Iteration Plan & Spec Validation
**Skill (replaces the iteration-plan drafting):** Produce the **[iteration plan]** by following **`writing-plans`** (`obra/superpowers:skills/writing-plans/SKILL.md`) — feed it the [loop spec] as the spec; it returns a dependency-ordered, verification-per-step plan covering what one pass does, what the worker must return, the progress metric, and exactly how each exit predicate is evaluated from the worker's compact result. When intent is ambiguous, first run the companion **`brainstorming`** (`obra/superpowers:skills/brainstorming/SKILL.md`) — but defer any approval to the opt-in gate (`_lib/approval_gate.md`), not brainstorming's own gate.
**Fallback if the skill is unavailable:** the main agent drafts the [iteration plan] inline (as in the fast loop).

**The draft [loop spec] is validated here by the two subagents below — each runs the pre-flight guardrail checklist:** (a) goal concrete; (b) every success criterion has an objective verifier; (c) baseline captured; (d) progress metric hard to game; (e) every exit predicate boolean-evaluable; (f) the loop body fits the goal; (g) the chosen `loop_strategy` fits the goal's risk/reversibility profile (per `_lib/loop_control.md` §Loop Strategy).

**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only pre-loop step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | **Skill-backed:** run the guardrail challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) — a structured devil's-advocate / pre-mortem over the repo context (per §Context Passing) + [loop spec] + [iteration plan]. Run the guardrail checklist adversarially: what could make the loop run forever or stop too early; whether each success criterion is verifiable; whether the progress metric is cheap and **un-game-able**; whether the caps and baseline are sane; whether the body fits. Flag destructive/irreversible actions needing a human checkpoint. Return [spec critique]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate guardrail challenge as written in the fast loop. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | **Skill-backed:** validate the verification methods by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`) — plan/search/read/synthesize a **cited** check on whether the chosen checks are the standard, robust way to verify these success criteria, known pitfalls, and stronger verifiers (and references for the body action when needed). The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof. Return [research + verifier validation]. **Fallback if `deep-research` is unavailable:** perform the Online Researcher verifier-validation as written in the fast loop. |

The main agent folds [spec critique] + [research + verifier validation] into a finalized **[loop spec]** + **[iteration plan]**. On a failed guardrail: in **plan-only** mode surface it; in **autonomous** mode (default) record a one-line assumption/fix and proceed (per `_lib/approval_gate.md`).

### Step 3 - Approval Gate
Print the finalized [loop spec] + [iteration plan] (goal, body, strategy, exit OR-set, caps, progress metric, write-guard). **Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed to Step 4 unless the user asked for no changes / a plan-only review (then stop here).

### Step 4 - Run the Loop
*(Loop control — inline; no qualifying skill.)*
The main agent is the **controller**; the act is **always delegated**. Initialize the **[loop ledger]** and **persist it — plus the baseline and progress-accounting state (baseline metric value, `best`, `previous_committed`, stagnation/divergence counters, exploration-mode state, verifier/test-file hashes, collected-item count — per `_lib/loop_control.md` §Progress Accounting and §Exploration Mode) — to a scratch file** (state survives iterations; controller context stays lean; the persisted progress-accounting state must never be lost to tail truncation). This persisted state is the loop's **durable goal record** (`_lib/loop_control.md` §Durable Goal Record); mirroring it into a platform's native goal facility is opt-in per §Native Goal Bridge. The scratch file must also carry the **[re-entry prompt]** block + **resume-vs-replay marker** per `_lib/loop_control.md` §Re-Entry Prompt, so a fresh controller with zero memory can resume mid-loop. **Success criteria and exit conditions cannot be changed during the loop.** If a critical exit condition needs script/code verification, spawn a subagent to build those verifier scripts first. **Iteration-commit / resume rule:** an iteration is committed only once its Observe & measure step (3) completes and its ledger entry is written (`completed: yes/no`); if a crash or ESCALATE interrupts iteration N before then, the next run sees the last entry `completed: no` (or missing) and re-runs that pass's Act step from the start — unless authoritative completion metadata shows that same pass's awaited work already finished with a work identity matching the pending-wait record (`_lib/stay_active.md` Rule 2) **and** the pass's verifiable check passes, in which case accept that result instead of re-running Act and commit iteration N via its normal Observe & measure step, write-guard included (on any mismatch or failed check, discard it and re-run) — distinct from the write-guard's reject/revert, which handles a *completed* but gamed iteration. Any side effect made before that commit point must be safe to repeat or deferred until after it.

**Spawn the exit-gater (before iterating).** Now that the exit conditions are finalized, spawn a **Devils Advocate** (`agents/devils-advocate.agent.md`, model = `subagent_model`) as the **exit-gater** (a safety guardrail — it runs regardless of the `devils_advocate` toggle) and pass it the **exit-condition check info** — the success criteria → verifiable checks, the exit OR-set (including `_lib/loop_control.md` §Exploration Mode's trigger, deferral, and episode-resolution rules), and exactly how each is evaluated from a worker's result; at each later gate check, also pass the current exploration state (episode open/closed, probes used, verdicts). This subagent **co-guards the exit gate** for the whole loop: the loop may exit **only when both the controller and the exit-gater agree** an exit condition is met (re-engage the same subagent each time the gate is checked; if your platform cannot persist it, re-spawn it with the same exit-condition check info). The `max_iterations` hard cap (and an unrecoverable hard-blocker / ESCALATE) still stops the loop unconditionally.

For iteration N = 1, 2, …:

1. **Pre-iteration exit check.** Evaluate the OR-set *before* acting (goal already met? any cap exhausted?). If a condition fires, **confirm the exit with the exit-gater** — stop only if both agree (the `max_iterations` cap — and an unrecoverable hard-blocker / ESCALATE — stops unconditionally). Record the reason for any stop.
2. **Act (delegated) — the controller never edits/fixes/runs the body itself.**
   - **Stay active while delegating (`_lib/stay_active.md`).** Delegating is not standing down: the controller does not end its turn, idle, or hand back to the user while the body-worker or dispatched sub-main agent is in flight — it watches the delegation through to its compact result. If this pass must wait on a background process or external event, follow the `_lib/stay_active.md` Rule 2 wait protocol: reconcile real state, **arm two wake triggers through two different mechanisms** (event-driven + a bounded watchdog tick under one immutable absolute deadline), reconcile again, and persist the pending-wait record to scratch state **before the wait begins** (never deferred to Reflect & ledger). Wake safety is per-wait — a fired trigger is consumed; re-arm a fresh pair before waiting again, never extending the deadline, and treat deadline expiry as a hard blocker. On every wake or resume, reconcile authoritative completion metadata first — notifications are hints.
   - **Near-cap wind-down:** when this pass reaches Act as the last one the pre-iteration check allows (`N == max_iterations`), instruct the worker to enter **wind-down mode** — stop starting new fixes, document remaining blockers, and emit a clean handoff — instead of opening a fresh attempt the hard cap would cut off mid-flight.
   - **Exploration mode (`_lib/loop_control.md` §Exploration Mode):** while an episode is open, this pass's delegation is a **probe** — a cheap, single-idea, reduced-scale experiment with a tool-evidenced verdict, never a full-scale attempt. After a confirmed probe, the next pass scales the idea up at full scale in normal mode.
   - **Free-form (skill-backed):** spawn a body-worker (model = `subagent_model`) that performs the action — receiving the [loop spec]'s strategy and its directives (per `_lib/loop_control.md` §Loop Strategy) — and returns a **compact result** (files changed + one-line diff, progress-metric value before → after, blocker, noteworthy). When the action is **code/feature** work, the worker follows **`executing-plans`** (`obra/superpowers:skills/executing-plans/SKILL.md`) reinforced by **`test-driven-development`** (`obra/superpowers:skills/test-driven-development/SKILL.md`) for the red→green→refactor loop; when the action is **debugging**, it follows **`systematic-debugging`** (`obra/superpowers:skills/systematic-debugging/SKILL.md`) — reproduce → isolate → root-cause before fixing. **Fallback if the skills are unavailable:** the body-worker performs the action directly (as in the fast loop), still returning only the compact result.
   - **Dispatch:** spawn one depth-1 **sub-main agent** (model = `dispatch_main_model`) to run `workflow/<mode dir>/<family>.instructions.md` (`<mode dir>`: `general` → `general_workflow`, `fast` → `token_effective_workflow`, `skill` → `skill_workflow`) **as that family's main agent** (prefer `mode: skill` for the dispatched family unless [input 3] says otherwise), spawning that family's subagents at the next level with model = `dispatch_subagent_model` **and effort = this request's `subagent_effort` / `online_researcher_effort`, carried down unchanged** (§Subagent effort applies at that level too — there is no `dispatch_*_effort` header), returning only a **compact iteration summary**. Include the [loop spec]'s strategy as an **advisory note only** — it never overrides the dispatched family's own instructions, gates, or hard constraints (per `_lib/loop_control.md` §Loop Strategy). **Platform-conditional:** on Claude Code nested subagents are supported; on Codex / VS Code Copilot (limited nesting) the controller runs the family inline — sequential, equivalent.
3. **Observe & measure.** Read the worker's compact result; re-run the verifiable check (capturing its own exit status) and record the iteration's progress-accounting entry (`raw_score`, `total_delta`, `step_delta`, `best_delta` per `_lib/loop_control.md` §Progress Accounting). **When the verifier is a test/script suite, run the write-guard first:** assert verifier/test files unchanged vs. baseline hash and collected-item count invariant; if either moved, **reject/revert this iteration** and record it as blocked. **Probe iterations (exploration mode):** re-run the probe's own cheap check instead of the full verifier and record probe accounting per `_lib/loop_control.md` §Exploration Mode — no `raw_score`, `best`/`previous_committed` unchanged; the verifier-file hash assertion still runs.
4. **Post-iteration exit check.** Before the no-progress predicate, apply `_lib/loop_control.md` §Exploration Mode: enter an exploration episode when its trigger fires, and resolve probe / scale-up outcomes per its episode-resolution rules (the deferred no-progress exit fires only as that section allows). Then re-evaluate the OR-set in priority order (goal-met? hard-blocker? budget/max-iter? no-progress? divergence?). **If a condition fires, the loop exits only if both the controller and the exit-gater agree** to exit; on disagreement, continue and record it (the `max_iterations` cap — and an unrecoverable hard-blocker / ESCALATE — stops unconditionally). Record which condition fired.
5. **Reflect & ledger.** Append a [loop ledger] entry for iteration N: action (free-form, or dispatched family+mode); mode (normal, or `explore` — with the probe's idea, verdict, and evidence); code changes (files + one-line diff, or "none"); metric (`before → after`); observation + blocker; noteworthy; exit-check result (incl. the exit-gater's verdict when the gate was checked); completed (yes/no). Carry one short lesson forward, **stated as a concrete next action, not just an observation**. Refresh the scratch file's [re-entry prompt] block (iteration number, pending action, resume-vs-replay marker) as part of writing this entry.
6. **Continue or stop.** If no exit fired, start iteration N+1 **immediately** with **fresh minimal context** (reload [loop spec] + persisted [loop ledger] tail; discard verbose intermediate output). The end of an iteration is **never** a reason to yield the turn — only a fired exit condition, a recorded escalation, or a declared human checkpoint is (`_lib/stay_active.md`). **The loop MUST terminate at the max-iterations cap regardless.**

### Step 5 - Post-loop Review and Validation

**[PARALLEL EXECUTION — launch the sub-step 2 review-skill subagents and the sub-step 3 `the-fool` self-challenge in one batch; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Issue every enabled subagent invocation below before waiting on any result, and perform the main agent's own direct review while they run. **Speed-for-accuracy trade:** simplify writes the working tree while the other reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before the remediation pass. Degrade to sequential (simplify first) only if parallel launch is unavailable.
1. Summarize the outcome from the [loop ledger]: goal met (yes/no), which exit condition fired, final state vs success criteria, and — aggregated across iterations — the **net code changes**, the **metric trajectory** (baseline → final + total improvement), and the collected **noteworthy items**.
2. **Review skills** (`true` = Claude Code native · `local` = the pack's local skills; see [`_lib/review_skills.md`](../../_lib/review_skills.md)):
   - **Review skills (opt-in; both headers default to `false`):** only when some iteration edited source files, resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely. When a header is **`true`** and the main agent is Claude Code (or another Claude agent with Claude Code skills available), run the native review **once** via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — that skill is the only caller of `/simplify` and `/code-review`; do not run either yourself in addition to it. When a header is **`local`**, skip that wrapper and spawn the local-skill subagent directly (`skills/code-simplification/SKILL.md`, resp. `skills/code-review-and-quality/SKILL.md`) — this works on every platform. Record [simplify] and/or [code-review] for whichever ran. If a `true` header's native skill is unavailable, skip it. Skip the whole sub-step when the loop only ran commands without editing source; in that case the main agent reviews the net diff directly.
3. **Skill-backed self-challenge:** run **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) over the loop outcome — claim the goal is NOT genuinely met (gamed metric? regressions? vacuous pass?), explain why, then reconcile. **Fallback if unavailable:** the main agent performs this self-challenge inline.
4. If the outcome did not meet the goal, summarize the gaps and lessons learned in bullet points to chat (no more than 3 sentences), then go to Step 6. If it met the goal, go to Step 6.

### Step 6 - Documentation and Summary
1. If the loop changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Loop Update===============================}
{Loop Name + Timestamp (current time, YYYY-MM-DD HH:MM) + Loop ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Goal / success criteria}
{Loop body (free-form action, or dispatched family + mode)}
{Loop strategy (aggressive | fast_iteration | stable_advancing)}
{Exit conditions (the OR-set + caps that were in effect)}
{Iterations run + exit reason (which condition fired)}
{Code changes (net files touched + diff summary, or none)}
{Metric trajectory (baseline → final, total improvement)}
{Noteworthy (key decisions, surprises, regressions, lessons)}
{summary from Step 5 (gaps if any)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize the loop outcome (iterations run, exit reason, net code changes, metric trajectory, achieved y/n) in bullet points to chat.
