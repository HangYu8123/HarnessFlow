---
name: code-simplification
description: 'Simplify code for clarity while preserving exact behavior — reduce nesting, split long functions, remove redundancy and dead code, and fix unclear names. TRIGGER: invoked by a HarnessFlow workflow''s post-implementation review step when the request header is `simplify: local`. Not a planning-time skill.'
disable-model-invocation: true
---

# Code Simplification

The platform-independent alternative to Claude Code's native `/simplify`. A workflow invokes
it from its post-implementation review step when the request header is `simplify: local` —
see `_lib/review_skills.md` (resolved via Pack Path Resolution) for how it is launched.

*Distilled from `addyosmani/agent-skills` · `code-simplification` (MIT).*

## Your job

Make the diff you were handed easier to read **without changing what it does**, then apply
the edits to the working tree. This is the write step; the `code_review` pass that may follow
reads the resulting diff. Report what you changed under the output label **[simplify]**.

**Scope is binding, not advisory: simplify only the files in the diff you were handed.** No
drive-by refactors of untouched code. **Never commit, branch, or open a PR** (`_lib/safety_rules.md`
rule 1). Under the default autonomous gate (`_lib/approval_gate.md` Mode 2) do not ask
questions — choose the most reasonable reading, record it as a one-line assumption, proceed.

## Rules

1. **Preserve behavior exactly.** Same output for every input, same error behavior, same side
   effects and ordering, same edge cases. Existing tests must pass **unmodified** — needing to
   change a test means you changed behavior. If unsure a change is behavior-preserving, skip it.
2. **Understand before touching (Chesterton's Fence).** Know what the code is responsible for,
   what calls it, and why it might be written that way, before you change or delete it. Check
   `git blame` when the reason isn't obvious. Can't answer? Read more; don't simplify — at
   `low`/`medium` effort, skip the change instead of reading more (see §Effort budget).
3. **Match the project's conventions**, not your preferences — imports, naming, error handling,
   type depth, and how neighboring code solves the same problem. Simplification that breaks
   consistency is churn.
4. **Comprehension speed is the goal, not line count.** A one-line nested ternary is not simpler
   than a five-line `if`/`else`. Explicit beats compact whenever compact needs a mental pause.
5. **Don't over-simplify.** Inlining a helper that gave a concept its name, merging two simple
   functions into one complex one, or deleting an abstraction that exists for testability all
   make things worse.
6. **One change at a time.** Apply, re-run the tests, keep or revert. Batching untested edits
   hides which one broke things — at `low` effort you batch anyway and accept that cost (see
   §Effort budget). If a change would touch >500 lines, script it instead.

## What to look for

| Signal | Remedy |
|---|---|
| Nesting 3+ deep | Guard clauses / early returns; extract a helper |
| Function 50+ lines, multiple responsibilities | Split into focused, well-named functions |
| Nested ternaries, boolean flag params | `if`/`else` chain, lookup table, or separate functions |
| The same conditional repeated | Extract a named predicate |
| Generic or misleading names (`data`, `tmp`, a `get` that mutates) | Rename to what it actually is/does |
| Comments restating the code | Delete — but keep every comment explaining *why* |
| 5+ duplicated lines | Extract a shared function |
| Dead code: unreachable branches, unused vars/imports, commented-out blocks | Remove once confirmed dead |
| Wrapper or pattern that adds no value (factory-for-a-factory) | Inline it; call the real thing |

## Effort budget

Your prompt carries an `effort:` line. It is a binding budget on tool use, not only on how
hard you think. Canonical tiers: `_lib/review_skills.md` §Effort budget.

- **`low` and `medium`** — intake is the handed-in diff. No `git blame`; open a whole file
  only when a hunk is unintelligible without it. When that leaves a Chesterton's Fence
  question unanswered (rule 2), **skip that simplification** — the budget never buys a
  behavior risk.
- **`low` also** — replace rule 6's per-edit test loop with a single run: apply the batch,
  run the tests once, and revert **the whole batch** if it fails rather than bisecting it.
- **`high` and above, or no `effort:` line** — rules 2 and 6 stand exactly as written.

End your report with a one-line `budget:` note saying what the tier kept you from checking
(files not opened, history not read, edits skipped for an unanswered fence question).

## Before you finish

- Tests pass **without modification**; build and linter clean, no new warnings.
- No error handling was removed or weakened; no dead code left behind.
- Every edit traces to a file in the handed-in diff.
- The result genuinely reads faster than the original — if it doesn't, revert it.
