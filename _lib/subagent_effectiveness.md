# Run Record — Context, Subagents, Plan, Workflow

Canonical rule for the **[run record]** artifact and the append-only
`repo_info/subagent_effectiveness.md` log it is written to (the file keeps its historical name;
older entries carrying only helper lines remain valid). Every workflow's last step — fast, general,
and skill mode, initialize included — points here; this file is the single source and the workflow
files deliberately do not restate it.

The record is the **raw layer** of the harness wiki (`_lib/harness_wiki.md`): one fixed-shape entry
per run, never edited, answering four questions the Wiki Maintainer later tallies across runs —
**what context contributed · what subagents contributed · whether having a plan helped · what part
of the workflow can improve**. Every element exists to make one of those computable, and the whole
entry is written from what the main agent already holds when the run ends.

**What it is not:** a measurement. A main agent rating its own pipeline is biased toward "useful"
(self-preference bias; introspective contribution estimates track true ablation poorly in
hierarchical agent topologies — arXiv:2605.27621), which is why every value below must be tied to
a count or note the run already produced rather than freshly judged.

**Record effect, not activity.** What a helper *did* — what it read, which files it covered, what
it proposed — is already in the run's other artifacts and is dead weight here. A line that narrates
work performed is a defective entry, however accurate.

---

## Token budget — cheap by construction

- The entry is **at most one line per spawned advisory role plus three note lines**, every line
  ≤ ~25 words, no prose. A general-mode run lands near 15 short lines; a fast run near 8.
- Every value comes from something the run already produced: the item-by-item adjudication of each
  subagent's result, the context notes kept since context gathering (`_lib/workflow_contract.md`
  §Key Context Files, "Context utility"), the thoughts artifact's closing tally
  (`_lib/plan_adherence.md` §Tally), the activity log. **Never re-read an artifact, a file, or a
  prior entry to fill a line** — a value you do not hold is written `—`, never researched.
- Append only. Writing the entry never requires reading the file, and the Maintainer pass that
  follows reads nothing on four runs out of five (`_lib/harness_wiki.md` §Cadence).

## Which roles are covered

- **Opt-in helpers** — **Devils Advocate**, **Diversifier**, **Online Researcher**, **`simplify`**,
  **`code_review`** — always get a line when the workflow contains them.
- **Advisory roles that always run** — Focus / Broad / Free Analyst, Senior and Principal Engineer,
  QA Engineer, Bug Reproducer, the refactor analysts, the initialize overview generators — get the
  same line whenever they were spawned: `m` is the number of discrete items they returned (plan
  items, findings, checks, overview claims) and `n` how many reached the final artifact ([final
  plan], the diagnosis, the report, the written overview). They are the bulk of a general-mode
  run's token cost and the only way to answer "which subagents contribute" for that mode.
- **Executing roles** — Implementer, Executor, a loop dispatch sub-main — get a line **only on
  exception**: `- Implementer [{model} · {effort}]: fallback — <reason>` or
  `rework <n> passes — <what>`. A clean execution is omitted, not praised.
- Record a role only when the workflow that just ran actually **contains** it; a role the workflow
  has no row for is omitted entirely (the loop and query families have no Diversifier row;
  `initialize` has none of the five helpers). Never write a line for one.
- A contained helper whose gate resolved off, that was skipped, or that returned
  `fallback-single-agent` / `blocked` gets the short form `- Diversifier: did not run — gate off`,
  with no dials, counts, or verdict. Never invent a contribution for it.
- **Loop family:** the Devils Advocate runs in two roles — the gated advisory spec critique and the
  always-on exit-gater (`_lib/workflow_contract.md` §Subagent Launch Contract, "Analysis gates").
  Record each role that ran on its own line, `Devils Advocate (spec critique)` and
  `Devils Advocate (exit-gater)`; under `devils_advocate: off` the first is `did not run` while the
  second still ran.

## Dials — model and effort

Every line for a role that ran carries the two dials it ran under, as `[<model> · <effort>]`
directly after the role name — this is what makes a weak verdict readable: `not useful` at `low`
effort is a dial problem, `not useful` at `xhigh` is a helper problem. Take both from the
resolution already performed at launch (`_lib/workflow_contract.md` §Subagent Launch Contract);
never re-derive them.

- **model** — [specified subagent model]: the concrete id when the header pinned one, else
  `inherit→<main agent model>`.
- **effort** — [specified subagent effort] as resolved (`inherit` · `low` · `medium` · `high` ·
  `xhigh` · `max`); for the **Online Researcher**, [specified online researcher effort]. Append
  `(not-applied)` when the launch logged `effort: not-applied` — the requested level is then not
  what ran.
- **`simplify` / `code_review`** under a `true` header run as native Claude Code skills on the
  platform's own dials: write `[native]`. Under `local` they carry the run's dials like any line.

## Role lines — what subagents contributed

After the dials, three clauses on one line — adoption, novelty/importance, verdict — and nothing
more:

1. **Adoption** — `adopted n/m` (m = discrete items returned as counted in the adjudication; n =
   accepted) plus ≤ 8 words on what the accepted items changed. `adopted 0/m` is a normal result;
   write it plainly. **Diversifier exception:** `adopted N / parked M / rejected K` (+
   `· same-as-draft S` when S > 0), each count taken from the per-alternative dispositions recorded
   at the refine step (`_lib/workflow_contract.md` §Diversifier Contract → Count).
2. **Novelty & importance** — two fixed tokens judged on the adopted items: `novel` · `partly novel`
   · `redundant` (did it give the main agent something its own analysis lacked?) and `critical` ·
   `moderate` · `minor` (what ignoring it would have cost). When nothing was adopted, judge the
   rejected items instead: correct but out-of-scope work is still `novel` (a gating problem); wrong
   or generic output is `redundant` (a helper problem).
3. **Verdict** — `useful` · `partly useful` · `not useful` plus ≤ 8 words tied to the counts.
   **Diversifier exception:** computed — `useful` when N ≥ 1, `partly useful` when N = 0 and M ≥ 1,
   `not useful` when N = M = 0.

**Anchoring rule.** Every count and token traces to the accept/reject adjudication the main agent
already performed. If a role's output was not adjudicated item-by-item, write
`adopted —/m (not adjudicated)` and let the verdict say so.

## Context line — what context contributed

One `- context:` line: one clause per [key md files] file the workflow read (plus any extra
repo_info file it read, e.g. `past_Q&A.md`), then the digest. Each clause carries one or more
tokens, each with the concrete claim or gap in a few words:

- `load-bearing` — a claim from the file shaped the plan, diagnosis, answer, or a subagent's route;
  name it (`pipeline edge ingest→train`, `known issue #4`).
- `unused` — read, and nothing in the run relied on it.
- `stale` — a claim the code contradicted this session; name it. Corrected at the documentation
  step when that step owns the file (the overviews), otherwise left for re-initialization.
- `missing` — information the run needed and had to re-derive from code because no file carried
  it; name it. A recurring `missing` is a candidate addition, budget permitting.
- `digest sufficient` · `digest insufficient — <what a subagent had to re-read>`.

**Initialize runs:** a re-initialization writes the validation outcome instead —
`context: codebase_overview confirmed <n> · stale <n> · obsolete <n> · missing <n> ·
scripts_overview …` from the [validation & diff report]; a fresh initialization writes
`context: fresh`.

## Plan line — whether having a plan helped

One `- plan:` line. "The plan" is [final plan] / [final bug fix plan] / [final pr plan] in the code,
debug, exec, pr, and refactor families and [loop spec] in the loop family; query,
correctness_check, and initialize have none and write `- plan: n/a`, nothing else.

```
- plan: steps <t> · as-written <a> · adapted <b> · dropped <c> · added <d> · re-plans <r> · <verdict> — <≤ 12 words>
```

- The counts are the thoughts artifact's closing tally (`_lib/plan_adherence.md` §Tally): t = steps,
  actions, or PRs in the plan; a = executed as written; b = needed the smallest adaptation; c = not
  needed; d = work the plan lacked; r = stop-and-re-plan events. A loop run counts iterations
  against [loop spec] the same way.
- The verdict is **computed**: `load-bearing` when an item adopted from the plan-stage subagents
  (challenge, analysis, diversifier, research) changed what was executed, or a plan precondition or
  failure mode prevented an adaptation or a wrong action; `not needed` when t ≤ 2, b = d = r = 0,
  and nothing from the plan-stage subagents was adopted; `partly` otherwise. The tail names the one
  thing the plan caught, or the one thing it got wrong.

This line is what decides, across runs, whether planning earns its tokens for a family and a request
size; the wiki's plan-utility pages are built from it.

## Workflow line — what part of the workflow can improve

One `- workflow:` line: every instruction-level problem the main agent met, each as
`<family/step> — <problem> → <smallest fix>`, separated by ` ; `, or `none`; then the counters
` · remediation <n> · fallbacks <n> · gate pauses <n>` (review → fix loops; subagent fallbacks from
the activity log; approval-gate pause points hit). Problems are things like a step that was
ambiguous or contradicted another, a label naming an artifact the run never produced, mandated work
the request did not need, or a spawn row that under-specified its task so the result came back
off-target. Not repo problems (those go to `known_issues.md`) and not role verdicts (those are the
lines above). `none` is a valid and common value — never invent friction to fill the line.

## Entry format

Create `repo_info/subagent_effectiveness.md` if it does not exist (the initialize workflows and
`cli_setup.sh` create it; older installs predate it). **Append** at the bottom; never rewrite,
re-order, or read prior entries. Entries carry no ID, only a timestamp obtained per
`_lib/doc_logging.md`. Entries written under the older
`{=====================Subagent Effectiveness=====================}` banner remain valid raw records.

```md
{=====================Run Record=====================}
{<category + mode> · <YYYY-MM-DD HH:MM> · main agent <model id> · achieved yes | partial | no}
{Request: <one line>}
- Devils Advocate [{model} · {effort}]: adopted {n}/{m} — {≤ 8 words}. {novelty}, {importance}. {verdict} — {≤ 8 words}
- Diversifier [{model} · {effort}]: adopted {N} / parked {M} / rejected {K} — {…}. {novelty}, {importance}. {computed verdict}
- Online Researcher [{model} · {effort}]: adopted {n}/{m} — {…}. {novelty}, {importance}. {verdict} — {…}
- Focus Analyst [{model} · {effort}]: adopted {n}/{m} — {…}. {novelty}, {importance}. {verdict} — {…}   ← one such line per spawned advisory role
- simplify [{model} · {effort} | native]: adopted {n}/{m} — {…}. {novelty}, {importance}. {verdict} — {…}
- code_review [{model} · {effort} | native]: adopted {n}/{m} — {…}. {novelty}, {importance}. {verdict} — {…}
- Implementer [{model} · {effort}]: fallback — {reason}   ← executing roles: exception-only
- context: codebase_overview {tokens — claim} · scripts_overview {…} · update_logs {…} · known_issues {…} · digest {sufficient | insufficient — what was re-read}
- plan: steps {t} · as-written {a} · adapted {b} · dropped {c} · added {d} · re-plans {r} · {load-bearing | partly | not needed} — {≤ 12 words}
- workflow: {family/step — problem → fix ; …} | none · remediation {n} · fallbacks {n} · gate pauses {n}
```

This file is **not** part of [key md files] and is not read at a workflow's context-gathering
step; open it only when a request actually asks about helper effectiveness — with two narrow
exceptions: at Diversifier spawn time the main agent may extract **only** the `- Diversifier` lines
to build the calibration-prior `history:` line (`_lib/workflow_contract.md` §Subagent Launch
Contract), and the Wiki Maintainer's consolidation pass reads the newest five entries
(`_lib/harness_wiki.md` §Cadence). A Skill Proposer run may open the entries a wiki page cites.
