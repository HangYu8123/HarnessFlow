# Plan Adherence — Final Plans Are Binding Guidance

Canonical rule for every implementation/execution step that consumes a finalized plan
([final plan], [final bug fix plan], [final pr plan]). The workflow files reference this
file instead of restating it. It binds whoever performs the planned work — the main agent
when it implements/executes directly, and any Implementer/Executor subagent (the spawn
prompt names this file alongside the plan).

## Principle

A finalized plan is **binding guidance, not an immutable script**. Its **goal, scope,
success criteria, and safety/approval constraints are fixed**. Its step-level detail is the
best prediction available before touching the real code — a pre-generated plan is never
guaranteed 100% correct against the actual codebase, environment, and outputs.

## Follow the plan, but keep thinking

- **Follow the plan**: work through it step by step; never wander into unrequested work.
- **Keep judgment active**: before and while applying each step, check its assumptions
  against what the code, files, and command/test outputs actually show.
- **When evidence contradicts a step**, neither force the plan through nor silently
  improvise: apply the **smallest adaptation that achieves the step's intent** while
  staying inside the plan's goal, scope, and constraints.
- **Not adaptable**: anything that would change the goal, scope, success criteria, or an
  approval-gated decision. The main agent stops and re-plans (re-running the
  plan-challenge step when the change is material); a subagent returns `status: blocked`
  with the reason. An adaptation that introduces a **destructive, irreversible, or
  outward-facing action the plan did not contain** is never in-scope — treat it as a pause
  point per `_lib/approval_gate.md` and the workflow's own guards.
- **Boundary note:** this rule governs plan-content-vs-reality mismatches. The
  wait/cache-resume rule in `_lib/stay_active.md` ("re-execute safely per [final plan]" on
  a work-identity mismatch) is a different mechanism and is unaffected.

## The thoughts artifact — [implementation thoughts] / [execution thoughts]

While implementing (label **[implementation thoughts]**) or executing planned actions
(label **[execution thoughts]**), record one concise entry per point where thinking was
needed:

- what the plan expected → what was actually found (evidence: file/line, or the command
  and its output) → what was done instead → why (intent preserved, risk accepted);
- plan steps found wrong, unnecessary, or incomplete — even when no change resulted;
- surprises and noteworthy observations reviewers should see.

The implementation/execution **report stays "changes only, no explanations"** — the
thoughts artifact is the separate reasoning channel. **Always produce the label**: when the
plan held throughout, record exactly `none — plan held as written`.

## Tally

The thoughts artifact **ends with one line** counting the plan's steps (actions, PRs, or loop
iterations) by outcome — `tally: steps <t> · as-written <a> · adapted <b> · dropped <c> · added <d>`
— counted as the work proceeds, never reconstructed afterwards. It costs one line and is the
only source of the run record's `plan:` line (`_lib/subagent_effectiveness.md` §Plan line),
which is how the pack learns, across runs, whether planning earns its tokens.

## Hand-off to review

Whoever implemented/executed returns the thoughts artifact **alongside** the report
(subagents: `output_label: [implementation report] and [implementation thoughts]` — return
both, never drop one; see `_lib/subagent_contract.md` §Result Format). The main agent then
passes the thoughts artifact to **every** review/validation consumer that receives the
report. Reviewers treat recorded deviations as the **highest-priority review targets**: a
deviation is work the plan-stage challenge never saw.

## Nested-skill note (skill family)

Where an external plan-execution skill (e.g. `executing-plans`) says to stop and ask on a
plan-reality mismatch, this rule plus the approval gate's autonomous mode apply instead:
adapt in-scope mismatches with recorded reasoning; escalate only non-adaptable ones.
