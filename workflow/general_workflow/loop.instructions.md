---
name: 'Loop'
description: 'Unified general (full multi-subagent) loop meta-workflow for Claude Code, Codex, and VS Code Copilot: an analyst panel designs the loop spec, adversarial validation hardens it, and a controller runs the loop with independent per-iteration progress evaluation and a goal-met confirmation panel until a goal-met or an always-on safety stop fires.'
---
# loop until a goal or exit condition

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

> **Loop meta-workflow.** The main agent is a **controller**, not a doer. It designs the spec; then for each iteration it **observes** the delegated result, **checks** the exit conditions, and **reflects & ledgers** — it never performs the body work itself. The *act* is **always delegated** to a spawned worker. Exit conditions form an **OR-set** ("stop when ANY fires") with **always-on safety caps**, so the loop can never run away.

> **General (full) variant.** This is the thorough, multi-subagent loop: an **analyst panel** drafts the [loop spec] from three cognitive perspectives, a **Senior Engineer** consolidates it, and **Devils Advocate + Online Researcher** validate it before the loop runs. During the loop, each iteration's progress is **independently evaluated** to counter action-bias, and a candidate goal-met is **confirmed by a Senior Engineer + QA Engineer panel** before success is declared. For a leaner single-controller loop, use `mode: fast`.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - _lib/local_skill_discovery.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - agents/focus-analyst.agent.md
  - agents/broad-analyst.agent.md
  - agents/free-analyst.agent.md
  - agents/senior-engineer.agent.md
  - agents/qa-engineer.agent.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - agents/implementer.agent.md
  - agents/executor.agent.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
  - (dispatch only) workflow/<mode>/<family>.instructions.md for the dispatched family
-->

[inputs]:
- input 1: **[goal]** — *required*; a single concrete sentence (with a specific term/quantity, not a vague "improve").
- input 2: **[success criteria + exit conditions]** — *required*; the verifiable check(s) that define "done", plus any extra exit conditions (budget / human checkpoint). The `max_iterations` / `no_progress_k` caps come from the header (defaults below).
- input 3: **[loop body]** — *optional*; a free-form action to perform each iteration, **or** `dispatch: family=<code|debug|exec|refactor|query|correctness_check|pr|initialize> mode=<fast|general|skill>`. **If omitted, the analyst panel + controller decide the body from [goal] + [success criteria]** (see Step 2).
- input 4: **[starting state]** — *optional*; files / target repo / baseline notes. **Defaults to the current repo/workspace state** if omitted.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved via Pack Path Resolution).

**Model headers** (read from the request header; governed by [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Launch Contract — default `inherit`, never downgrade):
- `subagent_model` — model for the loop's own workers (analysts, Senior/QA Engineer, body-worker, Devils Advocate, Online Researcher).
- `dispatch_main_model` — *dispatch only:* model for the sub-main agent that runs the dispatched family.
- `dispatch_subagent_model` — *dispatch only:* model for that family's own subagents.

**Safety-cap headers** (read from the request header; always enforced — these are the always-on stops):
- `max_iterations` — hard iteration cap (default **10** if absent). The loop MUST stop here regardless of any other condition.
- `no_progress_k` — stop after this many consecutive iterations with no measurable progress (default **3** if absent).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS

1. **Context Gathering.** Read [key md files]. If important files / a target repo are specified in [inputs], read them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, condense the understanding into a **[repo context digest]** (codebase structure/pipeline, key scripts, recent changes, active known issues) to pass inline to subagents; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly. **Local Skill Discovery:** per `_lib/local_skill_discovery.md`, scan `skills/index.md`; on a confirmed match read its `SKILL.md`. Record [local skills] (or "none relevant") and fold it into the repo context.

2. **Spec design — analyst panel.** The main agent creates three subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** (**Focus Analyst** via `agents/focus-analyst.agent.md`; **Broad Analyst** via `agents/broad-analyst.agent.md`; **Free Analyst** via `agents/free-analyst.agent.md`), passing [inputs] + the repo context (per §Context Passing) + [local skills]. Each analyst drafts a **candidate [loop spec]** with these formalized, machine-checkable fields:
   - **goal** — the single-sentence target from [input 1].
   - **success criteria → verifiable checks** — each criterion as an **objective, tool-based check** (test command, build/exit code, linter, grep/count) readable from a worker's result; never model self-assessment alone. **Capture the verifier's own exit status** (run it directly — a pipe reports the pipe's exit code, not the verifier's), pin the pass condition to **`exit == 0`**, and **treat a vacuous result as failure** (empty suite / all-skipped / no items collected, e.g. `pytest` exit **5**) — require a non-empty collected/asserted count.
   - **baseline** — the **starting state** ([input 4], or the current repo/workspace state by default) + the **baseline value of the progress metric before iteration 1**; when the verifier is a test/script suite, also a **hash of each verifier/test file** and the **collected-item count**.
   - **progress metric** — one cheap proxy tied to ≥1 success criterion; cheap to read and **hard to game**. **Anti-gaming write-guard (MANDATORY when the verifier is a test/script suite):** the body may edit **only non-verifier files**; the controller asserts verifier/test files unchanged vs. baseline hash and collected-item count invariant each iteration.
   - **exit conditions** — an OR-set of **concrete boolean predicates** in **priority order** (drop any you cannot instantiate): (1) **goal-met** = all verifiable checks pass; (2) **hard blocker** = verifier error status (e.g. `pytest` 2/3/4/5) or unrecoverable worker blocker → escalate; (3) **budget / max-iterations**; (4) **no-progress** = metric `delta == 0` for `no_progress_k` iterations; (5) **divergence** = metric worse than prior for 2 consecutive iterations; plus optional **human checkpoint**.
   - **loop body** — use [input 3] if given; otherwise propose one (free-form action, or `dispatch: family=… mode=…` when an existing family fits) with a one-line rationale.

   Each analyst applies its cognitive mode (Focus: depth on the most relevant files/verifier; Broad: whole pipeline upstream→downstream; Free: own judgment) and returns its candidate as [spec 1], [spec 2], [spec 3].

3. **Consolidate — Senior Engineer.** The main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), passing [spec 1/2/3] + [inputs] + the repo context (per §Context Passing). The subagent reviews the three candidates from a senior-staff perspective, **rejects game-able metrics, unverifiable criteria, and abstract (non-boolean) predicates**, confirms the write-guard and the captured exit-status semantics, and returns a single **[consolidated loop spec]** + a **[iteration plan]** (what one pass does, what the worker must return, the progress metric, and exactly how each exit predicate is evaluated from the worker's compact result).

4. **Validate — adversarial + research.** The main agent creates two subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, passing the repo context (per §Context Passing) + [consolidated loop spec] + [iteration plan]:
   a. **Devils Advocate** (`agents/devils-advocate.agent.md`) runs the **pre-flight guardrail checklist adversarially**: (a) goal concrete; (b) every success criterion has an objective verifier; (c) baseline captured; (d) progress metric hard to game; (e) every exit predicate boolean-evaluable; (f) the body fits the goal. It challenges what could make the loop run forever or stop too early, and flags any destructive/irreversible action needing a human checkpoint. Returns [spec critique].
   b. **Online Researcher** (`agents/online-researcher.agent.md`) **validates the verification methods against established practice** (are the chosen checks the standard, robust way to verify these criteria; known pitfalls or stronger verifiers; references for the body action when needed). It MUST call its platform's live web search/fetch tool(s) and return source URLs as proof — see `agents/online-researcher.agent.md`. Returns [research + verifier validation].

   The main agent folds [spec critique] + [research + verifier validation] into a **[final loop spec]** + **[final iteration plan]**.

5. **Print + Approval Gate.** Print [final loop spec] + [final iteration plan] (goal, body, exit OR-set, caps, progress metric, write-guard). **Approval gate:** see `_lib/approval_gate.md` — proceed to Step 6 unless the user asked for no changes / a plan-only review (then stop here, before any iteration or file change).

6. **Run the loop.** The main agent is the **controller**; the act is **always delegated**. Initialize the **[loop ledger]** and **persist it — plus the baseline (metric value, verifier/test-file hashes, collected-item count) — to a scratch file** (state survives iterations; controller context stays lean). If any critical exit condition needs script/code verification, spawn an **Implementer** (`agents/implementer.agent.md`) to build those verifier scripts before the loop. **Success criteria and exit conditions cannot be changed during the loop.**

**Spawn the exit-gater (before iterating).** Now that the exit conditions are finalized, spawn a **Devils Advocate** (`agents/devils-advocate.agent.md`, model = `subagent_model`) as the **exit-gater** and pass it the **exit-condition check info** — the success criteria → verifiable checks, the exit OR-set, and exactly how each is evaluated. This subagent **co-guards the exit gate** for the whole loop: the loop may exit **only when both the controller and the exit-gater agree** an exit condition is met (re-engage this same subagent at each exit check — steps d/e below; if your platform cannot persist it, re-spawn it with the same exit-condition check info). The `max_iterations` hard cap still stops the loop unconditionally.

For iteration N = 1, 2, …:
   a. **Pre-iteration exit check.** Evaluate the OR-set *before* acting (goal already met? any cap exhausted?). If a condition fires, **confirm the exit with the exit-gater** — stop only if both agree (the `max_iterations` cap stops unconditionally). Record the reason for any stop.
   b. **Act (delegated) — the controller never edits/fixes/runs the body itself.**
      - **Free-form:** spawn a body-worker (model = `subagent_model`; for code/command work, `agents/implementer.agent.md` / `agents/executor.agent.md`), passing the repo context + [final iteration plan] + the persisted [loop ledger] tail + this pass's action. It returns a **compact result** only: files changed (one-line diff, or "none"), progress-metric value (before → after), blocker, noteworthy.
      - **Dispatch:** spawn one depth-1 **sub-main agent** (model = `dispatch_main_model`) to run `workflow/<mode>/<family>.instructions.md` **as that family's main agent** (default the dispatched family to `mode: general` for this general loop unless [input 3] says otherwise), spawning that family's own subagents at the next level with model = `dispatch_subagent_model`, and to return only a **compact iteration summary**. **Platform-conditional:** on Claude Code nested subagents are supported; on Codex / VS Code Copilot (limited nesting) the controller runs the family inline — sequential, equivalent results.
      - The main agent passes the body-worker the exact [main agent model] per the Subagent Launch Contract — do not downgrade (unless a model header overrides).
   c. **Observe & measure.** Read the worker's compact result; re-run the verifiable check (capturing its own exit status) and compute the progress metric. **When the verifier is a test/script suite, run the write-guard first:** assert verifier/test files unchanged vs. baseline hash and collected-item count invariant; if either moved, **reject/revert this iteration** and record it as blocked.
   d. **Independent progress evaluation (anti-action-bias).** Consult the **exit-gater** (spawned at the start of Step 6), passing the [loop ledger] tail + the measured metric. It argues both sides — *"the goal is NOT actually met"* and *"the loop IS stuck / diverging"* — and returns a **CONTINUE / STOP-success / STOP-fail / ESCALATE** verdict with evidence. This verdict is the gater's vote at the exit gate (e).
   e. **Post-iteration exit check (exit gate — both must agree).** Re-evaluate the OR-set in priority order (goal-met? hard-blocker? budget/max-iter? no-progress? divergence?). If a condition fires, **the loop exits only if both the controller and the exit-gater (d) agree** to exit; on disagreement, continue and record it. The `max_iterations` cap (and an unrecoverable hard-blocker / ESCALATE) stops the loop unconditionally. Record which condition fired.
   f. **Goal-met confirmation gate.** If goal-met appears satisfied, before declaring success the main agent creates **Senior Engineer** (`agents/senior-engineer.agent.md`) + **QA Engineer** (`agents/qa-engineer.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** to **independently confirm** the goal is genuinely met: re-run the verifier, confirm no metric-gaming (write-guard intact), and check no regressions elsewhere. If they reject, the goal is NOT met — continue the loop.
   g. **Reflect & ledger.** Append a [loop ledger] entry for iteration N: action (free-form, or dispatched family+mode); code changes (files + one-line diff, or "none"); metric (`before → after`); observation + blocker; noteworthy (decisions, surprises, regressions, lessons); the exit-gater verdict; exit-check result. Carry one short lesson forward.
   h. **Continue or stop.** If no exit fired, start iteration N+1 with **fresh minimal context** (reload [final loop spec] + persisted [loop ledger] tail; discard verbose intermediate output). **The loop MUST terminate at the max-iterations cap regardless.**

7. **Post-loop review.** The main agent creates **Senior Engineer** (`agents/senior-engineer.agent.md`) + **QA Engineer** (`agents/qa-engineer.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, passing [final loop spec], the [loop ledger], and the net diff. Senior Engineer reviews the net code changes for correctness/regressions; QA Engineer validates the final state against the success criteria (re-running the pipeline if the user asked to run scripts). **Native review (platform-conditional):** if the loop edited source and the main agent is Claude Code (or another Claude agent with Claude Code skills), run the native review skills via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) (`/simplify` then `/code-review` on the net diff); otherwise review the net diff directly. Based on the reviews, perform **one** remediation pass (fix, then re-validate once); record any remaining gaps.

8. **Update overviews.** Read [final loop spec] + [loop ledger] + the review reports, then update codebase_overview.md and scripts_overview.md based on the actual net changes.

9. **Summarize.** Write the Loop Update block to update_logs.md:
```md
{=============================Loop Update===============================}
{Loop Name + Loop ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Goal / success criteria}
{Loop body (free-form action, or dispatched family + mode)}
{Exit conditions (the OR-set + caps that were in effect)}
{Iterations run + exit reason (which condition fired)}
{Code changes (net files touched + diff summary, or none)}
{Metric trajectory (baseline → final, total improvement)}
{Noteworthy (key decisions, surprises, regressions, lessons)}
{Review outcome (Senior + QA confirmation; gaps if any)}
{Achieved (yes/no, gaps if any)}
```

10. Write the Loop Update block to update_logs.md (do not add other content), then summarize the loop outcome (iterations run, exit reason, net code changes, metric trajectory, achieved y/n) in bullet points to chat.
