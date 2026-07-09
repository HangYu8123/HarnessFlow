---
name: 'Code Refactor'
description: 'Instructions for refactoring existing scripts, repositories, and functionalities'
---
# Refactor an Existing Repo

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
-->

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: target refactor functionalities, repository, or scripts
- input 2: target files (optional)
- input 3: target repo (optional)

Inputs specify the refactor targets.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, create a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues — then pass [inputs], [key md files], and [repo context digest] to subagents.

If input 1 or input 2 are specified in [inputs], the main agent must read through the files associated with [inputs], then combine the understood knowledge with [key md files].

### Step 2 - Refactor Analysis Panel
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [inputs] and the repo context (per §Context Passing) to all six subagents. Each subagent first processes the refactor targets and the repo context (per §Context Passing).

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Architecture | **Architecture Analyst** (`agents/architecture-analyst.agent.md`) | Always | Based on the current code/repo/architecture and the refactor targets from [inputs], analyze: 1) what functionalities and scripts must be refactored and why; 2) what functionalities are inappropriately designed/placed in the existing codebase and why; 3) how to improve the code architecture of the existing codebase/scripts and what the improvements are compared to the current code architecture. Draft an initial plan (what can be improved, why it must be improved, and the consequences of the improvements). Then read through the associated files and scripts, specifically focused on validating and improving the initial plan, and finalize the plan that improves the architecture of the existing codebase/scripts/functionalities. Draft a comparison statement showing how the code architecture is improved based on the original codebase diagram. The plan must keep the entire codebase stable, while maintaining stability, and NO repeat of any known issues/bugs in known_issues.md. Return [plan 1] and [comparison statement 1]. |
| Redundancy | **Redundancy Analyst** (`agents/redundancy-analyst.agent.md`) | Always | Based on the current code/repo/architecture and the refactor targets from [inputs], analyze: 1) what functionalities and scripts have redundancy and why; 2) whether there are overlapped implementations in the existing codebase/scripts/code and why they overlap; 3) how to reduce the redundancy of the existing codebase/scripts and what the improvements are compared to the current codebase/scripts. Draft an initial plan (what can be improved/removed, why, and the consequences of the improvements/removals). Then read through the associated files and scripts, specifically focused on validating and improving the initial plan, and imagine what would happen if the planned redundancies are removed. Finalize the plan that reduces the redundancy of the existing codebase/scripts/functionalities, and draft a comparison statement showing how the redundancy is reduced based on the original codebase/scripts. The plan must keep the entire codebase stable, while maintaining stability, and NO repeat of any known issues/bugs in known_issues.md. Return [plan 2] and [comparison statement 2]. |
| Robustness | **Robustness Analyst** (`agents/robustness-analyst.agent.md`) | Always | Based on the current code/repo/architecture and the refactor targets from [inputs], analyze: 1) what functionalities and scripts have robustness issues and why; 2) whether there are potential bugs or issues in the existing codebase/scripts/code and why; 3) how to improve the robustness of the existing codebase/scripts and what the improvements are compared to the current codebase/scripts. Draft an initial plan (what can be improved, why it must be improved, and the consequences of the improvements). Then read through the associated files and scripts, specifically focused on validating and improving the initial plan, and imagine what would happen if the planned improvements are implemented. Finalize the plan that improves the robustness of the existing codebase/scripts/functionalities, and draft a comparison statement showing how the robustness is improved based on the original codebase/scripts. The plan must keep the entire codebase stable, while maintaining stability, and NO repeat of any known issues/bugs in known_issues.md. Return [plan 3] and [comparison statement 3]. |
| Free analysis | **Free Analyst** (`agents/free-analyst.agent.md`) | Always | Process [inputs] and the repo context (per §Context Passing). Decide what files to read and what scripts to check, based on the known information. Analyze what the refactor targets are, how to refactor the existing codebase, and what scripts and files could be associated with the refactor targets. Draft a plan that refactors the existing codebase while maintaining the entire codebase stable. Return [plan 4]. |
| Code review | **Senior Engineer** (`agents/senior-engineer.agent.md`, code review mode) | Always | Based on [inputs] and the repo structure from the repo context (per §Context Passing), decide a list of files and scripts that could be associated with [inputs] and the refactor targets as [associated files]. Read files **LINE BY LINE** from [associated files] from a senior engineer perspective. While reading, if any files or scripts are found to be highly associated with the refactor targets, add them to [associated files] and read through them as well. After finishing reading one file from [associated files], add the read file into [read files]. Once [read files] and [associated files] are the same, the reading is finished. Then review the code from a senior engineer perspective, finding what is weak in terms of code quality, readability, maintainability, and robustness. Draft a code review report of the issues in the existing codebase/scripts/functionalities as [code issue review report], and what can be improved, why it must be improved, and how to improve it as [code improvement review report]. Return both reports. |
| Complexity | **Complexity Analyst** (`agents/complexity-analyst.agent.md`) | Always | Perform **read-only analysis only** — do NOT apply edits or run `/simplify` before the approval gate (any actual simplification is deferred to the post-approval skill step) (on Claude Code with skills, actual simplification is deferred to the post-approval skill step and `/simplify` must NOT run before the gate; on Codex or VS Code Copilot without Claude skills, no `/simplify` is available and the analyst performs the same complexity analysis directly). Identify: 1) unnecessary complexity in functions, modules, and scripts and why they are overly complex; 2) simplifiable logic paths that can be reduced without changing underlying behavior; 3) over-engineered abstractions that are convoluted and how they can be flattened or clarified. Draft an initial plan (what can be simplified, why it must be simplified, and the consequences of the simplifications). Then read through the associated files and scripts, specifically focused on validating that each proposed simplification preserves existing behavior. Finalize the plan that reduces the complexity of the existing codebase/scripts/functionalities, and draft a comparison statement showing how the complexity is reduced based on the original codebase/scripts. The plan must keep the entire codebase stable, while maintaining stability, and NO repeat of any known issues/bugs in known_issues.md. Return [plan 5] and [comparison statement 5]. |

### Step 3 - Principal Engineer Plan Review
The main agent creates a **Principal Engineer** subagent (`agents/principal-engineer.agent.md`), passing the refactor targets, all the plans ([plan 1], [plan 2], [plan 3], [plan 4], and [plan 5]), the comparison statements ([comparison statement 1], [comparison statement 2], [comparison statement 3], and [comparison statement 5]), the code review reports ([code issue review report] and [code improvement review report]), [inputs], and the repo context (per §Context Passing). The subagent reads associated scripts in this repo. If the plan involves any repo outside this repo, go to that repo; if there are codebase_overview.md and scripts_overview.md, read through them too. Then the subagent reviews all plans, comparison statements, and code review reports from a principal engineer perspective, assesses their correctness and feasibility, rejects redundant or incorrect plans, and makes sure that the plan can achieve the refactor targets without breaking the current codebase. Feed the [plan review] back to the main agent.

### Step 4 - Draft the Final Plan
The main agent reviews all the plans ([plan 1], [plan 2], [plan 3], [plan 4], and [plan 5]), the comparison statements ([comparison statement 1], [comparison statement 2], [comparison statement 3], and [comparison statement 5]), the code review reports ([code issue review report] and [code improvement review report]) from Step 2 and [plan review] from Step 3, and reads necessary files. If the plans, comparison statements, code review reports, or [plan review] involve any other repos, go to those repos, read their codebase_overview.md and scripts_overview.md if they exist, and keep those in the memory. Finally, combine all that information and draft a [final plan] that is feasible, stable, and verified against existing tests and behavior. Then the main agent must go through [final plan]: for each step in [final plan], read through the associated code and scripts, imagine what would happen if the step is implemented, examine correctness, and make sure the changes would not break the current codebase. If any step in [final plan] is problematic, revise [final plan] accordingly, and make sure the revised [final plan] can achieve the refactor targets without any issues.

### Step 5 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final plan], the refactor targets from [inputs], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read all relevant scripts, then critically challenge [final plan] — looking for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions. Return flaws as [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Based on the refactor targets, identify extra needs for skills, tools, packages, patterns, or migration references. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |

### Step 6 - Incorporate Criticisms
The main agent incorporates [valid criticisms] and [online resource], and updates [final plan] accordingly.

### Step 7 - Print Plan and Approval Gate
The main agent prints the updated [final plan], so the user can read it later. **Approval gate:** See `_lib/approval_gate.md`.

### Step 8 - Implementation
The main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), passing [final plan], the refactor targets, and the repo context (per §Context Passing). **Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback (on Claude Code the main agent launches the Implementer on the specified `subagent_model` — a specific id even if smaller, else the inherited session model; no retry loop). The subagent (or the main agent, if falling back) uses the repo context (per §Context Passing). Then based on [final plan] and the refactor targets, read all scripts that are associated with [final plan]. Then the subagent implements [final plan] and achieves the refactor targets accordingly. After finishing the implementation, the subagent must generate an [implementation report] (just what has been changed, **no explanation**), and report [implementation report] back to the main agent.

### Step 9 - Post-Implementation Review (platform-conditional)
- **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely.
- **When a header is `true` and the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — it is the only caller of the native `/simplify` and `/code-review`; do not invoke either separately. (`/code-review` additionally requires that the implementation changed code files.)
- **When a header is `local` (any platform, no Claude Code dependency):** skip that wrapper skill and spawn the vendored-skill subagent directly per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `skills/code-simplification/SKILL.md` for `simplify`, `skills/code-review-and-quality/SKILL.md` for `code_review`.
- **Otherwise (`true` on Codex, or VS Code Copilot without Claude Code skills):** the native skills do not exist — skip them; instead, the main agent performs a manual review of all changed files for unnecessary complexity and redundancy before proceeding.

### Step 10 - Implementation Review and QA
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final plan], the refactor targets, [implementation report], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Code review | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Always | Check all the code changes in the repo. Review the code changes and the implementations from a senior staff engineer perspective: assess the code implementation correctness, challenge the implementations, question the effectiveness of the implementations, making sure that the refactor targets are achieved without breaking the current codebase. Return [refactor code review report]. |
| QA validation | **QA Engineer** (`agents/qa-engineer.agent.md`) | Always | Check all the code changes in the repo. Read through the entire repo pipeline and validate the refactor from a QA engineer perspective; generate a [refactor code QA report]. If the user has requested to actually **run the scripts**, run through the entire codebase pipeline based on codebase_overview.md and scripts_overview.md from upstream to downstream, and validate whether the entire repo still performs correctly and the refactored functionalities perform as expected without errors; update the report based on the running results. Return [refactor code QA report]. |

### Step 11 - Update Overview Docs
The main agent reads through [final plan], [implementation report], [refactor code review report], and [refactor code QA report], then understands the code changes, the implementation, and the refactors to the codebase. Then the main agent updates codebase_overview.md and scripts_overview.md based on the refactor targets and the actual code changes (including the failures based on [refactor code review report] and [refactor code QA report]).

### Step 12 - Summarize the Refactor
The main agent summarizes the refactor changes in the following format:
```md
{=============================Refactor Update===============================}
{Refactor Summary (very high level description of the refactor target), Timestamp (fill the current time here, YYYY-MM-DD HH:MM), and refactor Id (assign a number in order, i.e., plus 1 to the last refactor id)}
{Refactor description (one or two sentences of description of what the refactor is)}
{Repo involved (what local repos are involved)}
{Implementation (what has been implemented to achieve the refactor)}
{Achieved (whether the refactor has been achieved, if not achieved, what is the gap)}
```

### Step 13 - Write Logs and Chat Summary
Write the Refactor Update summary to update_logs.md. Do not add additional contents, just the refactor update report from Step 12. In addition, summarize the refactor changes in bullet points and write them to the chat.
