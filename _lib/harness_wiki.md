# Harness Wiki — Compiling Run Records into Harness Improvements

Canonical rule for `repo_info/harness_wiki.md` (the **Wiki Layer**), the **Wiki Maintainer** pass
every workflow ends with, and the **Skill Proposer** procedure that turns supported wiki patterns
into validated changes to the pack. Every workflow's last step — fast, general, and skill mode,
initialize included — points here; the workflow files deliberately do not restate it.

**Model.** WikiSkill (Tang et al., arXiv:2608.27454, Aug 2026) separates an agent's workspace into
three layers — immutable **raw** execution traces, a persistent **wiki** of consolidated knowledge
(pattern pages, an evolution log, a skill-impact tracker, an index), and the evolving **skills** —
and runs a closed loop: execute → a Wiki Maintainer distils a *sample* of traces into pattern pages
(root causes of failures, strategies behind successes) → a Skill Proposer reads the wiki and
proposes one atomic skill change → the change is kept only if held-out validation is strictly
better, else the skill reverts; the wiki is never rolled back. HarnessFlow maps the layers as:

| Layer | WikiSkill | HarnessFlow |
|---|---|---|
| Raw | execution traces | `repo_info/subagent_effectiveness.md` — the append-only per-run **[run record]** (`_lib/subagent_effectiveness.md`), plus the run's own `update_logs.md` entry |
| Wiki | `patterns/`, `logs.md`, `skill-impact.md`, `index.md` | `repo_info/harness_wiki.md` — one budgeted file with the same four parts, its pattern pages grouped under the four questions the record answers |
| Skill | `skills/*/SKILL.md` | the pack itself: `workflow/**.instructions.md`, `agents/*.agent.md`, `_lib/*.md`, and the request-template dials |

Two of the paper's findings fix the design. The Skill Proposer's wiki access was the largest single
contributor (average accuracy 63.7 → 48.7 without it), while giving the **executing** agent wiki
access *reduced* performance (63.7 → 60.9): it leaned on the wiki instead of on better skills. Hence
Rule 1. The paper consolidates a sampled subset of traces per iteration rather than every trace,
and names the absence of wiki pruning as an open limitation — §Cadence and §Wiki Maintainer step 5
are the pack's versions of both.

---

## Rule 1 — written at the end of a run, never read at its start

- No workflow reads `harness_wiki.md` at context gathering; it is never part of [key md files] or
  of a [repo context digest]. A run touches it in exactly two places: the Wiki Maintainer pass at
  its last step, and a Skill Proposer run (§Skill Proposer). The Diversifier's `history:`
  calibration line reads the raw layer, not the wiki.
- Repo memory (`known_issues.md`, `update_logs.md`, `past_Q&A.md`, `past_Correctness_Check.md`) is
  about the *target repo* and stays read-at-start as today. The wiki is about the *harness* and
  feeds its maintenance.

## The four questions

Every pattern page answers exactly one, and the file is grouped by them:

1. **Context utility** — what context contributed: per `repo_info/` file (and per section when one
   recurs), how often it was load-bearing, unused, stale, or missing (the record's `context:` line).
2. **Subagent effectiveness** — what subagents contributed: tallies of `adopted n/m` and verdicts
   per role × dials (the record's role lines).
3. **Plan utility** — whether having a plan helped: per workflow family and request size, how much
   of the plan ran as written, was adapted, dropped, or added, and how often the plan was
   load-bearing, partly, or not needed (the record's `plan:` line).
4. **Workflow improvement** — what part of the workflow can improve: which steps recur as friction
   or rework, and the atomic fix each supports (the record's `workflow:` line).

## Cadence — cheap by construction

- **Every run** appends its [run record] and prints one status line. That is the whole per-run
  cost on four runs out of five: no wiki read, no page edit.
- **Every fifth entry** consolidates: after appending, count the raw file's entry banners (a shell
  `grep -c '^{=====' repo_info/subagent_effectiveness.md` suffices; on a platform without a shell,
  count the banners in the tail you can see). When the count is a multiple of 5 — or the wiki is
  empty or absent — run §Wiki Maintainer over the **newest five entries** and the wiki, and nothing
  else. A consolidating run reads at most the wiki (≤ 3k tokens) and five short entries.
- The Skill Proposer runs only on request (§Skill Proposer), never as part of a normal run.

## File format

`repo_info/harness_wiki.md`, **≤ 3k tokens** (≈12k characters). Created empty by the initialize
workflows and by `cli_setup.sh`; the Maintainer writes the skeleton below on first consolidation
(older installs predate the file).

```md
# Harness Wiki

## Index
<one line per page: `C1 · context · supported · 4 runs · <title>`; last line: `consolidated through <timestamp> · <n> entries`>

## Context utility
### C<n> · <repo_info file[/section]> · <title>
- status: hypothesis | supported | acted (update_logs ID <n>) | refuted
- support: <n> runs — <last 3 timestamps>
- tally: load-bearing <a> · unused <b> · stale <c> · missing <d>
- pattern: <what recurs — the concrete claim relied on, contradicted, or absent>
- fix: <the atomic change: which overview section, initialize step, or budget rule; `none yet` while hypothesis>

## Subagent effectiveness
### S<n> · <role> [<model> · <effort>] · <title>
- status: … · support: …
- tally: adopted Σn/Σm · useful <u> · partly useful <p> · not useful <k> · did not run <z>
- pattern: <what the adopted or rejected items have in common>
- fix: <dial, gate, or agent-definition change>

## Plan utility
### P<n> · <workflow family[/mode]> · <request-size band: ≤2 steps | 3–6 | 7+> · <title>
- status: … · support: …
- tally: steps Σt · as-written Σa · adapted Σb · dropped Σc · added Σd · re-plans Σr · load-bearing <x> · partly <y> · not needed <z>
- pattern: <which kind of plan step gets adapted or dropped, or what the plan keeps catching>
- fix: <strengthen a planning step, or gate planning/challenge by request size>

## Workflow improvement
### W<n> · <workflow family[/step]> · <title>
- status: … · support: …
- tally: friction <f> · remediation Σ<r> · fallbacks Σ<b> · gate pauses Σ<g>
- pattern: <the recurring friction or rework, quoted from the records>
- fix: <one file, one step or dial — the atomic change>

## Skill impact
<one row per proposal: `SI<n> · pages <ids> · target <file/step> · applied <update_logs ID> · metric <tally: before → after> · window <family × 3 runs, <k> seen> · outcome open | accepted | reverted — <reason>`>

## Evolution log
<one line per consolidation: `<timestamp> · entries <from>–<to> · created <ids> · updated <ids> · promoted <ids> · merged/pruned <ids>`>
```

Statuses move forward only: `hypothesis` (support < 3 runs) → `supported` (≥ 3 runs; the page now
carries a concrete `fix:` and is proposal-ready) → `acted` (a proposal citing it was applied; the
update_logs ID is the pointer). Any status may become `refuted` when later records contradict the
page or its proposal was reverted. Pages are patched in place, never rewritten wholesale.

## Wiki Maintainer — consolidation on every fifth entry

With the newest five entries and the wiki in context — nothing else is read — the main agent:

1. **Reads the wiki** whole; writes the skeleton if the file is empty or absent.
2. **Folds every signal of the five entries into a page**, matching on identity (same file, same
   role and dials, same family and size band, same family/step) — never on wording — and creating a
   page only when no match exists:
   - each `context:` token → that file's `C` page: increment the tally; on `stale` or `missing`,
     quote the claim or gap in `pattern:`;
   - each role line → that role × dials `S` page: add its `adopted n/m` and verdict to the tally (a
     `did not run` line counts only under `did not run`);
   - each `plan:` line → that family × size-band `P` page: add its counts and verdict to the tally;
     an `n/a` line touches nothing;
   - each `workflow:` friction item and each non-zero counter → that family/step's `W` page: quote
     the friction verbatim in `pattern:`.
   When two pages turn out to describe one thing, merge them and note it in the Evolution log.
3. **Promotes** a page reaching 3 supporting runs to `supported` and writes its `fix:` as one atomic
   change — one file, one step or dial. A page whose newer records contradict it (a `stale` claim
   `load-bearing` in the 3 runs since; a `not useful` role now `useful` at the same dials; a
   `not needed` plan band now `load-bearing`) becomes `refuted`.
4. **Advances Skill-impact rows** whose validation window covers any of the five entries' families:
   append each entry's value of the row's metric; when the window closes, mark `accepted` (the
   metric moved in the intended direction and no other tally on the cited pages regressed) or
   `reverted — <reason>`. A neutral result extends the window once, then reverts.
5. **Updates the Index** (including its `consolidated through` line), appends one Evolution-log
   line, and **fits the budget** in this order: merge near-duplicate pages; drop `refuted` pages
   older than the last 20 runs; compress `support:` lists to counts plus the last 3 timestamps.

**Status line** — every run, consolidating or not, ends its chat summary with one line:
`harness wiki: appended · next consolidation in <k> runs` or
`harness wiki: consolidated entries <from>–<to> · updated <ids> · proposal-ready <ids or none> · skill-impact <accepted/reverted ids or none>`.

The Maintainer edits `harness_wiki.md` only. It never changes the pack, and it never changes repo
memory — a `stale` overview claim is corrected at the run's documentation step, which already owns
those files, not here.

## Skill Proposer — turning supported pages into pack changes

Runs only when a request targets the pack itself (`workflow/`, `agents/`, `_lib/`, request
templates) **and** names `harness_wiki.md` or its page ids — typically a `code` or `refactor` run
on the HarnessFlow source or on an installed pack. In that run's planning step the main agent:

1. Reads the wiki's Index, Skill impact, and the `supported` pages — ReAct-style, opening a page
   only when the Index makes it relevant — and never the raw layer beyond the entries those pages
   cite.
2. Proposes **atomic** changes — one target file and one step or dial per proposal — each carrying:
   the page ids it acts on; the change; the **metric** it should move, which must be a tally the
   run records already compute (a role's adoption rate at given dials, a file's `stale`/`missing`
   count, a plan band's `not needed` share, a friction item's recurrence, remediation passes); the
   **validation window** (the next 3 recorded runs of the affected workflow family); and the
   acceptance rule of §Wiki Maintainer step 4. A proposal that cannot name a measurable tally is
   not a proposal.
3. Never re-proposes a change whose Skill-impact row is `reverted` unless it names what is different
   now — the rejection history is the wiki's audit trail.
4. On application, adds the row to Skill impact with `outcome open` and sets the cited pages to
   `acted (update_logs ID <n>)`. The wiki is never rolled back: a reverted change keeps its row and
   its pages; only the pack is reverted, by the maintainer, with its own update_logs entry.

The Maintainer and the Proposer are main-agent roles, not subagents: both need exactly what the main
agent already holds (the newest entries, or the planning context), and spawning would only re-send it.
