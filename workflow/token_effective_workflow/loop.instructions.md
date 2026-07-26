---
name: 'Fast Loop'
description: 'Unified token-effective (fast) loop meta-workflow for Claude Code, Codex, and VS Code Copilot: a controller-only main agent repeats a delegated body action — observe, check exit conditions, reflect & ledger — until a goal-met or an always-on safety stop fires.'
---
# Loop Until Goal or Exit Condition

**Safety: follow `_lib/safety_rules.md`.**

**Stay active: follow `_lib/stay_active.md`.** The controller never stands by while work is in flight, and any unavoidable wait must arm **two wake triggers through two different mechanisms** before it begins — wake safety is **per-wait**: a fired trigger is consumed, and a fresh pair must be armed (never extending the wait's absolute deadline) before waiting again.

**Loop control: follow `_lib/loop_control.md`.** Progress accounting (`raw_score` / `direction` / `total_delta` / `step_delta` / `best_delta`), exploration mode (fast probe iterations when stalled), the durable goal record, and the opt-in native-goal bridge are canonical there — this file deliberately does not restate them.

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: the main agent builds a condensed **[repo context digest]** from **[key md files]**, keeps the files themselves as **[full repo context]**, and passes the digest — plus the excerpts of [full repo context] each subagent's task needs — inline to subagents.

> **Loop meta-workflow.** The main agent is a **controller**, not a doer. It parses the spec; then for each iteration it **observes** the delegated result, **checks** the exit conditions, and **reflects & ledgers** — it never performs the body work itself. The *act* is **always delegated** to a spawned worker, which keeps the controller's context clean across many iterations. Exit conditions form an **OR-set** ("stop when ANY fires") with **always-on safety caps**, so the loop can never run away.

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
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - agents/implementer.agent.md
  - agents/executor.agent.md
  - skills/index.md
  - (dispatch only) workflow/<mode dir>/<family>.instructions.md for the dispatched family (<mode dir>: general → general_workflow, fast → token_effective_workflow, skill → skill_workflow)
-->

[inputs]:
- input 1: **[goal]** — *required*; a single concrete sentence (with a specific term/quantity, not a vague "improve").
- input 2: **[success criteria + exit conditions]** — *required*; the verifiable check(s) that define "done", plus any extra exit conditions (budget / human checkpoint). The `max_iterations` / `no_progress_k` caps come from the header (defaults below).
- input 3: **[loop body]** — *optional*; a free-form action to perform each iteration, **or** `dispatch: family=<code|debug|exec|refactor|query|correctness_check|pr|initialize> mode=<fast|general|skill>`. **If omitted, the controller decides the body from [goal] + [success criteria]** (see Step 1).
- input 4: **[starting state]** — *optional*; files / target repo / baseline notes. **Defaults to the current repo/workspace state** if omitted.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved via Pack Path Resolution). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Model & effort headers** (read from the request header; governed by [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Launch Contract — default `inherit`, never downgrade):
- `subagent_model` — model for the loop's own workers (the free-form body-worker, Devils Advocate, Online Researcher).
- `dispatch_main_model` — *dispatch only:* model for the sub-main agent that runs the dispatched family.
- `dispatch_subagent_model` — *dispatch only:* model for that family's own subagents.
- `subagent_effort` — reasoning-effort budget for those same workers (`inherit` | `low` | `medium` | `high` | `xhigh` | `max`; request templates ship `high`). Applied per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent effort — the platform effort field where the spawn exposes one, otherwise an `effort: <level> — binding budget, not a hint` line in the worker's prompt. `inherit` means add neither.
- `online_researcher_effort` — replaces `subagent_effort` for the Online Researcher only; honor it even when it is lower.
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
Read [key md files]. If important files are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, condense the understanding into a **[repo context digest]** (codebase structure/pipeline, key scripts, recent changes) and pass it, plus the excerpts of [full repo context] each subagent's task needs, inline to subagents.

**Parse [inputs] into a draft [loop spec] — decompose, then formalize. Step 2 validates it.**

*Decompose* the two required inputs into the fields below; *formalize* each so it is machine-checkable:
- **goal** — the single-sentence target from [input 1].
- **success criteria → verifiable checks** — turn each criterion from [input 2] into an **objective, tool-based check** (a test command, build/exit code, linter, or a grep/count) readable from a worker's result. **Never rely on model self-assessment alone** ("looks good" is not a check). For a command/test verifier, **capture the verifier's own exit status** (run it directly — a pipe like `… | tail` reports the *pipe's* exit code, not the verifier's), pin the pass condition to **`exit == 0`**, and **treat a vacuous result as failure** — an empty suite, all-skipped, or "no items collected" (e.g. `pytest` exit **5**) must NOT read as success; require a non-empty collected/asserted count. Add a one-line **constraints that must not change** element — invariants that must hold throughout (e.g. "no other test file is modified", "the public API is unchanged"), feeding the durable goal record's Exclusions (`_lib/loop_control.md`). Every goal-met check must be **demonstrable from the worker's returned output** (a transcript-only evaluator, e.g. native `/goal`, can only judge what was surfaced).
- **baseline** — snapshot the **starting state** ([input 4], or the current repo/workspace state by default) and record the **baseline value of the progress metric before iteration 1**. When the verifier is a test/script suite, also record a **hash of each verifier/test file** and the **collected-item count** (for the write-guard below).
- **progress metric** — one cheap proxy tied to ≥1 success criterion (e.g. failing-test count, % coverage, items remaining, build exit code); declare its **`direction`** (`minimize` | `maximize`) — plus, when the goal names a quantitative target, the metric's **target value** (the value at which goal-met fires) — and record it per [`_lib/loop_control.md`](../../_lib/loop_control.md) §Progress Accounting (`raw_score`, `total_delta`, `step_delta`, `best_delta` — defined there, not restated here). It must be cheap to read each iteration and **hard to game** (favor a metric that cannot be faked by adding comments/blank lines). **Anti-gaming write-guard (MANDATORY when the verifier is a test/script suite):** the body may edit **only non-verifier files**; each iteration the controller asserts the verifier/test files are **unchanged vs. the baseline hash** and the **collected-item count is invariant** — if a verifier/test file changed or the count moved, the metric was gamed (tests edited/skipped/deleted), so **reject/revert that iteration** rather than count it as progress.
- **exit conditions** — an OR-set of boolean predicates, evaluated each iteration in **priority order**. **Make every predicate concrete here** — each must be a boolean check evaluable from the iteration's result (no abstract conditions); drop any you cannot instantiate:
  1. **goal-met** (success) — all verifiable checks pass (e.g. `verifier exit == 0` with non-empty collection).
  2. **hard blocker** (failure / needs-human) — the verifier exits with an **error** status that is not a clean pass/fail (e.g. `pytest` exit 2/3/4/5 — collection / internal / usage error or no-tests), or the worker reports an unrecoverable blocker → stop and escalate.
  3. **budget / max-iterations** — `max_iterations` reached (header, default **10** — the hard cap), or any user token/time/cost budget exhausted.
  4. **no-progress** (stagnation) — **no new best** for `no_progress_k` consecutive committed iterations (header, default **3**) — best-relative and direction-aware per `_lib/loop_control.md` §Progress Accounting, never `total_delta`; before this exit may fire, a stalled loop first runs one bounded exploration episode of cheap single-idea probes per `_lib/loop_control.md` §Exploration Mode, which defers it.
  5. **divergence** (optional safety valve) — `step_delta` **strictly worse (direction-aware) for 2 consecutive accepted iterations** (per `_lib/loop_control.md` §Progress Accounting).
  - **human checkpoint** — optional; pause for approval before a named irreversible action.
- **loop body** — if [input 3] is given, use it. **Otherwise the controller decides it now:** classify the goal's intent (feature / fix / refactor / test / debug / query / exec / pr / …); when one of the existing families clearly fits, choose `dispatch: family=… mode=…`; otherwise choose a free-form action. Record the chosen body **and a one-line rationale** in the [loop spec].
- **strategy** — the `loop_strategy` header value, copied verbatim (default `stable_advancing`); its directives and invariant are canonical in `_lib/loop_control.md` §Loop Strategy.

**Local Skill Discovery (before any plan drafting):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`). Record [local skills] and fold it into the repo context; if nothing matches, record [local skills]: none relevant.

### Step 2 - Iteration Plan & Spec Validation
The main agent drafts an **[iteration plan]**: what one pass does, what the worker must return, the progress metric, and exactly how each exit condition is evaluated from the worker's compact result.

**The draft [loop spec] is validated here (not in Step 1), by the two subagents below — each runs the pre-flight guardrail checklist:** (a) the **goal** is concrete (a specific term/quantity, not a vague "improve"); (b) every **success criterion has an objective verifier** (tool-based, not model judgment alone); (c) the **baseline** is captured before the loop; (d) the **progress metric is hard to game** (composite or tied to real progress, not fakeable by comments/blank lines); (e) every **exit predicate is boolean-evaluable**; (f) the **loop body** (specified or controller-decided) fits the goal; (g) the **chosen `loop_strategy` fits the goal's risk/reversibility profile** (per `_lib/loop_control.md` §Loop Strategy).

**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only pre-loop step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Receive the repo context (per §Context Passing) + [loop spec] + [iteration plan]. Run the **guardrail checklist adversarially** and challenge the metrics, iteration plan, and whether [loop spec] makes sense: what could make this loop run forever or stop too early; whether each success criterion is actually verifiable from the worker's compact result; whether the progress metric is meaningful, cheap, and **un-game-able**; whether the caps and baseline are sane; whether the controller-decided body fits the goal. Flag any destructive/irreversible action that should be gated behind a human checkpoint. Report only evidence-backed criticisms (do not manufacture problems). Return [spec critique]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Receive the repo context (per §Context Passing) + [loop spec]. **Validate the verification methods against established practice** — are the chosen checks the standard, robust way to verify these success criteria; are there known pitfalls or stronger verifiers; and (when the body needs them) reliable references/approaches for the body action. The subagent MUST actually call its platform's web search/fetch tool(s) and return source URLs as proof — see `agents/online-researcher.agent.md`. Return [research + verifier validation]. |

The main agent folds [spec critique] + [research + verifier validation] into a finalized **[loop spec]** + **[iteration plan]**. On a failed guardrail: in **plan-only** mode surface the issue alongside the plan; in **autonomous** mode (default) record a one-line assumption/fix and proceed (per `_lib/approval_gate.md`).

### Step 3 - Approval Gate
Print the finalized [loop spec] + [iteration plan] (goal, body, strategy, exit OR-set, caps, progress metric).

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 4 unless the user asked for no changes or a plan-only review (in which case stop here, before any iteration or file change).

### Step 4 - Run the Loop
The main agent is the **controller**; the act is **always delegated**. Initialize the **[loop ledger]** (one line per iteration) and **persist it — plus the baseline and progress-accounting state (baseline metric value, `best`, `previous_committed`, stagnation/divergence counters, exploration-mode state, verifier/test-file hashes, collected-item count — per `_lib/loop_control.md` §Progress Accounting and §Exploration Mode) — to a scratch file**, so loop state survives across iterations and the controller's context stays lean (each iteration reloads a compact tail, not the whole history — the persisted progress-accounting state must never be lost to tail truncation). This persisted state is the loop's **durable goal record** (`_lib/loop_control.md` §Durable Goal Record); mirroring it into a platform's native goal facility is opt-in per §Native Goal Bridge. The scratch file must also carry the **[re-entry prompt]** block + **resume-vs-replay marker** per `_lib/loop_control.md` §Re-Entry Prompt, so a fresh controller with zero memory can resume mid-loop. The following steps can be adapted based on the [loop spec] + [iteration plan], but **success criteria and exit conditions** can not be changed. If any critical exit condition needs to be verified by scripts or codes, now spawn a subagent to implement those scripts/codes before starting the loop. **Iteration-commit / resume rule:** an iteration is committed only once its Observe & measure step (3) completes and its ledger entry is written (`completed: yes/no`); if a crash or ESCALATE interrupts iteration N before then, the next run sees the last entry `completed: no` (or missing) and re-runs that pass's Act step from the start — unless authoritative completion metadata shows that same pass's awaited work already finished with a work identity matching the pending-wait record (`_lib/stay_active.md` Rule 2) **and** the pass's verifiable check passes, in which case accept that result instead of re-running Act and commit iteration N via its normal Observe & measure step, write-guard included (on any mismatch or failed check, discard it and re-run) — distinct from the write-guard's reject/revert, which handles a *completed* but gamed iteration. Any side effect made before that commit point must be safe to repeat or deferred until after it.

**Spawn the exit-gater (before iterating).** Now that the exit conditions are finalized, spawn a **Devils Advocate** (`agents/devils-advocate.agent.md`, model = `subagent_model`) as the **exit-gater** (a safety guardrail — it runs regardless of the `devils_advocate` toggle) and pass it the **exit-condition check info** — the success criteria → verifiable checks, the exit OR-set (including `_lib/loop_control.md` §Exploration Mode's trigger, deferral, and episode-resolution rules), and exactly how each is evaluated from a worker's result; at each later gate check, also pass the current exploration state (episode open/closed, probes used, verdicts). This subagent **co-guards the exit gate** for the whole loop: the loop may exit **only when both the controller and the exit-gater agree** an exit condition is met (re-engage the same subagent each time the gate is checked; if your platform cannot persist it, re-spawn it with the same exit-condition check info). The `max_iterations` hard cap (and an unrecoverable hard-blocker / ESCALATE) still stops the loop unconditionally.

For iteration N = 1, 2, …:

1. **Pre-iteration exit check.** Evaluate the OR-set *before* acting (goal already met? any cap exhausted?). If a condition fires, **confirm the exit with the exit-gater** — stop only if both agree (the `max_iterations` cap — and an unrecoverable hard-blocker / ESCALATE — stops unconditionally). Record the reason for any stop.
2. **Act (delegated) — the main agent never edits/fixes/runs the body work itself.**
   - **Stay active while delegating (`_lib/stay_active.md`).** Delegating is not standing down: the controller does not end its turn, idle, or hand back to the user while the body-worker or dispatched sub-main agent is in flight — it watches the delegation through to its compact result. If this pass must wait on a background process or external event, follow the `_lib/stay_active.md` Rule 2 wait protocol: reconcile real state, **arm two wake triggers through two different mechanisms** (event-driven + a bounded watchdog tick under one immutable absolute deadline), reconcile again, and persist the pending-wait record to scratch state **before the wait begins** (never deferred to Reflect & ledger). Wake safety is per-wait — a fired trigger is consumed; re-arm a fresh pair before waiting again, never extending the deadline, and treat deadline expiry as a hard blocker. On every wake or resume, reconcile authoritative completion metadata first — notifications are hints.
   - **Near-cap wind-down:** when this pass reaches Act as the last one the pre-iteration check allows (`N == max_iterations`), instruct the worker to enter **wind-down mode** — stop starting new fixes, document remaining blockers, and emit a clean handoff — instead of opening a fresh attempt the hard cap would cut off mid-flight.
   - **Exploration mode (`_lib/loop_control.md` §Exploration Mode):** while an episode is open, this pass's delegation is a **probe** — a cheap, single-idea, reduced-scale experiment with a tool-evidenced verdict, never a full-scale attempt. After a confirmed probe, the next pass scales the idea up at full scale in normal mode.
   - **Free-form:** spawn a **body-worker subagent** (model = `subagent_model`), passing [repo context digest] + [iteration plan] + the current [loop ledger] tail + this pass's specific action + the [loop spec]'s strategy and its directives (per `_lib/loop_control.md` §Loop Strategy). It performs the action and returns a **compact result** only: **files changed** (one-line diff summary, or "none"), the **progress-metric value** (before → after), any **blocker**, and anything **noteworthy** (decisions, surprises, regressions). When the action is code or command work, the body-worker may be `agents/implementer.agent.md` or `agents/executor.agent.md`.
   - **Dispatch:** spawn one depth-1 **sub-main agent** (model = `dispatch_main_model`), instructed to run the chosen family's file `workflow/<mode dir>/<family>.instructions.md` (`<mode dir>`: `general` → `general_workflow`, `fast` → `token_effective_workflow`, `skill` → `skill_workflow`) **as that family's main agent** — spawning that family's own subagents at the next level with model = `dispatch_subagent_model` **and effort = this request's `subagent_effort` / `online_researcher_effort`, carried down unchanged** (§Subagent effort applies at that level too — there is no `dispatch_*_effort` header) — and to return only a **compact iteration summary** (**files changed** with a one-line diff summary, **progress-metric value** before → after, **blockers**, and **noteworthy items**), not its full transcript. Include the [loop spec]'s strategy as an **advisory note only** — it never overrides the dispatched family's own instructions, gates, or hard constraints (per `_lib/loop_control.md` §Loop Strategy). **Platform-conditional:** on **Claude Code**, nested subagents are supported (the sub-main spawns the family's workers directly); on **Codex / VS Code Copilot**, where nesting is limited, the loop main agent runs the family's instruction file **inline** for this iteration instead — sequential, equivalent results.
3. **Observe & measure.** Read the worker's compact result; re-run the verifiable check (capturing its own exit status) and record the iteration's progress-accounting entry (`raw_score`, `total_delta`, `step_delta`, `best_delta` per `_lib/loop_control.md` §Progress Accounting). **When the verifier is a test/script suite, run the write-guard first:** assert the verifier/test files are unchanged vs. the baseline hash and the collected-item count is invariant; if either moved, **reject/revert this iteration** (the metric was gamed, not earned) and record it as a blocked iteration. **Probe iterations (exploration mode):** re-run the probe's own cheap check instead of the full verifier and record probe accounting per `_lib/loop_control.md` §Exploration Mode — no `raw_score`, `best`/`previous_committed` unchanged; the verifier-file hash assertion still runs.
4. **Post-iteration exit check (exit gate — both must agree).** Before the no-progress predicate, apply `_lib/loop_control.md` §Exploration Mode: enter an exploration episode when its trigger fires, and resolve probe / scale-up outcomes per its episode-resolution rules (the deferred no-progress exit fires only as that section allows). Then re-evaluate the OR-set in priority order: goal met (all checks pass)? hard blocker / needs-human? budget exhausted or `max_iterations` reached? no new best for the last `no_progress_k` iterations (no-progress)? diverging (step-wise)? **If a condition fires, the loop exits only if both the controller and the exit-gater agree** to exit; on disagreement, continue and record it (the `max_iterations` cap — and an unrecoverable hard-blocker / ESCALATE — stops unconditionally). Record which condition fired.
5. **Reflect & ledger.** Append a [loop ledger] entry for iteration N capturing: **action** (free-form, or dispatched family+mode); **mode** (normal, or `explore` — with the probe's idea, verdict, and evidence); **code changes** (files touched + one-line diff summary, or "none"); **metric** (`before → after`, i.e. the improvement); **observation + blocker**; **noteworthy** (decisions, surprises, regressions, lessons); **exit-check result** (incl. the exit-gater's verdict when the gate was checked); **completed** (yes/no). Carry one short lesson forward to the next iteration, **stated as a concrete next action, not just an observation**. Refresh the scratch file's [re-entry prompt] block (iteration number, pending action, resume-vs-replay marker) as part of writing this entry.
6. **Continue or stop.** If no exit fired, start iteration N+1 **immediately** with **fresh minimal context**: reload [loop spec] + the persisted [loop ledger] tail (from the scratch file) and discard the worker's verbose intermediate output (the context-rot defense). The end of an iteration is **never** a reason to yield the turn — only a fired exit condition, a recorded escalation, or a declared human checkpoint is (`_lib/stay_active.md`). **The loop MUST terminate at the max-iterations cap regardless.**

### Step 5 - Post-loop Review and Validation

**[PARALLEL EXECUTION — launch the sub-step 2 review-skill subagents in one batch; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Issue every enabled subagent invocation below before waiting on any result, and perform the main agent's own direct review while they run. **Speed-for-accuracy trade:** simplify writes the working tree while the other reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before the remediation pass. Degrade to sequential (simplify first) only if parallel launch is unavailable.
1. Summarize the outcome from the [loop ledger]: goal met (yes/no), which exit condition fired, final state vs success criteria, and — **aggregated across all iterations** — the **net code changes** (cumulative files touched + net diff summary), the **metric trajectory** (baseline → final `raw_score`; `total_delta` = total improvement), and the collected **noteworthy items** (key decisions, surprises, regressions, lessons).
2. **Review skills (opt-in; both headers default to `false`):** only when some iteration edited source files, resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `false` skips, `true` runs Claude Code's native `/simplify` / `/code-review medium`, `local` runs the pack's local `code-simplification` / `code-review-and-quality` skills (portable to every platform). Spawn one subagent per enabled skill **in parallel — issue both invocations before waiting on either** (per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback; degrade to sequential, simplify first, only if parallel launch is unavailable), following the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) (subagents use the `subagent_model` header; keep an activity log and record fallbacks). Pass each the net diff + [loop spec] + [loop ledger] plus the relevant repo context. Record [simplify] and/or [code-review] for whichever ran; leave a skipped skill's label unproduced. Skip entirely when the loop only ran commands without editing source.
3. **While those subagents run**, the main agent reviews the net changes directly, validates them against [loop spec] + [loop ledger], and reports the conclusion as [direct review].
4. Based on whichever of [simplify] + [code-review] + [direct review] were produced, the main agent analyzes and validates them all — reconciling [simplify] against [code-review] per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats when both ran — and consolidates them with the Step 5 outcome summary into a [final report], recording any remaining gaps. Then the main agent applies the clearly-correct, low-risk findings (do not auto-apply uncertain or behavior-changing ones). If the outcome did not meet the goal, summarize the gaps and lessons learned in bullet points to chat (no more than 3 sentences), and pass to step 6 for documentation and summary. If the outcome met the goal, pass to step 6 for documentation and summary.

### Step 6 - Documentation and Summary
1. If the loop changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes and [final report].
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
