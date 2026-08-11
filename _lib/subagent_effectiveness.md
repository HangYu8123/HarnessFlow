# Subagent Effectiveness Record

Canonical rule for the **[subagent effectiveness]** artifact and the append-only
`repo_info/subagent_effectiveness.md` log it is written to. Every workflow's effectiveness
step points here; this file is the single source — the workflow files deliberately do not
restate it.

**Purpose:** make it visible, run after run, whether the pack's opt-in helpers earn their token
cost **at the model and effort they were given**. The record exists to evaluate and tune the
harness — drop a helper, re-gate it, raise or lower a dial — not to summarize the run.
**What it is not:** a measurement. A main agent rating its own pipeline is biased toward
"useful" (self-preference bias; introspective contribution estimates track true ablation poorly
in hierarchical agent topologies — arXiv:2605.27621), which is why every claim below must be
tied to something the run already recorded rather than freshly judged.

**Record effect, not activity.** What a helper *did* — what it read, which files it covered,
what it proposed — is already in the run's other artifacts and is dead weight here. Each line
records only what survived the main agent's adjudication, how new and how consequential that
was, and under which dials it was produced. A line that narrates work performed is a defective
entry, however accurate.

---

## Which helpers are covered

Exactly the five opt-in helpers: **Devils Advocate**, **Diversifier**, **Online Researcher**,
**`simplify`**, **`code_review`**.

- Record a helper only when the workflow that just ran actually **contains** it. A helper the
  workflow has no row for is **omitted entirely** — the loop and query families have no
  Diversifier row, and `initialize` has none of the five; never write a line for one.
- A contained helper whose gate resolved off, that was skipped, or that returned
  `fallback-single-agent` / `blocked` gets a single `did not run — <reason>` line, with **no
  dials, no counts, and no verdict**. Never invent a contribution for it.
- **Loop family:** the Devils Advocate runs in two distinct roles — the gated advisory spec
  critique and the always-on exit-gater (`_lib/workflow_contract.md` §Subagent Launch Contract,
  "Analysis gates"). Record each role that ran on its own line, labelled
  `Devils Advocate (spec critique)` and `Devils Advocate (exit-gater)`; under
  `devils_advocate: off` the first is `did not run` while the second still ran.

## Dials — model and effort

Every line for a helper that ran carries the two dials it ran under, as `[<model> · <effort>]`
directly after the helper name. This is what makes a weak verdict readable: `not useful` at
`low` effort is a dial problem, `not useful` at `xhigh` is a helper problem.

Take both from the resolution already performed at launch (`_lib/workflow_contract.md`
§Subagent Launch Contract) — never re-derive or guess them here.

- **model** — [specified subagent model]. Write the concrete model id when the header pinned
  one; when the header was `inherit` or absent, write `inherit→<main agent model>`.
- **effort** — [specified subagent effort] as resolved, one of `inherit` · `low` · `medium` ·
  `high` · `xhigh` · `max`. For the **Online Researcher** write [specified online researcher
  effort] instead — that per-role override is the level that actually ran. Append
  `(not-applied)` when the launch logged `effort: not-applied`, i.e. neither the agent
  definition nor the prompt could carry the override: the requested level is then **not** what
  ran, and a verdict read against it would be wrong.
- **`simplify` / `code_review`** — under a `true` header these run as native Claude Code skills
  on the platform's own dials, which the pack does not set: write `[native]` in place of both
  fields. Under a `local` header they are ordinary spawned subagents and carry the run's dials
  like any other line.
- Record the main agent's own model once in the entry header (it is the fallback every
  `inherit` line resolves to).

## What each line records

After the dials, exactly three elements in order — adoption, novelty/importance, verdict. Two
sentences plus the verdict token; never a third sentence.

1. **Adoption** — `adopted n/m`, where **m** is the number of discrete items the helper returned
   (findings, alternatives, sources, review items) as counted in the run's adjudication and
   **n** is how many the main agent accepted, followed by one clause naming what the accepted
   ones actually changed: the plan, the code, the diagnosis, the exit decision, or nothing.
   `adopted 0/m` is a normal and informative result — write it plainly rather than softening it.
2. **Novelty & importance** — two fixed tokens, judged on the **adopted** items:
   - `novel` · `partly novel` · `redundant` — did the accepted content give the main agent
     something its own analysis did not already have? `redundant` means it duplicated a
     conclusion the run had already reached.
   - `critical` · `moderate` · `minor` — what ignoring it would have cost: broken correctness,
     a rework pass, or nothing beyond polish.

   When nothing was adopted, judge these on the **rejected** items instead: correct but
   out-of-scope work is still `novel` (a gating or scoping problem), while wrong or generic
   output is `redundant` (a helper problem). That distinction is the whole point of the line.
3. **Verdict** — opens with one of the fixed tokens `useful` · `partly useful` · `not useful`,
   then ~8 words of reason tied to the counts, e.g. `useful — 4/7 adopted, one blocking bug`.
   The fixed token is what makes entries comparable across runs; the tail is free text.

**Anchoring rule.** Every count and token must trace to the accept/reject adjudication the main
agent already performed (`_lib/workflow_contract.md` §Division of Labor). Never estimate: if a
helper's output was not adjudicated item-by-item, write `adopted —/m (not adjudicated)` and let
the verdict say so.

## Entry format

Create `repo_info/subagent_effectiveness.md` if it does not exist (the initialize workflows
create it; older installs predate it). **Append** the entry at the bottom; never rewrite or
re-order prior entries, and do not read them first — entries carry **no ID**, only a timestamp
obtained per `_lib/doc_logging.md`.

```md
{=====================Subagent Effectiveness=====================}
{Workflow (category + mode) + Timestamp (current time, YYYY-MM-DD HH:MM)}
{Request (one line)}
{Main agent model: <model id>}
- Devils Advocate [{model} · {effort}]: adopted {n}/{m} — {what the accepted items changed}. {novelty token}, {importance token} — {short reason}. {verdict}
- Diversifier [{model} · {effort}]: adopted {n}/{m} — {…}. {novelty token}, {importance token} — {…}. {verdict}
- Online Researcher [{model} · {effort}]: adopted {n}/{m} — {…}. {novelty token}, {importance token} — {…}. {verdict}
- simplify [{model} · {effort} | native]: adopted {n}/{m} — {…}. {novelty token}, {importance token} — {…}. {verdict}
- code_review [{model} · {effort} | native]: adopted {n}/{m} — {…}. {novelty token}, {importance token} — {…}. {verdict}
```

A helper that was contained but did not run takes the short form instead, with nothing after it:

```md
- Diversifier: did not run — gate off
```

This file is **not** part of [key md files] and is not read at a workflow's context-gathering
step; open it only when a request actually asks about helper effectiveness — with one narrow
exception: at Diversifier spawn time the main agent may extract **only** the `- Diversifier`
lines to build the calibration-prior `history:` line (`_lib/workflow_contract.md` §Subagent
Launch Contract), never the rest of the file.
