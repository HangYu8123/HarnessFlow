---
name: 'Code Implementation'
description: 'Instructions for implementing, updating, and adding new functionalities'
---
# add new functions to an existing repo

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
-->

[inputs]:
input 1: target functionalities
input 2: important files (optional)
input 3: target repo (optional)

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

When asked to implement new functionalities, always first read the following files from `repo_info/`, resolved by the Pack Path Resolution rule (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.


**Local Skill Discovery (before any plan drafting):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` — scan `skills/index.md` for any local skill whose trigger fits [inputs]/the task; on a confirmed match, read its `SKILL.md`. Keep the result as [local skills], fold it into the repo context (per §Context Passing) so every planning subagent receives it, and integrate it when the main agent drafts its final plan. If nothing matches, record [local skills]: none relevant.

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
then, for implementing new functionalities to an existing codebase, **CREATE ONE TODO FOR EACH STEP**:
1. if preferred files are specified, the main agent must read through the preferred files, then combine the understood knowledge with [key md files].

2. the main agent creates three subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** (**Focus Analyst** via `agents/focus-analyst.agent.md`; **Broad Analyst** via `agents/broad-analyst.agent.md`; **Free Analyst** via `agents/free-analyst.agent.md`), pass [inputs] and the repo context (per §Context Passing) to the three subagents. The three subagents must be launched in parallel. Then:

a. the **Focus Analyst** (`agents/focus-analyst.agent.md`) first processes [inputs] and the repo context (per §Context Passing), and analyzes what the new functionalities are, how to integrate them into the existing codebase, and what scripts and files could be associated. Then, the subagent reads through the highly associated files and scripts. Then, the subagent drafts a plan that integrates the new functionalities into the existing codebase and drafts a diagram, while maintaining the codebase stable, avoiding known issues from known_issues.md. then the subagent feeds the plan and the implementation diagram back to the main agent as [plan 1] and [diagram 1].

b. the **Broad Analyst** (`agents/broad-analyst.agent.md`) must follow the pipeline diagram from the repo context (per §Context Passing), read through all scripts from upstream to downstream. then analyze what the new functionalities are, how to integrate them, and what scripts and files could be associated. Then, the subagent must draft a plan and diagram that integrates the new functionalities while maintaining the codebase stable and avoiding known issues. then the subagent feeds the plan and the implementation diagram back to the main agent as [plan 2] and [diagram 2].

c. the **Free Analyst** (`agents/free-analyst.agent.md`) must first process [inputs] and the repo context (per §Context Passing), then decide what files to read and scripts to check, following its own logic. Then analyze what the new functionalities are, how to integrate them while maintaining codebase stability. then the subagent feeds the plan back to the main agent as [plan 3].

3. the main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), pass all three plans [plan 1], [plan 2], and [plan 3] and the implementation diagrams [diagram 1] and [diagram 2] from the other subagents, [inputs], and the repo context (per §Context Passing) to this subagent. The subagent reads associated scripts in this repo. If the plan involves any repo outside this repo, go to that repo and read their codebase_overview.md and scripts_overview.md if they exist. Then the subagent reviews all plans and diagrams from a senior staff engineer perspective, assesses correctness and feasibility, rejects redundant or incorrect plans, and verifies the plan achieves the new functionalities without breaking existing behavior. feed the [senior staff engineer review] back to the main agent.

4. the main agent reviews the plans, the implementation diagrams from step 2, [senior staff engineer review], and read necessary files. If the plans or the review involve any other repos, go to those repos, read their codebase_overview.md and scripts_overview.md if they exist, and keep those in the memory. Finally, combine all that information and draft a [final plan] that is feasible, stable, and verified against existing tests and behavior.

5. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, pass [final plan], the input functionalities from [inputs], and the repo context (per §Context Passing) to the subagents.

a. The **Devils Advocate** receives the repo context (per §Context Passing) and reads all relevant scripts, then critically challenges [final plan] — looking for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** receives the repo context (per §Context Passing), then identifies extra needs for skills, tools, and packages. The subagent MUST actually call its platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs it fetched as proof — see `agents/online-researcher.agent.md`. The subagent reports the findings from online back to the main agent as [online resource].

5.5 The main agent incorporates [valid criticisms] and [online resource], and updates [final plan] accordingly.

6. Then, the main agent must print the updated [final plan], so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

7. the main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), pass [final plan], the target functionalities, and the repo context (per §Context Passing) to the subagent. **Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback (on Claude Code the main agent launches the Implementer on the specified `subagent_model` — a specific id even if smaller, else the inherited session model; no retry loop). The subagent (or the main agent, if falling back) uses the repo context (per §Context Passing) for codebase context. Then based on [final plan] and the target functionalities, identify what files and scripts are associated with the implementation. Then the subagent must read through all those identified files and scripts to get a detailed understanding of them. Then the subagent starts implementing the code based on [final plan] and the target functionalities. During the implementation, the subagent must follow [final plan] and implement the new functionalities correctly, verifying against existing tests and behavior. After finishing the implementation, the subagent must generate an [implementation report] (just what has been changed, **no explanation**), and report [implementation report] back to the main agent.

7.5. **Post-implementation review (platform-conditional):**
- **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) after step 7. (That skill runs `/simplify` automatically — do not invoke it separately.)
- **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the skill; instead, the main agent performs a manual review of all changed files for unnecessary complexity and redundancy before proceeding.

8. the main agent creates two subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** (**Senior Engineer** via `agents/senior-engineer.agent.md`; **QA Engineer** via `agents/qa-engineer.agent.md`). Then:
a. the main agent must pass [final plan], target functionalities, [implementation report], and the repo context (per §Context Passing) to the **Senior Engineer** subagent. The subagent checks all the code changes in the repo. Then the subagent reviews the code changes and the implementations from a senior staff engineer perspective, assesses correctness, challenges the implementations, questions the effectiveness, verifying that the new functionalities are achieved without breaking existing behavior. Then the subagent must generate an [implementation code review report] and then feed the review back to the main agent as [implementation code review report].

b. the main agent must pass [final plan], target functionalities, [implementation report], and the repo context (per §Context Passing) to the **QA Engineer** subagent. The subagent checks all the code changes in the repo. Then the subagent reads through the entire repo pipeline, validates the implementations from a QA engineer perspective. Based on the validation, the subagent must generate an [implemented code QA report]. If the user has requested to actually **run the scripts**, the subagent must run through the entire codebase pipeline from upstream to downstream, and validate if the entire repo still performs correctly and if the newly implemented functionalities perform as expected without errors. Then, the subagent must update [implemented code QA report] based on the running results, and then report [implemented code QA report] back to the main agent as [implemented code QA report].


9. the main agent must read through [final plan], [implementation report], [implementation code review report], and [implemented code QA report], then understand the code changes, the implementation, and the changes to the codebase. Then, the main agent must accordingly update codebase_overview.md and scripts_overview.md based on the newly implemented functionalities and the actual code changes (including the failures based on [implementation code review report] and [implemented code QA report]).

10. the main agent must summarize the implementation in the following format, for each new functionality:
{=============================Function Update===============================}
{functionality Name (very high level description of the functionality) and functionality Id (assign a number in order, i.e., plus 1 to the last functionality id)}
{functionality description (one or two sentences of description of what the functionality is)}
{Repo involved (what local repos are involved)}
{Implementation ( what has been implemented to achieve the functionality)}
{Achieved (whether the functionality has been achieved, if not achieved, what is the gap)}

11. write the Function Update summary to update_logs.md. do not add additional contents, just the function update report from previous step. In addition, summarize the implementation changes in bullet points and write them to the chat.
