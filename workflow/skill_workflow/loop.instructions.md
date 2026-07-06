---
name: 'Skill-Based Loop'
description: 'Unified skill-backed (skill mode) loop meta-workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast loop, but the iteration-plan, challenge, research, and body instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback. Loop control (spec parsing, exit-condition evaluation, write-guard, ledger) stays inline — no qualifying skill exists.'
---
# Loop Until Goal or Exit Condition

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

> **Loop meta-workflow.** The main agent is a **controller**, not a doer. It parses the spec; then for each iteration it **observes** the delegated result, **checks** the exit conditions, and **reflects & ledgers** — it never performs the body work itself. The *act* is **always delegated**. Exit conditions form an **OR-set** ("stop when ANY fires") with **always-on safety caps**, so the loop can never run away.

> **Skill-backed variant (skill mode).** Selected step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue — never block on a missing external skill. **Loop control** (spec parsing, the write-guard, exit-condition evaluation, the ledger) has **no qualifying ≥1000★ skill and stays inline** in all modes.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
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
  - (dispatch only) workflow/<mode>/<family>.instructions.md for the dispatched family
-->

[inputs]:
- input 1: **[goal]** — *required*; a single concrete sentence (with a specific term/quantity, not a vague "improve").
- input 2: **[success criteria + exit conditions]** — *required*; the verifiable check(s) that define "done", plus any extra exit conditions (budget / human checkpoint). The `max_iterations` / `no_progress_k` caps come from the header (defaults below).
- input 3: **[loop body]** — *optional*; a free-form action to perform each iteration, **or** `dispatch: family=<code|debug|exec|refactor|query|correctness_check|pr|initialize> mode=<fast|general|skill>`. **If omitted, the controller decides the body from [goal] + [success criteria]** (see Step 1).
- input 4: **[starting state]** — *optional*; files / target repo / baseline notes. **Defaults to the current repo/workspace state** if omitted.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved via Pack Path Resolution).

**Model headers** (read from the request header; governed by [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Launch Contract — default `inherit`, never downgrade):
- `subagent_model` — model for the loop's own workers (the body-worker, Devils Advocate, Online Researcher).
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

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering & Loop-Spec Parsing
*(Loop control — inline; no qualifying skill.)*
Read [key md files]. If important files are specified in [inputs], read them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, condense the understanding into a **[repo context digest]** to pass inline to subagents; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.

**Parse [inputs] into a draft [loop spec]** (decompose, then formalize so each field is machine-checkable):
- **goal** — the single-sentence target from [input 1].
- **success criteria → verifiable checks** — each criterion as an **objective, tool-based check**; never model self-assessment alone. **Capture the verifier's own exit status** (run it directly, not through a pipe), pin the pass to **`exit == 0`**, and **treat a vacuous result as failure** (empty / all-skipped / no items collected, e.g. `pytest` exit **5**).
- **baseline** — the starting state ([input 4], or current repo/workspace state by default) + the progress-metric baseline before iteration 1; when the verifier is a test/script suite, also a **hash of each verifier/test file** and the **collected-item count**.
- **progress metric** — one cheap proxy tied to ≥1 success criterion, hard to game. **Anti-gaming write-guard (MANDATORY for test/script verifiers):** the body may edit **only non-verifier files**; the controller asserts verifier/test files unchanged vs. baseline hash + collected-item count invariant each iteration (reject/revert otherwise).
- **exit conditions** — an OR-set of **concrete boolean predicates** in **priority order**: (1) goal-met = all checks pass; (2) hard blocker = verifier error status (e.g. `pytest` 2/3/4/5) or unrecoverable worker blocker → escalate; (3) budget / `max_iterations`; (4) no-progress = metric `delta == 0` for `no_progress_k` iterations; (5) divergence = metric worse than prior for 2 consecutive iterations; plus optional human checkpoint. Drop any predicate you cannot instantiate.
- **loop body** — use [input 3] if given; otherwise the controller decides (classify intent → `dispatch: family=… mode=…` when a family fits, else a free-form action) with a one-line rationale.

**Local Skill Discovery (before any plan drafting):** per `_lib/local_skill_discovery.md`, scan `skills/index.md`; on a confirmed match read its `SKILL.md`. Record [local skills] (or "none relevant") and fold it into the repo context.

### Step 2 - Iteration Plan & Spec Validation
**Skill (replaces the iteration-plan drafting):** Produce the **[iteration plan]** by following **`writing-plans`** (`obra/superpowers:skills/writing-plans/SKILL.md`, 229,665★ verified 2026-06-16) — feed it the [loop spec] as the spec; it returns a dependency-ordered, verification-per-step plan covering what one pass does, what the worker must return, the progress metric, and exactly how each exit predicate is evaluated from the worker's compact result. When intent is ambiguous, first run the companion **`brainstorming`** (`obra/superpowers:skills/brainstorming/SKILL.md`) — but defer any approval to the opt-in gate (`_lib/approval_gate.md`), not brainstorming's own gate.
**Fallback if the skill is unavailable:** the main agent drafts the [iteration plan] inline (as in the fast loop).

**The draft [loop spec] is validated here by the two subagents below — each runs the pre-flight guardrail checklist:** (a) goal concrete; (b) every success criterion has an objective verifier; (c) baseline captured; (d) progress metric hard to game; (e) every exit predicate boolean-evaluable; (f) the loop body fits the goal.

**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** This is the only pre-loop step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | **Skill-backed:** run the guardrail challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`, 9,938★ verified 2026-06-16) — a structured devil's-advocate / pre-mortem over the repo context (per §Context Passing) + [loop spec] + [iteration plan]. Run the guardrail checklist adversarially: what could make the loop run forever or stop too early; whether each success criterion is verifiable; whether the progress metric is cheap and **un-game-able**; whether the caps and baseline are sane; whether the body fits. Flag destructive/irreversible actions needing a human checkpoint. Return [spec critique]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate guardrail challenge as written in the fast loop. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | **Skill-backed:** validate the verification methods by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`, 28,103★ verified 2026-06-16) — plan/search/read/synthesize a **cited** check on whether the chosen checks are the standard, robust way to verify these success criteria, known pitfalls, and stronger verifiers (and references for the body action when needed). The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof. Return [research + verifier validation]. **Fallback if `deep-research` is unavailable:** perform the Online Researcher verifier-validation as written in the fast loop. |

The main agent folds [spec critique] + [research + verifier validation] into a finalized **[loop spec]** + **[iteration plan]**. On a failed guardrail: in **plan-only** mode surface it; in **autonomous** mode (default) record a one-line assumption/fix and proceed (per `_lib/approval_gate.md`).

### Step 3 - Approval Gate
Print the finalized [loop spec] + [iteration plan] (goal, body, exit OR-set, caps, progress metric, write-guard). **Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed to Step 4 unless the user asked for no changes / a plan-only review (then stop here).

### Step 4 - Run the Loop
*(Loop control — inline; no qualifying skill.)*
The main agent is the **controller**; the act is **always delegated**. Initialize the **[loop ledger]** and **persist it — plus the baseline (metric, verifier/test-file hashes, collected-item count) — to a scratch file** (state survives iterations; controller context stays lean). **Success criteria and exit conditions cannot be changed during the loop.** If a critical exit condition needs script/code verification, spawn a subagent to build those verifier scripts first. For iteration N = 1, 2, …:

1. **Pre-iteration exit check.** Evaluate the OR-set *before* acting. If any condition fires, stop and record the reason.
2. **Act (delegated) — the controller never edits/fixes/runs the body itself.**
   - **Free-form (skill-backed):** spawn a body-worker (model = `subagent_model`) that performs the action and returns a **compact result** (files changed + one-line diff, progress-metric value before → after, blocker, noteworthy). When the action is **code/feature** work, the worker follows **`executing-plans`** (`obra/superpowers:skills/executing-plans/SKILL.md`, 229,665★) reinforced by **`test-driven-development`** (`obra/superpowers:skills/test-driven-development/SKILL.md`) for the red→green→refactor loop; when the action is **debugging**, it follows **`systematic-debugging`** (`obra/superpowers:skills/systematic-debugging/SKILL.md`) — reproduce → isolate → root-cause before fixing. **Fallback if the skills are unavailable:** the body-worker performs the action directly (as in the fast loop), still returning only the compact result.
   - **Dispatch:** spawn one depth-1 **sub-main agent** (model = `dispatch_main_model`) to run `workflow/<mode>/<family>.instructions.md` **as that family's main agent** (prefer `mode: skill` for the dispatched family unless [input 3] says otherwise), spawning that family's subagents at the next level with model = `dispatch_subagent_model`, returning only a **compact iteration summary**. **Platform-conditional:** on Claude Code nested subagents are supported; on Codex / VS Code Copilot (limited nesting) the controller runs the family inline — sequential, equivalent.
3. **Observe & measure.** Read the worker's compact result; re-run the verifiable check (capturing its own exit status) and compute the progress metric. **When the verifier is a test/script suite, run the write-guard first:** assert verifier/test files unchanged vs. baseline hash and collected-item count invariant; if either moved, **reject/revert this iteration** and record it as blocked.
4. **Post-iteration exit check.** Re-evaluate the OR-set in priority order (goal-met? hard-blocker? budget/max-iter? no-progress? divergence?). Record which condition fired.
5. **Reflect & ledger.** Append a [loop ledger] entry for iteration N: action (free-form, or dispatched family+mode); code changes (files + one-line diff, or "none"); metric (`before → after`); observation + blocker; noteworthy; exit-check result. Carry one short lesson forward.
6. **Continue or stop.** If no exit fired, start iteration N+1 with **fresh minimal context** (reload [loop spec] + persisted [loop ledger] tail; discard verbose intermediate output). **The loop MUST terminate at the max-iterations cap regardless.**

### Step 5 - Post-loop Review and Validation
1. Summarize the outcome from the [loop ledger]: goal met (yes/no), which exit condition fired, final state vs success criteria, and — aggregated across iterations — the **net code changes**, the **metric trajectory** (baseline → final + total improvement), and the collected **noteworthy items**.
2. **Native review (platform-conditional):**
   - **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** if any iteration edited source files, run the native review skills **once** via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — that skill is the only caller: it runs `/simplify`, then — **only when the request's `code_review` header is `true` (default `false` → skip `/code-review`)** — `/code-review` on the net diff (recorded as [simplify], and [code-review] when `/code-review` runs). Do not run `/simplify` or `/code-review` yourself in addition to the skill. Skip when the loop only ran commands without editing source, or when the native skills are unavailable.
   - **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the native skills; when iterations edited source, review the net diff directly.
3. **Skill-backed self-challenge:** run **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) over the loop outcome — claim the goal is NOT genuinely met (gamed metric? regressions? vacuous pass?), explain why, then reconcile. **Fallback if unavailable:** the main agent performs this self-challenge inline.
4. If the outcome did not meet the goal, summarize the gaps and lessons learned in bullet points to chat (no more than 3 sentences), then go to Step 6. If it met the goal, go to Step 6.

### Step 6 - Documentation and Summary
1. If the loop changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
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
{summary from Step 5 (gaps if any)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize the loop outcome (iterations run, exit reason, net code changes, metric trajectory, achieved y/n) in bullet points to chat.
