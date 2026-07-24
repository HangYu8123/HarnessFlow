---
name: 'Code Implementation'
description: 'Instructions for implementing, updating, and adding new functionalities'
---
# Add New Functions to an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

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

[inputs]:
- input 1: target functionalities
- input 2: important files (optional)
- input 3: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved by the Pack Path Resolution rule). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). **Every spawn carries two dials, not one:** model from the `subagent_model` header, effort from the `subagent_effort` header (and from `online_researcher_effort` for the Online Researcher). Unless the resolved effort is `inherit`, set the platform effort field where the spawn exposes one, otherwise put the line `effort: <level> — binding budget, not a hint` in the subagent prompt.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering and Local Skill Discovery
Read [key md files]. Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.

If preferred files are specified, the main agent must read through the preferred files, then combine the understood knowledge with [key md files].

**Local Skill Discovery (before any plan drafting):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` — scan `skills/index.md` for any local skill whose trigger fits [inputs]/the task; on a confirmed match, read its `SKILL.md`. Keep the result as [local skills], fold it into the repo context (per §Context Passing) so every planning subagent receives it, and integrate it when the main agent drafts its final plan. If nothing matches, record [local skills]: none relevant.

### Step 2 - Implementation Analysis Panel
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [inputs] and the repo context (per §Context Passing) to all three subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Focus analysis | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Always | Process [inputs] and the repo context (per §Context Passing), and analyze what the new functionalities are, how to integrate them into the existing codebase, and what scripts and files could be associated. Read through the highly associated files and scripts. Draft a plan that integrates the new functionalities into the existing codebase and draft a diagram, while maintaining the codebase stable, avoiding known issues from known_issues.md. Return [plan 1] and [diagram 1]. |
| Broad analysis | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Always | Follow the pipeline diagram from the repo context (per §Context Passing), read through all scripts from upstream to downstream. Analyze what the new functionalities are, how to integrate them, and what scripts and files could be associated. Draft a plan and diagram that integrates the new functionalities while maintaining the codebase stable and avoiding known issues. Return [plan 2] and [diagram 2]. |
| Free analysis | **Free Analyst** (`agents/free-analyst.agent.md`) | Always | Process [inputs] and the repo context (per §Context Passing), then decide what files to read and scripts to check, following its own logic. Analyze what the new functionalities are and how to integrate them while maintaining codebase stability. Return [plan 3]. |

### Step 3 - Senior Engineer Plan Review
The main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), passing all three plans [plan 1], [plan 2], and [plan 3], the implementation diagrams [diagram 1] and [diagram 2], [inputs], and the repo context (per §Context Passing). The subagent reads associated scripts in this repo. If the plan involves any repo outside this repo, go to that repo and read their codebase_overview.md and scripts_overview.md if they exist. Then the subagent reviews all plans and diagrams from a senior staff engineer perspective, assesses correctness and feasibility, rejects redundant or incorrect plans, and verifies the plan achieves the new functionalities without breaking existing behavior. Feed the [senior staff engineer review] back to the main agent.

### Step 4 - Draft the Final Plan
The main agent reviews the plans and implementation diagrams from Step 2 and [senior staff engineer review], and reads necessary files. If the plans or the review involve any other repos, go to those repos, read their codebase_overview.md and scripts_overview.md if they exist, and keep those in the memory. Finally, combine all that information and draft a [final plan] that is feasible, stable, and verified against existing tests and behavior.

### Step 5 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final plan], the input functionalities from [inputs], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read all relevant scripts, then critically challenge [final plan] — looking for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions. Return flaws as [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Identify extra needs for skills, tools, and packages. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |

### Step 6 - Incorporate Criticisms
The main agent incorporates [valid criticisms] and [online resource], and updates [final plan] accordingly.

### Step 7 - Print Plan and Approval Gate
The main agent prints the updated [final plan], so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

### Step 8 - Implementation
The main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), passing [final plan], the target functionalities, and the repo context (per §Context Passing). **Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback (on Claude Code the main agent launches the Implementer on the specified `subagent_model` — a specific id even if smaller, else the inherited session model; no retry loop). The subagent (or the main agent, if falling back) uses the repo context (per §Context Passing) for codebase context. Then based on [final plan] and the target functionalities, identify what files and scripts are associated with the implementation. Then the subagent must read through all those identified files and scripts to get a detailed understanding of them. Then the subagent starts implementing the code based on [final plan] and the target functionalities. During the implementation, the subagent must follow [final plan] and implement the new functionalities correctly, verifying against existing tests and behavior. After finishing the implementation, the subagent must generate an [implementation report] (just what has been changed, **no explanation**), and report [implementation report] back to the main agent.

### Step 9 - Post-Implementation Review (platform-conditional)
- **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely.
- **When a header is `true` and the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — it is the only caller of the native `/simplify` and `/code-review`; do not invoke either separately. (`/code-review` additionally requires that the implementation changed code files.)
- **When a header is `local` (any platform, no Claude Code dependency):** skip that wrapper skill and spawn the local-skill subagent directly per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `skills/code-simplification/SKILL.md` for `simplify`, `skills/code-review-and-quality/SKILL.md` for `code_review`.
- **Otherwise (`true` on Codex, or VS Code Copilot without Claude Code skills):** the native skills do not exist — skip them; instead, the main agent performs a manual review of all changed files for unnecessary complexity and redundancy before proceeding.

### Step 10 - Implementation Review and QA
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final plan], target functionalities, [implementation report], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Code review | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Always | Check all the code changes in the repo. Review the code changes and the implementations from a senior staff engineer perspective: assess correctness, challenge the implementations, question the effectiveness, verifying that the new functionalities are achieved without breaking existing behavior. Return [implementation code review report]. |
| QA validation | **QA Engineer** (`agents/qa-engineer.agent.md`) | Always | Check all the code changes in the repo. Read through the entire repo pipeline and validate the implementations from a QA engineer perspective; generate an [implemented code QA report]. If the user has requested to actually **run the scripts**, run through the entire codebase pipeline from upstream to downstream, and validate whether the entire repo still performs correctly and the newly implemented functionalities perform as expected without errors; update the report based on the running results. Return [implemented code QA report]. |

### Step 11 - Update Overview Docs
The main agent reads through [final plan], [implementation report], [implementation code review report], and [implemented code QA report], then understands the code changes, the implementation, and the changes to the codebase. Then the main agent updates codebase_overview.md and scripts_overview.md based on the newly implemented functionalities and the actual code changes (including the failures based on [implementation code review report] and [implemented code QA report]).

### Step 12 - Summarize the Implementation
The main agent summarizes the implementation in the following format, for each new functionality:
```md
{=============================Function Update===============================}
{functionality Name (very high level description of the functionality), Timestamp (fill the current time here, YYYY-MM-DD HH:MM), and functionality Id (assign a number in order, i.e., plus 1 to the last functionality id)}
{functionality description (one or two sentences of description of what the functionality is)}
{Repo involved (what local repos are involved)}
{Implementation (what has been implemented to achieve the functionality)}
{Achieved (whether the functionality has been achieved, if not achieved, what is the gap)}
```

### Step 13 - Write Logs and Chat Summary
Write the Function Update summary to update_logs.md. Do not add additional contents, just the function update report from Step 12. In addition, summarize the implementation changes in bullet points and write them to the chat.
