---
name: 'Debug Workflow'
description: 'Instructions for debugging and fixing bugs'
---
# Debug Instructions

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

[inputs]:
- input 1: target bug
- input 2: suspected reasons (optional)
- input 3: important scripts (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

---

## CREATE ONE TODO PER STEP

### Step 0 (Optional) - Reproduce the Bug
Skipped by default; run only if `reproduce: true` is set in the debug request.

The main agent spawns a **Bug Reproducer** subagent (`agents/bug-reproducer.agent.md`). The subagent must: (1) read [key md files] and [inputs] to identify the target scripts and entry points associated with the bug; (2) run those scripts in the correct order per `scripts_overview.md` to exercise the bug path; (3) capture all output (stdout, stderr, exit codes, error messages, tracebacks); (4) summarize whether the bug was reproduced, what output was observed, and any relevant runtime state; (5) return the summary to the main agent as **[reproduction report]**. The main agent stores [reproduction report] and passes it to all subsequent analysis subagents.

### Step 1 - Context Gathering and Local Skill Discovery
Read [key md files]. Understand the structure of the repo, functions inside each script, previous updates, and previous bug fix attempts. **KEEP THESE IN THE MEMORY.** Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run.

Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, create a condensed **[repo context digest]** — a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes — and pass it, plus the excerpts of [full repo context] each subagent's task needs, inline to every subagent.

**Local Skill Discovery (before any plan drafting):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` — scan `skills/index.md` for any local skill whose trigger fits [inputs]/the task; on a confirmed match, read its `SKILL.md`. Keep the result as [local skills], fold it into the repo context (per §Context Passing) so every planning subagent receives it, and integrate it when the main agent drafts its final plan. If nothing matches, record [local skills]: none relevant.

### Step 2 - Prior-Fix Check
The main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`), passing [inputs] and the repo context (per §Context Passing). The subagent checks if the bug has previously been addressed or fixed based on the repo context. If a previous attempt exists, the subagent follows the codebase diagram from codebase_overview.md and goes through all scripts associated with the previous fix attempts. Then, combining the current bug information, the subagent infers why the bug is not fixed, and reports back to the main agent.

### Step 3 - Bug Analysis Panel
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [inputs] and the repo context (per §Context Passing) to all three subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Focus analysis | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Always | Focus on the important scripts and suspected reasons, read through those scripts, and check the potential reasons for the bug from the perspective of those scripts and suspected reasons. Return [bug reason 1]. |
| Broad analysis | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Always | Follow the pipeline diagram from [key md files], read through all scripts from upstream of the diagram to downstream, and check the potential reasons for the bug from a broader perspective. Return [bug reason 2]. |
| Free analysis | **Free Analyst** (`agents/free-analyst.agent.md`) | Always | Decide what files to read and what scripts to check, following its own logic, and check the potential reasons for the bug from a completely free perspective. Return [bug reason 3]. |

### Step 4 - Evidence-Based Diagnosis (platform-conditional)
- **If the main agent is Claude Code:** create a **Diagnosis subagent** (`agents/focus-analyst.agent.md`, diagnosis mode): pass the bug description, suspected reasons, and the repo context (per §Context Passing). The subagent re-runs the suspected code path with verbose/debug flags where possible and reads the actual stdout/stderr/tracebacks (and any existing log output) to identify exactly what went wrong, producing concrete evidence to supplement the Step 3 analysis. (Do not rely on a `/debug` skill — it is not a standard Claude Code skill.) Report back a [debug log analysis] to the main agent.
- **Otherwise (Codex or VS Code Copilot):** the main agent reviews the relevant error output, stack traces, and any existing logs manually to reach the same diagnosis, and documents the root causes as [debug log analysis].

### Step 5 - Synthesize Diagnosis
The main agent reads all three reports from Step 3 ([bug reason 1], [bug reason 2], [bug reason 3]), [debug log analysis] from Step 4, and [reproduction report] if it exists. Read necessary files, understand each report, examine all pointed-out potential reasons, combine the insights of each report, reject the redundant or incorrect parts of each report, and draft a precise and verified correct report addressing the potential reasons for the bug as [bug info].

### Step 6 - Diagnosis Challenge and Research (Round 1)
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [bug info], the original bug description, and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Critically challenge [bug info] — look for overlooked root causes, misattributed blame, or incorrect assumptions. Return flaws as [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Identify extra needs for skills, tools, packages, logs, error messages, or external references. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |

### Step 7 - Incorporate Round-1 Criticisms
The main agent incorporates [valid criticisms] and [online resource], and updates [bug info] accordingly. Record **[criticism dispositions]** — one line per round-1 criticism stating whether and how it was addressed (or why it was rejected) — for the round-2 challenge in Step 11.

### Step 8 - Draft the Bug Fix Plan
The main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`) in plan mode, passing [inputs], [bug info], and the repo context (per §Context Passing). Based on the bug information and the repo structure from the repo context, the subagent reads all scripts that could be associated with the bug. Then the subagent drafts a plan that can fix the bug while maintaining the entire codebase behavior, while maintaining stability, and NO repeat of any known issues/bugs in known_issues.md. The subagent feeds the plan back to the main agent as [bug fix plan].

### Step 9 - Senior Engineer Plan Review
The main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), passing [bug fix plan], [bug info], and the repo context (per §Context Passing). The subagent reads associated scripts in this repo. If the plan involves any repo outside this repo, go to that repo; if there are codebase_overview.md and scripts_overview.md, read through them too. Then the subagent reviews the plan from a senior staff engineer perspective, assesses the plan's correctness and feasibility, and makes sure that the plan can effectively fix the bug without breaking the current codebase. Feed the review back to the main agent as [bug fix plan review].

### Step 10 - Draft the Final Plan
The main agent reviews [bug fix plan] and [bug fix plan review] from Steps 8 and 9. If the plan or the review involves any other repos, go to those repos, read their codebase_overview.md and scripts_overview.md if they exist, and keep those in the memory. Finally, combine all that information and draft a final plan that is feasible, stable, and verified against existing tests and behavior as [final bug fix plan].

### Step 11 - Plan Challenge and Research (Round 2)
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final bug fix plan], [bug info], [valid criticisms], [criticism dispositions], and the repo context (per §Context Passing) to all three subagents.

> Round 2 deliberately receives round 1's output: it audits how round-1 criticisms were resolved instead of independently re-litigating them, and it challenges a different artifact (the plan, not the diagnosis). Multi-agent-debate results show additional rounds give diminishing returns unless they build on prior output while preserving a fresh perspective — hence the two separate checks below.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Read all relevant scripts, then run two separate checks: **(a) resolution audit** — for each round-1 criticism in [valid criticisms], verify against [criticism dispositions] that it actually survived into [final bug fix plan]; flag any criticism claimed addressed but not reflected in the plan. **(b) fresh challenge** — independently challenge [final bug fix plan] for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions that are new at the plan level (do not re-litigate round-1 items that were properly addressed). Return both as [valid criticisms round 2]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Based on [final bug fix plan], identify extra needs for skills, tools, and packages. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |
| Diversify | **Diversifier** (`agents/diversifier.agent.md`) | `diversifier: on` · default `on` | Process [bug info], [final bug fix plan], and the repo context (per §Context Passing), and read the files [final bug fix plan] touches. Then propose 5 alternative fix plans that each resolve the bug — including one **risky**, one **aggressive**, and one **rare** — each structurally different from [final bug fix plan] and from each other, each carrying a calibrated `P(better)` that it beats [final bug fix plan]. Return [diverse plans]. |

### Step 12 - Incorporate Round-2 Criticisms
The main agent incorporates [valid criticisms round 2] and [online resource], and updates [final bug fix plan] accordingly. When [diverse plans] was produced, it weighs them: where an alternative's `P(better)` and evidence show it beats [final bug fix plan], adopt it — or graft in the part of it that wins — and restate [final bug fix plan] on that basis; otherwise keep [final bug fix plan] and record in one line why the alternatives were not taken.

### Step 13 - Print Plan and Approval Gate
The main agent prints the updated [final bug fix plan], so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

### Step 14 - Implementation
The main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), passing [final bug fix plan], [bug info], and the repo context (per §Context Passing). **Implementer Model Verification:** See [`_lib/implementer_fallback.md`](../../_lib/implementer_fallback.md) (on Claude Code the main agent launches the Implementer on the specified `subagent_model` — a specific id even if smaller, else the inherited session model; no retry loop). The subagent (or the main agent, if falling back) receives the repo context (per §Context Passing). Then based on [bug info], [final bug fix plan], and the repo structure from the repo context, read all scripts that could be associated with the bug and the plan. Then implement [final bug fix plan] and fix the bug accordingly. Feed an implementation report (just what has been changed, no explanation why it would fix the bug) to the main agent as [bug fix implementation report].

### Step 15 - Post-Implementation Review (platform-conditional)
- **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely.
- **When a header is `true` and the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — it is the only caller of the native `/simplify` and `/code-review`; do not invoke either separately. (`/code-review` additionally requires that the implementation changed code files.)
- **When a header is `local` (any platform, no Claude Code dependency):** skip that wrapper skill and spawn the local-skill subagent directly per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `skills/code-simplification/SKILL.md` for `simplify`, `skills/code-review-and-quality/SKILL.md` for `code_review`.
- **Otherwise (`true` on Codex, or VS Code Copilot without Claude Code skills):** the native skills do not exist — skip them; instead, the main agent performs a manual review of all changed files for unnecessary complexity and redundancy before proceeding.
- **Parallel launch (speed-for-accuracy trade):** launch **every** review subagent this step spawns — the native wrapper's, or the `local` ones — **in parallel, including simplify** (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback). Simplify writes the working tree while the reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before applying anything. Degrade to sequential (simplify first) only if parallel launch is unavailable.

### Step 16 - Implementation Review and QA
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final bug fix plan], [bug fix implementation report], [bug info], [inputs], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Code review | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Always | Check all the code changes in the repo. Review the code changes and the implementations for bug fixing from a senior staff engineer perspective: assess the bug fix correctness, challenge the implementation, question the effectiveness of the implementation, and make sure the bug fix implementations achieve the intended fix without breaking the current codebase. Return [implementation code review report]. |
| QA validation | **QA Engineer** (`agents/qa-engineer.agent.md`) | Always | Check all the code changes in the repo. Read through the entire repo pipeline and validate the bug fix from a QA engineer perspective; generate an [implemented bug fix code QA report]. If the user has requested to actually **run the scripts**, run through the entire codebase pipeline based on codebase_overview.md and scripts_overview.md from upstream to downstream, and validate whether the entire repo still performs correctly and the newly implemented bug fixes perform as expected without errors; update the report based on the running results. Return [implemented bug fix code QA report]. |

### Step 17 - Update Overview Docs
The main agent reads through [final bug fix plan], [bug fix implementation report], [implementation code review report], [implemented bug fix code QA report], and [inputs], then understands the bug fixes, the implementation, and the changes to the codebase. Then the main agent updates codebase_overview.md and scripts_overview.md based on the newly implemented bug fixes and the actual code changes (including the failures based on [implementation code review report] and [implemented bug fix code QA report]).

### Step 18 - Summarize the Bug Fix
The main agent summarizes the bug fix in the following format:
```md
{=============================BUG FIX===============================}
{BUG Name (very high level description of the bug), Timestamp (fill the current time here, YYYY-MM-DD HH:MM), and Bug Id (assign a number in order, i.e., plus 1 to the last bug id)}
{Bug description (one or two sentences of description of what the bug is)}
{Repo involved (what local repos are involved)}
{Implementation (what has been changed to fix the bug)}
{Fixed (whether the bug has been fixed, if not fixed, what is the gap)}
```

### Step 19 - Write Logs
Write the summary to update_logs.md per `_lib/doc_logging.md` (timestamps, IDs, two-file rule). Do not add additional contents, just the bug fix report from Step 18. If the bug is a recurring issue that has been attempted and failed to fix multiple times, also write to known_issues.md in the following format:
```md
{Problem Title}
a. What was not fixed: (a brief explanation of what remains broken)
b. Last attempt summary: (a brief summary of the last fix attempt)
c. Why the last fix failed: (a brief analysis of why the previous fix failed, including what mistakes the coding agent made)
d. Current fix: (a brief description of the current fix being applied)
```

### Step 20 - Chat Summary
The main agent summarizes [final bug fix plan], [bug fix implementation report], [implementation code review report], and [implemented bug fix code QA report] in bullet points and writes them to the chat.
