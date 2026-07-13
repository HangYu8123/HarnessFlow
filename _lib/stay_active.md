# Stay-Active Rule

These rules apply to every **loop** and **exec** workflow, in every mode (`general`, `fast`, `skill`), on every platform. They govern the **main agent / controller** and every subagent it spawns.

---

## Rule 1 — Do not stand aside early. Stay active.

The agent stays **actively engaged from the first step to the terminal step**. Delegating work, starting a command, or finishing one iteration is **never** a reason to go quiet.

**Never:**
- End the turn, hand back to the user, or declare the workflow finished while a subagent, background command, or dispatched sub-main agent is still in flight.
- Idle, "stand by", or wait passively for something to happen.
- Ask the user to report back when a build/test/CI/subagent finishes, or to "tell me when it's done".
- Treat a delegation as the end of a step — the step ends when its **result has been observed and recorded**, not when the work was handed off.

**Always:**
- After every delegation, either do the next non-blocking work (observe, measure, verify, ledger) or actively watch the in-flight work through to its result.
- Drive the loop / execution forward on your own initiative until a terminal condition is reached.

**The turn may be yielded only when one of these is true:**
1. A terminal **exit condition** fired (loop), or every step completed (exec).
2. A **hard blocker / escalation** was recorded and genuinely requires a human.
3. The **approval gate** is in Mode 1 (plan-only) per `_lib/approval_gate.md`.
4. A **human checkpoint** declared in the spec was reached.

Anything else — including "the subagent is running" or "the tests are still going" — is **not** a valid reason to stop.

---

## Rule 2 — Every wait arms two wake triggers, through two different mechanisms. Wake safety is per-wait.

Sometimes a step genuinely must wait: a long build, a background process, a remote CI run, an external event. A wait is allowed **only** when the agent is guaranteed to wake up again. A single wake path is a single point of failure — if it never fires, the agent sleeps forever.

**A wait may begin only when durable state was just reconciled, the awaited condition is still false, and one live event trigger plus one live bounded time trigger are armed. This holds per-wait, not per-task: a trigger that already fired is consumed and cannot protect a later wait.**

- **Trigger A — event-driven.** Fires when the awaited thing actually changes state. *(Claude Code: a `Monitor` watch on the condition, or the completion notification of a background `Bash` task / subagent. Codex · VS Code Copilot: a blocking foreground call with its own hard timeout.)*
- **Trigger B — time-driven fallback.** Fires on a timer regardless of whether the event ever arrives. *(Claude Code: `ScheduleWakeup`, a `CronCreate` tick, or a bounded re-check loop. Codex · VS Code Copilot: a bounded polling loop that re-reads real state on an interval.)*

**Requirements:**
1. **Two different mechanisms — not one mechanism twice.** Two timers are one mechanism; an event watch plus a timer are two.
2. **Follow the wait sequence: reconcile → arm both → reconcile again → wait.** Arm both before the wait begins, never after — an unarmed fallback cannot rescue a wait already in progress. The second reconciliation closes the race where the work completes between the first check and trigger registration: if it now shows the condition true, consume the triggers and continue instead of waiting. *(Codex · VS Code Copilot: both triggers are synchronous — a bounded blocking call or poll loop — so this collapses to re-reading real state immediately before each bounded call or poll iteration.)*
3. **Two timer concepts, one bound: a renewable watchdog tick under an immutable absolute deadline.** The time-driven trigger is a **watchdog tick** — it wakes the agent to reconcile and may be re-armed on every wake. The **absolute deadline** is set once, before the wait begins, and re-arming ticks never extends it — otherwise a single step could wait forever despite the workflow's caps. Declare the deadline up front: default **1 hour**, or a larger bound declared before the wait for known-long work (training, full benchmark runs). A pre-spawn time estimate may inform the declared bound, but is never grounds to kill work early — model duration estimates are unreliable. The deadline covers one wait's re-armed generations for the **same awaited work**; a new wait for different work gets its own deadline.
4. **On deadline expiry, treat it as a hard blocker.** Reconcile once more, persist the pending-wait record (point 6), then record and escalate — never sleep unbounded, and never silently kill-and-continue. Where the platform exposes a safe stop for the stuck work (e.g. Claude Code's `TaskStop`), the escalation may stop it **after** the record is persisted, discarding only a repeat-safe, uncommitted tail.
5. **Whichever fires first wins — and is thereby consumed.** On wake, stand down the other trigger and **re-verify the real condition by reading actual state** (exit code, file, process status) — a trigger firing, or any notification, is a hint to look, not proof the work finished. A stale notification from an earlier wait generation gets the same treatment: reconcile, then ignore it. Before waiting again, retire the old generation and arm a fresh live pair (under the same absolute deadline while still awaiting the same work).
6. **Persist a pending-wait record before the wait begins** — never deferred to the later Reflect/Ledger or report step: wait generation (incremented each time the pair is re-armed for the same awaited work), awaited work/artifact identities, start time + absolute deadline, last reconciliation result, and trigger lifecycle (live / fired / consumed / replaced) where the platform exposes it. Write it to scratch state (loop: a note beside the scratch ledger, not a ledger line; exec: a scratch note) — never a repo file. After the wake, record the completed wait (what was awaited, both triggers, which fired, duration) in the [loop ledger] entry / [execution report] as before.
7. **On every wake or resume, inspect authoritative completion metadata first.** If the awaited work is complete, accept its output only when its work identity matches the pending-wait record **and** the step's own verifier passes — then continue immediately and commit it (loop: per the iteration-commit rule, write-guard included; exec: record it in [execution report]). On an identity mismatch or failed verification, discard the cached output and fall back to the repeat-safe replay (loop: re-run that pass's Act step; exec: safe re-execution per the plan) — never accept stale output or duplicate a committed side effect. If the work is incomplete, retire the old wait generation and arm a fresh pair before waiting again (point 5). This is the level-triggered controller pattern — observed state governs; notifications are only optimizations ([Kubernetes controllers](https://kubernetes.io/docs/concepts/architecture/controller/), [watch recovery](https://kubernetes.io/docs/reference/using-api/api-concepts/)).

**Design the wait so that both triggers failing is impossible, not merely unlikely.** This protocol engages only when a wait is genuinely unavoidable: if you cannot name two distinct mechanisms for a given wait, restructure the step so it does not wait at all — poll actively instead.
