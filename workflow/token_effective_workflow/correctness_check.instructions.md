---
name: 'Fast Correctness Check'
description: 'Unified token-effective (fast) correctness workflow for Claude Code, Codex, and VS Code Copilot: main-agent scope-driven inspection with optional script runs, then one parallel challenge + research + diversify subagent step. Read-only.'
---
# Examine Existing Repo for Correctness

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/subagent_effectiveness.md
  - _lib/harness_wiki.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Correctness_Check.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - agents/diversifier.agent.md
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

This workflow is read-only — it inspects and reports, and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo
- input 2: target functionalities (optional)
- input 3: important files (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under `repo_info/`, resolved by Pack Path Resolution). Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames. In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files or target functionalities are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, condense the understanding into a **[repo context digest]** (passed inline to subagents, plus the excerpts of [full repo context] each subagent's task needs) and identify [important information] — the most relevant code, scripts, and functionalities. Decide the **scope**: whole-repo (include the full pipeline diagram) or target functionality (include upstream/downstream context).

### Step 2 - Correctness Analysis
**Diversifier — spawn first, from the goal (gate `diversifier: on` · default `on`):** before examining anything, write [invariants] per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Diversifier Contract (for a correctness check: no code changes, checks only within the chosen scope, script runs only where the user requested them) and spawn the **Diversifier** (`agents/diversifier.agent.md`) on [inputs] + [important information] + the repo context (per §Context Passing) + [invariants] — never on [draft correctness report], which does not exist yet and is never sent to it later. Task: the request every alternative must fulfill is *surface any remaining correctness defect in scope*, and the `expected default:` is fixed — "a linear pipeline-order read of the in-scope files" — write it verbatim. Find **new angles to check correctness — ways the code could be wrong or unsafe**: each of the 3–5 alternatives is a different **checking route** (quality floor per the agent definition — report an archetype with no viable route rather than filling it) whose steps are checks to run, never code changes, and the routes must differ structurally (execution path · input and data type · state/transition assumption · concurrency and ordering · resource limit or starvation · interruption and partial failure · trust boundary · error path). Read the three mandatory archetypes as checking depth — **risky** = pays off only if a named assumption is wrong; **aggressive** = the broadest, most expensive check (full-pipeline instrumentation, exhaustive input sweep), still no code change; **rare** = an unconventional checking technique. `P(better)` is the calibrated probability that the route exposes a real defect a linear read misses; an unchecked area of the repo is the gap that licenses a high number. Emit every angle as an **unverified hypothesis for the main agent to check**, never as an asserted defect. Read `graftable:` as the single cheapest check from the route worth keeping even if the route as a whole is not taken; `preserves:` confirms the route stays within [invariants]. Return [diverse angles]. Do not wait for it: examine correctness while it runs and collect the result at Step 4.

Based on the repo context (per §Context Passing) + [important information] + the chosen scope, the main agent lists the relevant files, orders them by pipeline flow, reads them, and examines correctness:
- **Target scope:** focus on the named functionality and its upstream/downstream.
- **Whole-repo scope:** traverse the full pipeline upstream→downstream.

If the user requested script runs, run the runnable scripts directly in pipeline order and record any errors or unexpected outputs as [run results].

Draft [draft correctness report], including all script failures from [run results].

### Step 3 - Report Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Step 2's Diversifier spawn and this step are the only subagent launches.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Read the repo context (per §Context Passing) + [draft correctness report] + [inputs], and all relevant scripts if needed. Assume every item in the report is wrong and flawed, then explain why — challenge false positives, overlooked issues, misattributed causes, and incorrect assumptions. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Read the repo context (per §Context Passing) + [draft correctness report] + [inputs]. Actually call the platform's live web search/fetch tool(s) (never answer from prior knowledge) to find reliable references and known dependency bugs, returning the source URLs as proof. Return [online resource]. |

### Step 4 - Final Correctness Report
The main agent incorporates [challenge report] and [online resource] (when produced), prioritizing codebase evidence over external sources. When [diverse angles] was produced, it dispositions every angle against the checks its own draft already covers per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Diversifier Contract → Pick — `adopt` (run the route, running scripts only where the user requested script runs, and fold its result into the report) · `adopt-part <check>` · `same-as-draft` · `park` (to `known_issues.md` §Untaken options) · `reject <reason>` — one line each, working the adopted ones down by `P(better)`. Finalize the correctness report. Print it.

### Step 5 - Documentation
1. Append to past_Correctness_Check.md, using the existing contents to determine the last CC ID (create if missing):
```md
{=============================Correctness Check: (current time, YYYY-MM-DD HH:MM) — (last CC ID + 1)===============================}
Incorrect: (one sentence summary)
Potential Cause: (brief precise bullet points)
```
2. Cross-check known_issues.md. If any found problems were marked as fixed there, add: "the attempted fix actually failed."

### Step 6 - Run Record and Wiki Maintainer
Append the [run record] to `repo_info/subagent_effectiveness.md` per [`_lib/subagent_effectiveness.md`](../../_lib/subagent_effectiveness.md), written only from what you already hold — never re-read an artifact or the file: one short line per spawned advisory role (dials `[model · effort]`, `adopted n/m`, novelty/importance, verdict — effect, never activity; executing roles only on fallback or rework), then `context:` (which `repo_info/` files were load-bearing, unused, stale, or missing, from the notes kept since Step 1), `plan:` (`n/a` — this workflow has no plan artifact), and `workflow:` (friction as `step — problem → fix`, or `none`, plus remediation / fallback / gate-pause counters). Then the **Wiki Maintainer** pass per [`_lib/harness_wiki.md`](../../_lib/harness_wiki.md) §Cadence: on every fifth entry consolidate the newest five into `repo_info/harness_wiki.md`; otherwise nothing more. End the chat summary with the one-line wiki status.
