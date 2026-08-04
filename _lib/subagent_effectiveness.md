# Subagent Effectiveness Record

Canonical rule for the **[subagent effectiveness]** artifact and the append-only
`repo_info/subagent_effectiveness.md` log it is written to. Every workflow's effectiveness
step points here; this file is the single source — the workflow files deliberately do not
restate it.

**Purpose:** make it visible, run after run, whether the pack's opt-in helpers actually earn
their token cost. **What it is not:** a measurement. A main agent rating its own pipeline is
biased toward "useful" (self-preference bias; introspective contribution estimates track true
ablation poorly in hierarchical agent topologies — arXiv:2605.27621), which is why every claim
below must be tied to something the run already recorded rather than freshly judged.

---

## Which helpers are covered

Exactly the five opt-in helpers: **Devils Advocate**, **Diversifier**, **Online Researcher**,
**`simplify`**, **`code_review`**.

- Record a helper only when the workflow that just ran actually **contains** it. A helper the
  workflow has no row for is **omitted entirely** — the loop and query families have no
  Diversifier row, and `initialize` has none of the five; never write a line for one.
- A contained helper whose gate resolved off, that was skipped, or that returned
  `fallback-single-agent` / `blocked` gets a single `did not run — <reason>` line and **no
  verdict**. Never invent a contribution for it.
- **Loop family:** the Devils Advocate runs in two distinct roles — the gated advisory spec
  critique and the always-on exit-gater (`_lib/workflow_contract.md` §Subagent Launch Contract,
  "Analysis gates"). Record each role that ran on its own line, labelled
  `Devils Advocate (spec critique)` and `Devils Advocate (exit-gater)`; under
  `devils_advocate: off` the first is `did not run` while the second still ran.

## The two sentences

For each helper that ran, exactly two sentences — never a third:

1. **Contribution** — one sentence naming what it actually brought, **anchored to the
   adjudication the main agent already performed** (`_lib/workflow_contract.md` §Division of
   Labor): how many findings were accepted vs rejected, which alternative was adopted or why
   none was, which source changed a decision, which review findings were applied. A
   contribution sentence with no accepted / rejected / adopted anchor is not usable — write
   "nothing was accepted" rather than a generic gloss.
2. **Verdict** — a few words, opening with one of the fixed tokens `useful` ·
   `partly useful` · `not useful`, then a short reason (~8 words total), e.g.
   `useful — 4 of 7 findings changed the plan`. The fixed token is what makes entries
   comparable across runs; the tail is free text.

## Entry format

Create `repo_info/subagent_effectiveness.md` if it does not exist (the initialize workflows
create it; older installs predate it). **Append** the entry at the bottom; never rewrite or
re-order prior entries, and do not read them first — entries carry **no ID**, only a timestamp
obtained per `_lib/doc_logging.md`.

```md
{=====================Subagent Effectiveness=====================}
{Workflow (category + mode) + Timestamp (current time, YYYY-MM-DD HH:MM)}
{Request (one line)}
- Devils Advocate: {contribution sentence} {verdict}
- Diversifier: {contribution sentence} {verdict}
- Online Researcher: {contribution sentence} {verdict}
- simplify: {contribution sentence} {verdict}
- code_review: {contribution sentence} {verdict}
```

This file is **not** part of [key md files] and is not read at a workflow's context-gathering
step; open it only when a request actually asks about helper effectiveness.
