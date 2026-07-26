# Review Skills — the `simplify` and `code_review` headers

Canonical rule for the two opt-in post-implementation review headers. Every workflow's
review step points here; this file is the single source — the workflow files deliberately
do not restate it.

Applies to the six code-modifying categories: **code, debug, refactor, exec, pr, loop**.

---

## The three values

Both headers take the same three values, independently of each other
(`simplify: local` with `code_review: true` is legal). **Both default to `false`** —
absent, unset, or any unrecognized value is treated as `false`.

| Value | What runs | Writes files? | Output label | Platforms |
|---|---|---|---|---|
| `false` *(default)* | Nothing. Skip the step entirely and leave the output label **unproduced**. | — | — | all |
| `true` | Claude Code's **native bundled skill**: `/simplify`, resp. `/code-review medium`. | `/simplify` yes · `/code-review` no | `[simplify]` · `[code-review]` | Claude Code only — see *Platform note* |
| `local` | The pack's own **local skill**: `skills/code-simplification/SKILL.md`, resp. `skills/code-review-and-quality/SKILL.md` (resolve via Pack Path Resolution). | `code-simplification` yes · `code-review-and-quality` no | `[simplify]` · `[code-review]` | all |

`/code-review medium` — `medium` is the **skill's own** effort level on its
`low|medium|high|xhigh|max|ultra` scale, a property of the skill call, not of the
subagent's model. It is a separate dial from `subagent_effort`, which governs the subagent
running the skill (see `_lib/workflow_contract.md` §Subagent Launch Contract, "Subagent
effort").

---

## Platform note

`true` depends on Claude Code's bundled skills. On **Codex** or **VS Code Copilot** the
native skills do not exist, so `true` keeps whatever non-Claude branch the calling
workflow already specifies (typically: skip the native skills; in the `general_workflow`
family the main agent still performs its own manual complexity/redundancy review).

**`local` is the portable option.** A local skill is just a `SKILL.md` the subagent
reads and follows, so `local` behaves identically on Claude Code, Codex, and VS Code
Copilot. Choose `local` when you want a real review pass on a non-Claude platform.

---

## How to run them

Both are launched as subagents under the Subagent Launch Contract
(`_lib/workflow_contract.md` §Subagent Launch Contract): they use the `subagent_model` the
request specifies, and the main agent keeps the usual activity log.

**They run in parallel — launch both before waiting for either.** This is a deliberate
speed-for-accuracy trade: the simplify step writes the working tree, so the code-review
step reads a diff that may be stale by the time it reports. See *Parallel-review caveats*
below for how the main agent reconciles that. Invoke each skill exactly once.

Launch per `_lib/workflow_contract.md` §Parallel Execution & Fallback: issue both subagent
invocations before waiting on any result; if parallel launch is unavailable, degrade to
sequential with simplify first.

1. **Simplify** (only when `simplify` is `true` or `local`) — spawn one subagent. Pass it
   the changed files (the current diff), the workflow's finalized plan, its implementation
   or execution report, and the relevant repo context (per §Context Passing).
   - `true` → have it run `/simplify`.
   - `local` → have it read `skills/code-simplification/SKILL.md` and follow that skill.

   Either way it applies its edits to the working tree. Record **[simplify]**.

2. **Code review** (only when `code_review` is `true` or `local`, *and* the step actually
   changed code files) — spawn a second subagent **at the same time as the simplify
   subagent, without waiting for it**. Pass it the diff as it stands at launch, plus the
   same plan / report / repo context.
   - `true` → have it run `/code-review medium`, **review-only**: never `--fix`, never
     `--comment` (`--comment` posts inline comments to a GitHub PR — an outward-facing
     action governed by `_lib/safety_rules.md` rule 1).
   - `local` → have it read `skills/code-review-and-quality/SKILL.md` and follow that
     skill, which is review-only by construction.

   Either way it modifies nothing. Record **[code-review]**.

When only one of the two is enabled, run just that one. When both are `false`, skip the
whole step.

---

## Parallel-review caveats

Running the two concurrently is faster but costs the guarantee that code-review saw the
final tree. When both actually ran, the main agent must, before consuming the results:

1. **Anchor findings by file + symbol, not line number.** Simplify may have moved or
   deleted the lines a code-review finding cites. Re-locate each finding in the current
   tree; drop the ones simplify already resolved.
2. **Re-check any finding that lands in a region simplify edited.** Those are the only
   ones the staleness can invalidate — a finding in untouched code is unaffected.
3. **Treat a direct conflict as unresolved, not as a fix.** If simplify rewrote code that
   code-review flagged as buggy, the bug is not automatically gone; verify or record it
   as a gap.

---

## Orchestration per workflow family

- **`token_effective_workflow/`** — the main agent spawns the one or two subagents
  directly, one skill each, no orchestration wrapper.
- **`general_workflow/` and `skill_workflow/`** — when the value is `true` on Claude Code,
  the review is delegated to `skills/claude-native-skills-subagents/SKILL.md`, which is the
  **only** caller of the native `/simplify` and `/code-review`; do not invoke either
  separately in addition to it. When the value is `local`, that wrapper does not apply —
  spawn the local-skill subagents directly, exactly as described above.

---

## Fallback

If a subagent cannot be spawned, or cannot invoke its slash command (for `true`) or read
its `SKILL.md` (for `local`), the main agent performs that skill's work directly — or, if
the skill itself is unavailable, reviews the diff inline — and records a `[fallback result]`
with `status: fallback-single-agent` (per `_lib/workflow_contract.md` §Subagent Launch
Contract). The workflow never blocks on a missing review skill.

---

## Consuming the results

The main agent analyzes whichever of **[simplify]** and **[code-review]** were produced,
applies the clearly-correct, low-risk findings, does **not** auto-apply uncertain or
behavior-changing ones, and records any remainder as gaps for the documentation step.
