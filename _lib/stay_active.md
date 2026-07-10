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

## Rule 2 — Every wait arms two wake triggers, through two different mechanisms.

Sometimes a step genuinely must wait: a long build, a background process, a remote CI run, an external event. A wait is allowed **only** when the agent is guaranteed to wake up again. A single wake path is a single point of failure — if it never fires, the agent sleeps forever.

**Before entering any wait, arm at least two independent wake triggers using two different mechanisms:**

- **Trigger A — event-driven.** Fires when the awaited thing actually changes state. *(Claude Code: a `Monitor` watch on the condition, or the completion notification of a background `Bash` task / subagent. Codex · VS Code Copilot: a blocking foreground call with its own hard timeout.)*
- **Trigger B — time-driven fallback.** Fires on a timer regardless of whether the event ever arrives. *(Claude Code: `ScheduleWakeup`, a `CronCreate` tick, or a bounded re-check loop. Codex · VS Code Copilot: a bounded polling loop that re-reads real state on an interval.)*

**Requirements:**
1. **Two different mechanisms — not one mechanism twice.** Two timers are one mechanism; an event watch plus a timer are two.
2. **Arm both before the wait begins**, never after. An unarmed fallback cannot rescue a wait already in progress.
3. **Bound the fallback.** Every wait carries a finite max duration or max poll count. On expiry, treat it as a **hard blocker** — record it and escalate. Never sleep unbounded.
4. **Whichever fires first wins.** On wake, stand down the other trigger and **re-verify the real condition by reading actual state** (exit code, file, process status) — a trigger firing is a hint to look, not proof the work finished.
5. **Record the wait**: what was awaited, both triggers armed, which one fired, and how long it took. In a loop this goes in the [loop ledger] entry; in exec it goes in [execution report].

**Design the wait so that both triggers failing is impossible, not merely unlikely.** If you cannot name two distinct mechanisms for a given wait, restructure the step so it does not wait at all — poll actively instead.
