# Loop-Control Contract

Canonical rules for the loop meta-workflows: progress accounting, the durable goal record, and the opt-in native-goal bridge. Every `loop.instructions.md` variant (`general`, `fast`, `skill`) points here; this file is the single source — the workflow files deliberately do not restate it. Generic stay-engaged and wait rules (heartbeat, wake triggers, bounded deadlines, re-verification) live in `_lib/stay_active.md`; the loop-specific counters and checkpoint semantics live here.

---

## Progress Accounting

The [loop spec] declares the progress metric together with its **`direction`** — `minimize` (smaller is better, e.g. failing-test count) or `maximize` (larger is better, e.g. % coverage). Declare it explicitly; never infer it from the metric's name.

**Per-iteration record.** At every Observe & measure step, record:

- **`raw_score`** — the measured metric value for iteration N.
- **`total_delta = raw_score − baseline`** — cumulative movement since the loop started. **Trajectory reporting only** (post-loop summary, update_logs): it must never drive stagnation or divergence detection — after any early progress it stays non-zero indefinitely, so a stagnation check built on it can never fire.
- **`step_delta = raw_score − previous_committed`** — movement vs. the last accepted iteration (`previous_committed` = the `raw_score` of the most recent accepted iteration, or `baseline` before the first).
- **`best_delta = raw_score − best`** — movement vs. the best accepted value so far (`best` starts at `baseline`).

**Committed vs. accepted.** *Committed* is the crash-safety notion from a loop's iteration-commit rule: Observe & measure completed and the ledger entry written (in a loop variant without an explicit iteration-commit rule, an iteration counts as committed once its ledger entry is written). *Accepted* is the progress-accounting notion: committed **and** not rejected/reverted by the anti-gaming write-guard. **Only accepted iterations update `previous_committed` and `best`.** A gamed iteration is still committed (crash-safe, ledgered as blocked) but never accepted.

**Improvement (direction-aware, best-relative).** Iteration N *improved* iff it sets a new best: `raw_score < best` when `direction: minimize`, `raw_score > best` when `direction: maximize`. Matching the old best is not improvement. (This is standard early-stopping "patience" semantics — compare against best-so-far, not the previous step.)

**Exit predicates** (canonical — these replace any older `delta == 0` / "worse than prior" phrasing):

- **no-progress (stagnation)** — the last `no_progress_k` consecutive committed iterations produced **no new best**. Rejected/write-guard-blocked iterations count as no-progress; any improvement resets the counter to 0.
- **divergence** — `step_delta` strictly worse than zero, direction-aware (`> 0` when minimizing, `< 0` when maximizing), for 2 consecutive accepted iterations.

**Persistence.** `baseline`, `best`, `previous_committed`, the stagnation/divergence counters, and the exploration-mode state (§Exploration Mode) are part of the persisted loop state in the scratch file, alongside the [loop ledger] — never held only in context. Reloading a compact ledger tail must not lose them.

---

## Exploration Mode (Fast Iteration on Stagnation)

A loop that has stalled for several rounds is rarely blocked because no solution exists — it is stuck because the current approach cannot reach the goal in one big attempt. Exploration mode switches a stalled loop from expensive full-scale passes to cheap, fast probes of new ideas, then scales the first confirmed idea back up — never crediting a small-scale result until it is confirmed at full scale.

**Target value and meaningful improvement.** When the goal names a quantitative target for the progress metric, the [loop spec] records it as the metric's **target value** (the value at which goal-met fires); the **required total improvement** is `|target value − baseline|`. An iteration's improvement is **meaningful** only when it sets a new best that moves `best` by at least **10%** of the required total improvement. The 10% figure is a tunable heuristic default (a relative `min_delta`, not an established constant); a spec may override it with a one-line rationale. When no numeric target value exists, a meaningful improvement is any new best (§Progress Accounting's improvement, unchanged).

**Trigger (always on, every loop variant).** The controller tracks a **meaningful-stagnation counter**: consecutive committed iterations without meaningful improvement, reset to 0 only by a meaningful new best. It is distinct from §Progress Accounting's stagnation counter, whose any-new-best reset rule is unchanged — a small non-meaningful best resets only the latter. When the meaningful-stagnation counter reaches `no_progress_k` (default **3**), the controller MUST enter exploration mode at that exit check — before evaluating the no-progress exit. Entering opens one **exploration episode** and **defers the no-progress exit until the episode resolves** (at both pre- and post-iteration checks). Every other exit stays fully in force: `max_iterations` (unconditional), hard blocker, budget, divergence, human checkpoint.

**Probe iterations.** While the episode is open, each Act pass delegates a **probe** instead of a full-scale attempt: the smallest decisive experiment that validates or falsifies **one new idea** at reduced scale — a data/test subset, fewer steps/epochs, a single component, a proof-of-concept spike — never a big job (no training from scratch, no full re-run). Prefer genuinely new ideas over re-polishing the approach that stalled; pass earlier probes' ideas + verdicts to each new probe so ideas are not repeated. A probe returns a compact result whose verdict — **confirmed / refuted / inconclusive** — must be demonstrable from the captured tool output of the probe's own small-scale check (exit status / measured value); an unevidenced "it works" is model self-assessment, not a verdict. At Observe & measure the controller re-runs (or reads the captured output of) that cheap probe check, **not** the full verifier — this is what makes a probe iteration fast.

**Probe accounting.** A probe is a **committed** iteration — it counts toward `max_iterations` and writes a ledger entry marked `mode: explore` (idea, verdict, evidence; its `metric` field carries the probe's own cheap-check reading, or `n/a` — never a `raw_score`) — but it is never **accepted** in §Progress Accounting's sense: it makes no full-scale measurement, records no `raw_score`, and never updates `best` or `previous_committed`; having no `step_delta`, it can never feed the divergence exit (which is evaluated only across accepted full-scale iterations). Both stagnation counters are frozen while the episode is open. **Write-guard:** a probe must not edit verifier/test files — the baseline-hash assertion still runs every iteration; the collected-item-count invariant applies only to full verifier runs, so a probe's deliberately reduced-scope run is never treated as a full-verifier measurement (nor as gaming).

**Scale-up and episode resolution.** The first **confirmed** probe closes the probing phase: the next iteration returns to normal mode and runs the confirmed idea **at full scale** — a normal full-scale iteration under all caps, with the full Observe & measure (full verifier + complete write-guard).
- Scale-up sets a meaningful new best → the episode resolves successfully; both stagnation counters reset; normal looping continues.
- Scale-up does not → the deferred no-progress exit fires at that iteration's exit check — the failed episode is itself sufficient stagnation evidence, whatever the plain stagnation counter reads (an episode carries exactly one deferral).
- Probe budget exhausted — at most **`no_progress_k` probes** per episode — with no confirmed idea → the deferred no-progress exit fires, with the probes' ideas + verdicts as the ledger's stagnation evidence.

A new episode may open only after an intervening meaningful new best has reset the meaningful-stagnation counter. **Near-cap precedence:** where a variant defines near-cap wind-down, wind-down wins over both a scale-up run and a fresh probe — a confirmed idea whose scale-up would land on the last allowed pass is documented in the wind-down handoff as the recommended next step, not launched.

**Exit-gater briefing (variants with an exit-gater).** This section's trigger, deferral, and episode-resolution rules are part of the exit-condition check info given to the exit-gater at spawn, and every later consultation includes the current exploration state (episode open/closed, probes used, verdicts) — the gater must never judge stuck/diverging off pre-exploration rules.

**Time budgets (`_lib/stay_active.md` Rule 4).** Estimate per scale class: a probe's budget from probe-scale precedents (or the default), and the scale-up run's from the pre-exploration full-scale ledger entries — never from the immediately preceding probe entries.

**Persistence.** The exploration state — the meaningful-stagnation counter, episode open/closed, probes used, ideas tried with verdicts + evidence pointers, confirmed idea (if any), pending scale-up flag — is part of the persisted progress-accounting state (§Progress Accounting → Persistence) and of the [re-entry prompt] block (§Re-Entry Prompt), so a cold-restarted controller resumes mid-episode instead of silently dropping back to normal mode.

---

## Durable Goal Record

The persisted loop state (scratch file: [loop spec] + [loop ledger] + baseline + progress-accounting state) is the loop's **durable goal record**. It exists on every platform and requires no native goal feature. Its fields:

1. **Objective (immutable)** — the goal, success criteria, and exit conditions, frozen once the approval gate passes (this is the existing "success criteria and exit conditions cannot be changed during the loop" rule).
2. **Exclusions** — an explicit out-of-scope list: what the loop must not touch or attempt (at minimum the write-guard's protected verifier/test files).
3. **Stopping condition (verifiable)** — the exit OR-set plus the always-on caps, each a boolean predicate evaluable from real tool output.
4. **Checkpoints** — one per committed iteration: the ledger entry plus the updated progress-accounting state.
5. **Evidence** — the verifier's own fresh exit status/output captured at Observe & measure. Belief, plausibility, or a stale earlier run is never evidence.
6. **Remaining work** — what is still open, carried in the ledger entry and the wind-down handoff.
7. **Blockers** — recorded as they occur; an unrecoverable one is a stop, not a detour.

A budget stop (tokens / time / `max_iterations`) is a **stop, never goal-met**: reaching a cap with the verifier unproven records the goal as not achieved, with remaining work and blockers.

---

## Re-Entry Prompt (stay-in-loop, cold restart)

The scratch file must carry a self-sufficient **[re-entry prompt]** block — the slice of the durable goal record a fresh controller with zero memory needs to resume mid-loop: the finalized [loop spec], the baseline (metric value, verifier/test-file hashes, collected-item count), the [loop ledger] tail, the current iteration number, the exploration-mode state when an episode is open (§Exploration Mode), and the **pending action** (re-run iteration N's uncommitted Act, or start N+1) — plus an explicit **resume-vs-replay marker** distinguishing:

- **resume** — a fresh controller reloads this block, re-creates any loop-scoped subagents its variant requires (e.g. the exit-gater, with the same exit-condition check info), and continues at the pending action per the variant's iteration-commit / resume rule. It never re-runs the pre-loop spec-design steps.
- **replay** — re-run the original request from its first step, redesigning the spec (e.g. the general loop's analyst panel). Correct only when no valid re-entry block exists.

The platform does not carry this distinction for you — a re-fed prompt alone conflates the two — so the marker lives in the scratch file. The split mirrors native `/goal`'s documented resume behavior: the condition text (here: the spec) is the durable artifact that carries over, while turn counters and timers (here: iteration state) reset. Refresh the block's iteration number and pending action at every Reflect & ledger step. **Any exit condition recorded in the ledger invalidates the marker — the loop is over; a later cold start must not resume it.** (Marker invalidation is also what disarms a stay-active hard-enforcement guard, per `_lib/stay_active.md`.)

---

## Native Goal Bridge (opt-in, capability-aware)

Some platforms expose a native durable-goal or persistent-task facility (e.g. Codex `/goal`, a platform task list). Mirroring the durable goal record into such a facility is **opt-in** — do it only when the user asked for it or the platform's own workflow requires it — and governed by these hard rules:

1. **Never replace or overwrite an existing native goal automatically.** If one is already active, leave it alone, keep the internal record, and surface the coexistence to the user instead of merging.
2. **Never invent a token budget.** Carry a budget into the native goal only when the user or platform actually set one; otherwise leave it unset. Budget exhaustion is a stop, never completion.
3. **Mark the native goal complete only on fresh verifier evidence** — a verifier run executed in the current session whose captured exit status satisfies the goal-met predicate. Never from memory, belief, or a prior session's result.
4. **Fall back to the internal record on unsupported platforms.** The durable goal record is always authoritative; a native mirror is a view of it, and on any conflict the internal checkpoint state wins.
