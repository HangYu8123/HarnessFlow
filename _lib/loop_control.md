# Loop-Control Contract

Canonical rules for the loop meta-workflows: progress accounting, the loop strategy, the durable goal record, and the opt-in native-goal bridge. Every `loop.instructions.md` variant (`general`, `fast`, `skill`) points here; this file is the single source — the workflow files deliberately do not restate it. Generic stay-engaged and wait rules (heartbeat, wake triggers, bounded deadlines, re-verification) live in `_lib/stay_active.md`; the loop-specific counters and checkpoint semantics live here.

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

When a loop makes no meaningful progress for `no_progress_k` (default **3**) consecutive iterations, switch from expensive full-scale passes to **fast, small-scale probes** — the no-progress exit is deferred while the episode runs; all other exits stay in force. Each probe iteration tests **one new idea** with the smallest decisive experiment (data subset, fewer steps, single component) instead of a full attempt, and its verdict — confirmed / refuted / inconclusive — must come from the probe's own captured check output, not self-assessment.

Ideas must be **genuinely new directions** — a different algorithm, data treatment, decomposition, or tool — not re-polishing of the stalled approach. Propose several candidates before probing and pick the one promising the most information for the least cost; pass every earlier probe's idea + verdict to each new probe so directions never repeat, and let a refuted or inconclusive verdict sharpen the next proposal rather than end it. Measure a probe only by its own cheap check, never the full verifier — that is what keeps iterations fast. Probes are committed iterations (`mode: explore` ledger entries, counting toward `max_iterations`) but never update `best` or the stagnation counters, and must not touch verifier/test files.

Once an idea is **confirmed**, return to normal mode and run it at full scale under the full verifier. A meaningful new best resolves the episode and normal looping continues; otherwise — or if `no_progress_k` probes confirm nothing — the deferred no-progress exit fires, with the probes' ideas + verdicts as stagnation evidence. Persist the episode state (probes used, verdicts, confirmed idea) with the rest of the loop state so a restart resumes mid-episode, and include it in any exit-gater consultation.

---

## Loop Strategy (`loop_strategy` header)

The optional `loop_strategy` request header selects how the loop's body work advances each iteration: `aggressive` | `fast_iteration` | `stable_advancing`. Absent or unrecognized values resolve to **`stable_advancing`** (the default). The controller copies the resolved strategy verbatim into the [loop spec] — it is a fixed input like the safety caps, never a field for planning subagents to design — and passes it, with its directives below, to every body-worker. For a dispatched sub-main agent the strategy is an **advisory note only**: it never overrides the dispatched family's own instructions, gates, or hard constraints.

**Invariant (all strategies).** Strategy modulates only *how the body searches* — never *how success is proven or when the loop may stop*. The success criteria, exit-condition OR-set, always-on caps (`max_iterations`, `no_progress_k`), anti-gaming write-guard, and controller/delegation split are strategy-invariant. In particular, `aggressive` changes what the body is allowed to build, never how success is verified: every iteration still runs the full verifier and write-guard before it can count as progress.

- **`aggressive`** — pursue the goal aggressively: ambitious, larger steps per iteration are welcome, and over-engineering and fine-grained optimization are explicitly allowed. This is a scoped license: it relaxes the simplicity-first bias **only within the files and scope of the current iteration's declared action** — it never licenses touching out-of-scope files or suspending Surgical Changes outside that action, and never exempts the iteration from verification (invariant above).
- **`fast_iteration`** — proof-of-concept focus: prove that a new idea or direction works before investing in it. Each iteration is a deliberately small step with more thinking and analysis (a fuller Reflect & ledger entry), and the body actively references papers, tech reports, and online resources to source new ideas and directions fast — kept cheap: 1–2 targeted searches per iteration, tied to the current sub-goal, summarized rather than transcribed. **Orthogonal to §Exploration Mode:** a `fast_iteration` iteration is still a normal committed iteration — full verifier, full progress accounting (`raw_score`, `best`, and the counters all update). Probe accounting belongs only to a stagnation-triggered exploration episode, which triggers and resolves identically under every strategy.
- **`stable_advancing`** *(default)* — solid, validated advancement: prefer the smallest change that demonstrably improves the metric, validate carefully (never skip or thin the verifier run), and prioritize code quality — clean, maintainable changes a reviewer would accept.

**Training time window (`fast_iteration` and `aggressive` only).** When an iteration's body work **sets up and runs model training** (trains or fine-tunes a model), and the resolved strategy is `fast_iteration` or `aggressive`, that training run is capped at a **maximum time window of 2h**. This bounds speculative training under the two exploratory strategies; it does not apply under `stable_advancing`. As with every strategy directive it modulates only *how the body searches* (invariant above): the body-worker enforces the window as a wall-clock ceiling on the training run itself (e.g. a time / max-steps budget passed to the training command), and a run that reaches the window is stopped and its partial result observed like any other iteration — the cap never weakens the success criteria, exit conditions, safety caps, or write-guard. It is the binding ceiling for a training run under these strategies even when `_lib/stay_active.md` Rule 4's `2 × estimate` run limit would be larger.

  **Doubling on proven effectiveness.** 2h is the *starting* window. Each time a training method is **approved effective by the training run** — that run produced a **confirmed improvement** under the loop's normal evidence rules (a new best via the verifier / §Progress Accounting, captured from real tool output per §Durable Goal Record's Evidence — never self-assessment, and never a write-guard-blocked, refuted, or unaccepted run) — **double that method's window** for its next training run (2h → 4h → 8h → …). Doubling is cumulative and per method: a method that has not yet proven effective stays at 2h. Persist each method's current window with the rest of the loop state (§Progress Accounting → Persistence) so a cold restart resumes at the earned cap rather than resetting to 2h.

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
