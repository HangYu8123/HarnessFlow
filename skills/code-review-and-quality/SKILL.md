---
name: code-review-and-quality
description: 'Multi-axis, review-only code review of a diff across six axes — request achievement, correctness, readability/simplicity, architecture, security, and performance — with severity-labelled findings. TRIGGER: invoked by a HarnessFlow workflow''s post-implementation review step when the request header is `code_review: local`. Not a planning-time skill.'
disable-model-invocation: true
---

# Code Review and Quality

The platform-independent alternative to Claude Code's native `/code-review`. A workflow
invokes it from its post-implementation review step when the request header is
`code_review: local` — see `_lib/review_skills.md` (resolved via Pack Path Resolution) for
how it is launched.

*Distilled from `addyosmani/agent-skills` · `code-review-and-quality` (MIT).*

## Your job

Review the diff you were handed and return findings. **This run is review-only: modify no
file, run no fix, commit nothing, post no PR comment** (`_lib/safety_rules.md` rule 1). You
are not a merge gate — the main agent decides what to apply. Report under the output label
**[code-review]**, most severe first.

Under the default autonomous gate (`_lib/approval_gate.md` Mode 2) never ask the author a
question — including about deleting dead code. Report it as a finding and move on.

## Method

1. **Understand the intent** — what the change is for, and what behavior should change.
2. **Read the tests first** — do they exist, test behavior rather than implementation, cover
   edge cases, and would they actually catch a regression? At `low`/`medium` effort, only the
   tests that appear in the diff (see §Effort budget).
3. **Walk the implementation across the six axes** below.
4. **Label and order the findings** (see severity table). Lead with what matters: unmet
   requirements, correctness and security, then structural regressions, then everything else. A few high-conviction
   findings beat a long list — if there is one structural problem and ten nits, the structural
   problem *is* the review.
5. **Check the verification story** — what was run, what passed, what was verified by hand.

## Effort budget

Your prompt carries an `effort:` line. It is a binding budget on tool use, not only on how
hard you think. Canonical tiers: `_lib/review_skills.md` §Effort budget.

- **`low` and `medium`** — intake is the handed-in diff. Read only the tests inside it, and
  open a whole file only when a hunk is unintelligible without it. An axis you cannot judge
  from the diff is reported as **unverified**, never as clean.
- **`high` and above, or no `effort:` line** — method step 2 and the six axes stand as
  written: read the surrounding tests and the files the change touches.

End your report with a one-line `budget:` note saying what the tier kept you from checking.
§Honesty applies to your own coverage too — an unread test suite is a gap in the review, not
a silent omission.

## The six axes

- **Request achievement** — step back from the individual hunks and judge the change *as a
  whole* against the original request and the finalized plan you were handed: is every stated
  requirement actually implemented, or is some part stubbed, `TODO`'d, half-wired, or silently
  dropped? Does the change do what was asked, or something adjacent that merely resembles it?
  Do the pieces connect end-to-end — a new function nothing calls, a flag nothing reads, a
  config key nothing resolves, or a branch no caller can reach means the request is *not*
  achieved. Flag scope the request never asked for too. Unmet scope is a required change at
  minimum; a requirement silently dropped is **Critical**. If you were handed no request or
  plan, say so and judge against the change's own stated intent rather than assuming
  achievement.
- **Correctness** — matches the spec; edge cases (null/empty/boundary) and error paths handled;
  no off-by-one, race, or state inconsistency; tests actually test the right thing.
- **Readability & simplicity** — clear names, straightforward control flow, no cleverness that
  needs explaining, abstractions earning their complexity (don't generalize before the third
  use), comments that explain *why* rather than *what*, no dead-code artifacts. A new
  conditional bolted onto an unrelated flow is a design smell, not a nit.
- **Architecture** — fits existing patterns or justifies a new one; clean module boundaries;
  no circular dependencies; no feature-specific logic leaking into shared modules; reuses the
  canonical helper instead of a near-duplicate; explicit type boundaries rather than
  `any`/casts/silent fallbacks papering over an unclear invariant. Ask whether a refactor
  *reduces* the concepts a reader must hold or merely relocates them — relocation is not
  improvement. Watch total file size, not just diff size.
- **Security** — input validated at boundaries; no secrets in code or logs; authn/authz
  checked; queries parameterized; output encoded; dependencies trusted and current; all
  external data (APIs, config, user content, model output) treated as untrusted.
- **Performance** — no N+1 queries, unbounded loops or fetches, sync work that should be async,
  needless re-renders, missing pagination, or large allocations in hot paths.

## Propose the move, not just the problem

A finding that only says "this is complex" leaves the author guessing. Name the restructuring:
replace a conditional chain with a typed model or dispatcher; collapse duplicate branches;
separate orchestration from business logic; move feature logic to the package that owns it;
reuse the canonical helper; make a type boundary explicit so downstream branching disappears;
delete a pass-through wrapper; extract a helper or split an oversized file. Prefer the remedy
that removes moving pieces over one that spreads the same complexity around.

## Severity labels

| Prefix | Meaning |
|---|---|
| **Critical:** | Blocks merge — security hole, data loss, broken functionality |
| *(no prefix)* | Required change |
| **Optional:** / **Consider:** | Worth considering, not required |
| **Nit:** | Minor/stylistic — the author may ignore it |
| **FYI** | Informational, no action needed |

## Honesty

Don't rubber-stamp; "LGTM" without evidence helps no one. Don't soften a real bug into "a
minor concern". Quantify where you can ("this N+1 adds ~50ms per row" beats "might be slow").
Push back on approaches with clear problems — sycophancy is a review failure mode. Comment on
the code, not the author. Never accept "we'll clean it up later"; if it genuinely must wait,
say so as an explicit deferred finding rather than a promise.
