# Loop-Control Contract

Canonical rules for the loop meta-workflows: progress accounting, verifier calibration, the loop strategy, one-lever attribution, resource partitioning, negative-result memory, progressive scale-up, the durable goal record, and the opt-in native-goal bridge. Every `loop.instructions.md` variant (`general`, `fast`, `skill`) points here; this file is the single source — the workflow files deliberately do not restate it. Generic stay-engaged and wait rules (heartbeat, wake triggers, bounded deadlines, re-verification) live in `_lib/stay_active.md`; the loop-specific counters and checkpoint semantics live here.

---

## Progress Accounting

The [loop spec] declares the progress metric together with its **`direction`** — `minimize` (smaller is better, e.g. failing-test count) or `maximize` (larger is better, e.g. % coverage). Declare it explicitly; never infer it from the metric's name.

**Per-iteration record.** At every Observe & measure step, record:

- **`raw_score`** — the measured metric value for iteration N.
- **`total_delta = raw_score − baseline`** — cumulative movement since the loop started. **Trajectory reporting only** (post-loop summary, update_logs): it must never drive stagnation or divergence detection — after any early progress it stays non-zero indefinitely, so a stagnation check built on it can never fire.
- **`step_delta = raw_score − previous_committed`** — movement vs. the last accepted iteration (`previous_committed` = the `raw_score` of the most recent accepted iteration, or `baseline` before the first).
- **`best_delta = raw_score − best`** — movement vs. the best accepted value so far (`best` starts at `baseline`).

**Committed vs. accepted.** *Committed* is the crash-safety notion from a loop's iteration-commit rule: Observe & measure completed and the ledger entry written (in a loop variant without an explicit iteration-commit rule, an iteration counts as committed once its ledger entry is written). *Accepted* is the progress-accounting notion: committed **and** not rejected/reverted by the anti-gaming write-guard. **Only accepted iterations update `previous_committed` and `best`.** A gamed iteration is still committed (crash-safe, ledgered as blocked) but never accepted.

**Improvement (direction-aware, best-relative).** Iteration N *improved* iff it sets a new best: `raw_score < best` when `direction: minimize`, `raw_score > best` when `direction: maximize`. Matching the old best is not improvement. When the verifier has a nonzero noise floor (§Verifier Calibration), a new best counts only when it beats `best` by **more than the noise floor** — a sub-floor delta is not improvement. (This is standard early-stopping "patience" semantics — compare against best-so-far, not the previous step.)

**Exit predicates** (canonical — these replace any older `delta == 0` / "worse than prior" phrasing):

- **no-progress (stagnation)** — the last `no_progress_k` consecutive committed iterations produced **no new best**. Rejected/write-guard-blocked iterations count as no-progress; any improvement resets the counter to 0.
- **divergence** — `step_delta` strictly worse than zero, direction-aware (`> 0` when minimizing, `< 0` when maximizing), for 2 consecutive accepted iterations. A step counts toward divergence only when it is worse by **more than the noise floor** (§Verifier Calibration) — measurement noise must not fire the failure exit either.

**Persistence.** `baseline`, `best`, `previous_committed`, the stagnation/divergence counters, the exploration-mode state (§Exploration Mode), the noise floor (§Verifier Calibration), and the refuted list (§Negative-Result Memory) are part of the persisted loop state in the scratch file, alongside the [loop ledger] — never held only in context. Reloading a compact ledger tail must not lose them.

---

## Verifier Calibration (Noise Floor & Statistical Gates)

The loop's first measurement tests the measuring stick, not the policy.

- **Calibration (mandatory setup).** Before iteration 1, run the verifier **twice on the identical, unchanged baseline state** and record the disagreement between the two runs (score delta, count of flipped items) as the **noise floor**, persisted with the baseline (§Progress Accounting → Persistence). Two runs are a cheap tripwire, not a precise estimate: agreement does not prove a stochastic verifier is quiet, so treat the measured floor as a conservative lower bound; if the two runs disagree, escalate repetitions until the floor is characterized well enough to size the gates — or repair the verifier. *Scoped skip:* when the verifier is expected-deterministic **and** expensive to run, one baseline run may serve, with the skip and its rationale recorded; any flaky behavior observed later voids the floor-0 assumption and triggers calibration then.
- **Every gate must clear the floor.** Improvement (new best) and divergence steps count only when the delta exceeds the noise floor, direction-aware (§Progress Accounting) — noise may fire neither the success-side accounting nor the failure exits. A deterministic verifier has floor 0 and behaves exactly as before.
- **Statistical gates.** When the progress metric is a sample statistic over n items (a pass rate, a benchmark score), express goal-met / no-progress thresholds as **interval bounds resolvable at the available n** (e.g. "lower confidence bound ≥ X at n = …", Wilson-style; at very small n — below ≈5 — use an exact/conservative interval or raise n before gating), and size n from the **smallest effect worth detecting**. A raw-count gate the available n cannot resolve is not boolean-evaluable — repair it at spec time (raise n, widen the effect threshold, or change the verifier).
- **Verifier-first repair.** If the noise floor exceeds the smallest effect worth detecting, iterating on the policy is chasing noise: the loop's next iterations must improve the verifier (more samples/repetitions, deterministic seeds, finer scoring) before any policy iteration — these are legitimate committed iterations. The same diagnosis applies mid-loop: a no-progress streak whose iterations repeatedly show positive-but-sub-floor deltas is **resolution-limited, not search-limited** — verifier-resolution repair is then the first candidate probe idea for the §Exploration Mode episode, before any new policy direction.
- **Exit-gater.** The noise floor and any interval-typed gates are part of the exit-condition check info handed to the exit-gater; at each consultation it also argues *"the observed delta is within the noise floor"* when weighing goal-met or divergence.

---

## Exploration Mode (Fast Iteration on Stagnation)

When a loop produces no new best (§Progress Accounting's no-progress predicate) for `no_progress_k` (default **3**) consecutive iterations, switch from expensive full-scale passes to **fast, small-scale probes** — the no-progress exit is deferred while the episode runs; all other exits stay in force. Each probe iteration tests **one new idea** with the smallest decisive experiment (data subset, fewer steps, single component) instead of a full attempt, and its verdict — confirmed / refuted / inconclusive — must come from the probe's own captured check output, not self-assessment.

Ideas must be **genuinely new directions** — a different algorithm, data treatment, decomposition, or tool — not re-polishing of the stalled approach. Propose several candidates before probing and pick the one promising the most information for the least cost; pass every earlier probe's idea + verdict to each new probe so directions never repeat, and let a refuted or inconclusive verdict sharpen the next proposal rather than end it. Measure a probe only by its own cheap check, never the full verifier — that is what keeps iterations fast. Probes are committed iterations (`mode: explore` ledger entries, counting toward `max_iterations`) but never update `best` or the stagnation counters, and must not touch verifier/test files.

Once an idea is **confirmed**, return to normal mode and run it at full scale under the full verifier. A new best resolves the episode and normal looping continues; otherwise — or if `no_progress_k` probes confirm nothing — the deferred no-progress exit fires, with the probes' ideas + verdicts as stagnation evidence. Persist the episode state (probes used, verdicts, confirmed idea) with the rest of the loop state so a restart resumes mid-episode, and include it in any exit-gater consultation.

---

## Loop Strategy (`loop_strategy` header)

The optional `loop_strategy` request header selects how the loop's body work advances each iteration: `aggressive` | `fast_iteration` | `stable_advancing`. Absent or unrecognized values resolve to **`stable_advancing`** (the default). The controller copies the resolved strategy verbatim into the [loop spec] — it is a fixed input like the safety caps, never a field for planning subagents to design — and passes it, with its directives below, to every body-worker. For a dispatched sub-main agent the strategy is an **advisory note only**: it never overrides the dispatched family's own instructions, gates, or hard constraints.

**Invariant (all strategies).** Strategy modulates only *how the body searches* — never *how success is proven or when the loop may stop*. The success criteria, exit-condition OR-set, always-on caps (`max_iterations`, `no_progress_k`), anti-gaming write-guard, and controller/delegation split are strategy-invariant. In particular, `aggressive` changes what the body is allowed to build, never how success is verified: every iteration still runs the full verifier and write-guard before it can count as progress.

- **`aggressive`** — pursue the goal aggressively: ambitious, larger steps per iteration are welcome, and over-engineering and fine-grained optimization are explicitly allowed. This is a scoped license: it relaxes the simplicity-first bias **only within the files and scope of the current iteration's declared action** — it never licenses touching out-of-scope files or suspending Surgical Changes outside that action, and never exempts the iteration from verification (invariant above).
- **`fast_iteration`** — proof-of-concept focus: prove that a new idea or direction works before investing in it. Each iteration is a deliberately small step with more thinking and analysis (a fuller Reflect & ledger entry), and the body actively references papers, tech reports, and online resources to source new ideas and directions fast — kept cheap: 1–2 targeted searches per iteration, tied to the current sub-goal, summarized rather than transcribed. **Orthogonal to §Exploration Mode:** a `fast_iteration` iteration is still a normal committed iteration — full verifier, full progress accounting (`raw_score`, `best`, and the counters all update). Probe accounting belongs only to a stagnation-triggered exploration episode, which triggers and resolves identically under every strategy.
- **`stable_advancing`** *(default)* — solid, validated advancement: prefer the smallest change that demonstrably improves the metric, validate carefully (never skip or thin the verifier run), and prioritize code quality — clean, maintainable changes a reviewer would accept.

**Training time window (`fast_iteration` and `aggressive` only).** When an iteration's body work **sets up and runs model training** (trains or fine-tunes a model), and the resolved strategy is `fast_iteration` or `aggressive`, that training run is capped at a **maximum time window of 2h**. This bounds speculative training under the two exploratory strategies; it does not apply under `stable_advancing`. As with every strategy directive it modulates only *how the body searches* (invariant above): the body-worker enforces the window as a wall-clock ceiling on the training run itself (e.g. a time / max-steps budget passed to the training command), and a run that reaches the window is stopped and its partial result observed like any other iteration — the cap never weakens the success criteria, exit conditions, safety caps, or write-guard. It is the binding ceiling for a training run under these strategies even when `_lib/stay_active.md` Rule 4's `2 × estimate` run limit would be larger. Where an expensive method *starts*, and how it earns scale across iterations, is governed strategy-independently by §Progressive Scale-Up; the window here caps only a training run's duration under these two strategies.

  **Doubling on proven effectiveness.** 2h is the *starting* window. Each time a training method is **approved effective by the training run** — that run produced a **confirmed improvement** under the loop's normal evidence rules (a new best via the verifier / §Progress Accounting, captured from real tool output per §Durable Goal Record's Evidence — never self-assessment, and never a write-guard-blocked, refuted, or unaccepted run) — **double that method's window** for its next training run (2h → 4h → 8h → …). Doubling is cumulative and per method: a method that has not yet proven effective stays at 2h. Persist each method's current window with the rest of the loop state (§Progress Accounting → Persistence) so a cold restart resumes at the earned cap rather than resetting to 2h.

---

## One Lever per Iteration (Attribution)

An unattributed win costs more than a slow loop — every later iteration inherits the ambiguity.

- Each iteration's declared action moves **one lever** (one independent change axis) whenever feasible. This deliberately trades sample-efficiency for attribution — the right trade when iterations are expensive or noisy. When levers are individually cheap, a pass may move several **only if** its report names each lever and keeps **per-lever artifacts** (configs, diffs, intermediate outputs, per-source results) that leave a one-step ablation possible.
- **Never declare a direction, winner, or "what worked" from an unattributed multi-lever result** — finish the attribution runs first, even under budget pressure. If the loop stops before attribution, the ledger and final summary record the result as *unattributed*, never as a validated direction.
- **Strategy interaction.** `aggressive`'s license for ambitious, larger steps (§Loop Strategy) modulates a lever's *size*, never the *number* of unattributed levers; the per-lever artifact rule binds under every strategy. For a `dispatch:` body, the dispatched family's internal edits count as one lever — the iteration-level action it was asked to perform.

---

## Resource Partitioning (Concurrent Sessions)

Parallel sessions without resource partitioning are net-negative: cross-session kills, repointed defaults, and device contention corrupt runs.

- The [loop spec] **declares the exclusive resources** the body work will use — working tree/branch, devices (e.g. GPUs), ports, services, databases, and shared mutable defaults (env vars, symlinks, "current" pointers) — and this declaration travels in every [work order].
- **One loop per resource set.** Concurrent loops or agent sessions must be **partitioned** (disjoint resources via lock files or explicit assignment — e.g. a worktree per session, a pinned device set) or **serialized**.
- **Positive attribution before any kill/claim/repoint.** Before terminating a process, claiming a device, or re-pointing a shared default, attribute it to *this* loop using the resource's own tooling (e.g. PID-level attribution from the device's own process listing). Anything that cannot be positively attributed to this loop is **never** killed, claimed, or reconfigured — record the contention as a blocker instead.

---

## Negative-Result Memory

Negative results are the loop's memory — without them each loop re-buys the same lessons.

- Every refuted attempt — a worse or sub-floor metric, a write-guard block, a refuted probe, a reverted change — is ledgered **as a refuted hypothesis**: the idea tried, the measured numbers (with the noise floor for context), the evidence, and the **artifact paths** needed to re-examine it. The accumulated **refuted list** is part of the persisted loop state (§Progress Accounting → Persistence).
- **Re-read before acting.** Before choosing each iteration's action, the controller re-reads the ledger tail + refuted list; a refuted direction is never re-proposed unless the proposal names the **new evidence** that distinguishes it from the refuted attempt.
- **Cross-run memory.** The post-loop Loop Update block records the refuted hypotheses (its `{Refuted …}` line) so they persist in `update_logs.md` beyond this run; loop spec design reads prior Loop Update entries — including `repo_info/update_logs_all.md` when the goal continues a campaign older than the live file — before proposing levers, so refuted directions are not re-bought across loops.

---

## Progressive Scale-Up (Expensive Actions)

Fast looping and iteration first; approach the goal's full scale only as evidence accumulates.

- When a body action has a large per-run cost (a long training run, a whole-corpus job, an expensive build or benchmark), its **first run uses the smallest decisive scale** — a short step, a subset, a reduced configuration — validated by the verifier like any iteration. Only a **validated** small run earns a larger scale next round; grow carefully (e.g. doubling) on confirmed improvement, and drop back to the last validated scale on refutation or a failed run.
- This pilot-first discipline applies **under every strategy** — it decides where an expensive method *starts*, and is orthogonal to §Loop Strategy's training-time window, which caps how long a training run may *last* under `fast_iteration`/`aggressive` (and continues not to apply under `stable_advancing`). When both apply, the smaller resulting run wins.

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
