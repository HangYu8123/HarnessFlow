---
name: 'Skill-Based Correctness Check'
description: 'Unified skill-backed (skill mode) correctness workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast workflow, but the correctness-analysis, challenge, and research instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback. Read-only.'
---
# Examine Existing Repo for Correctness

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - skills/skill_workflow_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Correctness_Check.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: the main agent builds a condensed **[repo context digest]** from **[key md files]**, keeps the files themselves as **[full repo context]**, and passes the digest — plus the excerpts of [full repo context] each subagent's task needs — inline to subagents.

> **Skill-backed variant (skill mode).** Selected step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue. Verified star counts and verification dates live **only** in that registry (single source — re-verify there); do not restate them in this file.

This workflow is read-only — it inspects and reports, and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo
- input 2: target functionalities (optional)
- input 3: important files (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under `repo_info/`, resolved by Pack Path Resolution). Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames. In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). **Every spawn carries two dials, not one:** model from the `subagent_model` header, effort from the `subagent_effort` header (and from `online_researcher_effort` for the Online Researcher). Unless the resolved effort is `inherit`, set the platform effort field where the spawn exposes one, otherwise put the line `effort: <level> — binding budget, not a hint` in the subagent prompt. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files or target functionalities are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, condense the understanding into a **[repo context digest]** (passed inline to subagents, plus the excerpts of [full repo context] each subagent's task needs) and identify [important information] — the most relevant code, scripts, and functionalities. Decide the **scope**: whole-repo (include the full pipeline diagram) or target functionality (include upstream/downstream context).

### Step 2 - Correctness Analysis
**Skill (replaces this step's instructions):** Examine correctness by following **`code-reviewer`** (`Jeffallan/claude-skills:skills/code-reviewer/SKILL.md`) — which analyzes files/diffs for bugs, edge cases, N+1 queries, naming, and architectural concerns with severity-rated findings. Apply it over the in-scope files identified from [important information] (Step 1):
- **Target scope:** focus on the named functionality and its upstream/downstream.
- **Whole-repo scope:** list the relevant files, order them by pipeline flow upstream→downstream, and review them in order.

If the user requested script runs, run the runnable scripts directly in pipeline order and record any errors or unexpected outputs as [run results]. Draft [draft correctness report] from the skill's findings, including all script failures from [run results].
**Fallback if the skill is unavailable:** the main agent uses [important information] (Step 1) to list the relevant files, orders them by pipeline flow, reads them, and examines correctness directly (target or whole-repo scope as above), then drafts [draft correctness report].

### Step 3 - Report Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | **Skill-backed:** run the challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) — a structured critical-reasoning pass over the repo context (per §Context Passing) + [draft correctness report] + [inputs], reading all relevant scripts if needed. Assume every item in the report is wrong and flawed, then explain why — challenge false positives, overlooked issues, misattributed causes, and incorrect assumptions; report only evidence-backed criticisms. Return [challenge report]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate task as written in the fast workflow. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | **Skill-backed:** draft [online resource] by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`) — plan/search/read/synthesize a **cited report** of reliable references and known dependency bugs relevant to [draft correctness report] + [inputs]. The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof — never answer from prior knowledge (see `agents/online-researcher.agent.md`). **Fallback if `deep-research` is unavailable:** perform the Online Researcher task as written in the fast workflow. |

### Step 4 - Final Correctness Report
The main agent incorporates [challenge report] and [online resource] (when produced), prioritizing codebase evidence over external sources, and finalizes the correctness report. Print it.

### Step 5 - Documentation
1. Append to past_Correctness_Check.md, using the existing contents to determine the last CC ID (create if missing):
```md
{=============================Correctness Check: (current time, YYYY-MM-DD HH:MM) — (last CC ID + 1)===============================}
Incorrect: (one sentence summary)
Potential Cause: (brief precise bullet points)
```
2. Cross-check known_issues.md. If any found problems were marked as fixed there, add: "the attempted fix actually failed."
