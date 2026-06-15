---
name: 'Code Implementation (Codex)'
description: 'Instructions for implementing, updating, and adding new functionalities — Codex CLI native'
---
# add new functions to an existing repo

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

**Safety: follow `_lib/safety_rules.md`.**
[inputs]:
input 1: target functionalities
input 2: important files (optional)
input 3: target repo (optional)

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md`, resolved by the Pack Path Resolution rule, before proceeding.
Every subagent created by this workflow must also read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

When ask to implement new functionalities, always, first read the following files .github/HarnessFlow/repo_info (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
Understand them, and keep them inside the memory.


**Local Skill Discovery (before any plan drafting):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` — scan `skills/index.md` for any local skill whose trigger fits [inputs]/the task; on a confirmed match, read its `SKILL.md`. Keep the result as [local skills], pass it to the planning subagents, and integrate it when the main agent drafts its final plan. If nothing matches, record [local skills]: none relevant.

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
then, for implementing new functionalities to an existing codebase, **CREATE ONE TODO FOR EACH STEP**:
1. if preferred files are specified, the main agent must read through the preferred files, then combine the understood knowledge with [key md files].

2. the main agent creates three subagents and **[PARALLEL EXECUTION via Codex agent workers — launch in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]** (**Focus Analyst** via `agents/focus-analyst.agent.md`; **Broad Analyst** via `agents/broad-analyst.agent.md`; **Free Analyst** via `agents/free-analyst.agent.md`), pass [inputs] to the three subagents. The three subagents must be launched in parallel. The three subagents read through [key md files]. Then:

a. the **Focus Analyst** (`agents/focus-analyst.agent.md`) first processes [inputs] and [key md files], and analyzes what the new functionalities are, how to integrate the new functionalities to the existing codebase, and what scripts and files could be associated with the new functionalities. Then, the subagent reads through the highly associated files and scripts. Then, the subagent drafts a plan that integrates the new functionalities into the existing codebase and drafts a diagram that integrates the new functionalities into the codebase diagram, while maintaining the entire codebase stable, with NO bugs, and NO repeat of any known issues/bugs in known_issues.md. then the subagent feeds the plan and the implementation diagram back to the main agent as [plan 1] and [diagram 1].

b. the **Broad Analyst** (`agents/broad-analyst.agent.md`) must follow the pipeline diagram from [key md files], read through all scripts from upstream of the diagram to downstream of the diagram. then analyze what the new functionalities are, how to integrate the new functionalities to the existing codebase, and what scripts and files could be associated with the new functionalities. Then, the subagent must draft a plan that integrates the new functionalities into the existing codebase and draft a diagram that integrates the new functionalities to the codebase diagram, while maintaining the codebase stable, with NO bugs, and NO repeat of any known issues/bugs. then the subagent feeds the plan and the implementation diagram back to the main agent as [plan 2] and [diagram 2].

c. the **Free Analyst** (`agents/free-analyst.agent.md`) must first process [inputs] and [key md files], then it must decide what files to read, what scripts to check, following its own logic. Then analyze what the new functionalities are, how to integrate the new functionalities to the existing codebase, and what scripts and files could be associated with the new functionalities. Then, the subagent must draft a plan that integrates the new functionalities into the existing codebase while maintaining the entire codebase stable. then the subagent feeds the plan and the implementation diagram back to the main agent as [plan 3].

3. the main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), pass all three plans [plan 1], [plan 2], and [plan 3] and the implementation diagrams [diagram 1] and [diagram 2] from the other subagents and [inputs] to this subagent. The subagent must additionally read through [key md files] and associated scripts in this repo. If the plan involves any repo outside this repo, go to that repo, if there are codebase_overview.md and scripts_overview.md, read through them too. Then the subagent reviews all plans and diagrams from a senior staff engineer perspective, assesses the plans' and diagrams' correctness and feasibility, rejects redundant or incorrect plans, and makes sure that the plan and diagrams can 100% achieve the new functionalities without breaking the current codebase. feed the [senior staff engineer review] back to the main agent.

4. the main agent reviews the plans, the implementation diagrams from step 2, [senior staff engineer review], and read necessary files. If the plans or the review involve any other repos, go to those repos, read their codebase_overview.md and scripts_overview.md if they exist, and keep those in the memory. Finally, combine all that information and draft a [final plan] that is feasible, stable, and 100% correct.

5. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION via Codex agent workers — launch in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]**, pass [final plan] and the input functionalities from [inputs] to the subagents.

a. The **Devils Advocate** must read through [key md files] and all relevant scripts, then critically challenge [final plan] — looking for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** must read through [key md files], then identify extra needs for skills, tools, and packages. The subagent searches online for resources and reliable solutions. The subagent reports the findings from online back to the main agent as [online resource].

5.5 The main agent incorporates [valid criticisms] and [online resource], and updates [final plan] accordingly.

6. Then, the main agent must print the updated [final plan], so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

7. the main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), pass [final plan] and the target functionalities to the subagent. **Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback. The subagent (or the main agent, if falling back) must also read through [key md files]. Then based on [final plan] and the target functionalities, identify what files and scripts are associated with the implementation of the new functionalities. Then the subagent must read through all those identified files and scripts to get a detailed understanding of them. Then the subagent starts implementing the code based on [final plan] and the target functionalities. During the implementation, the subagent must follow [final plan], and 100% correctly implement and integrate the new functionalities. After finishing the implementation, the subagent must generate an [implementation report] (just what has been changed, **no explanation**), and report [implementation report] back to the main agent.

7.5. Skip — Claude-native skills are not available in Codex. Instead, the main agent performs a manual review of all changed files for unnecessary complexity and redundancy before proceeding.

8. the main agent creates two subagents and **[PARALLEL EXECUTION via Codex agent workers — launch in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]** (**Senior Engineer** via `agents/senior-engineer.agent.md`; **QA Engineer** via `agents/qa-engineer.agent.md`). Then:
a. the main agent must pass [final plan], target functionalities, and [implementation report] to the **Senior Engineer** subagent. The subagent must additionally read through [key md files] and check all the code changes in the repo. Then the subagent reviews the code changes and the implementations from a senior staff engineer perspective, assess the code implementation correctness, challenge the implementations, question the effectiveness of the implementations, making sure that the new functionalities are 100% achieved without breaking the current codebase. Then the subagent must generate an [implementation code review report] and then feed the review back to the main agent as [implementation code review report].

b. the main agent must pass [final plan], target functionalities, and [implementation report] to the **QA Engineer** subagent. The subagent must additionally read through [key md files] and check all the code changes in the repo. Then the subagent reads through the entire repo pipeline, validate the implementations from a QA engineer perspective. Based on the validation, the subagent must generate an [implemented code QA report]. If the user has requested to actually **run the scripts**, the subagent must run through the entire codebase pipeline based on codebase_overview.md and scripts_overview.md from upstream to downstream, and validate if the entire repo still performs correctly and if the newly implemented functionalities perform as expected with 0 error. Then, the subagent must update [implemented code QA report] based on the running results, and then report [implemented code QA report] back to the main agent as [implemented code QA report].


9. the main agent must read through [final plan], [implementation report], [implementation code review report], and [implemented code QA report], then understand the code changes, the implementation, and the changes to the codebase. Then, the main agent must accordingly update codebase_overview.md and scripts_overview.md based on the newly implemented functionalities and the actual code changes (including the failures based on [implementation code review report] and [implemented code QA report]).

10. the main agent must summarize the implementation in the following format, for each new functionality:
{=============================Function Update===============================}
{functionality Name (very high level description of the functionality) and functionality Id (assign a number in order, i.e., plus 1 to the last functionality id)}
{functionality description (one or two sentences of description of what the functionality is)}
{Repo involved (what local repos are involved)}
{Implementation ( what has been implemented to achieve the functionality)}
{Achieved (whether the functionality has been achieved, if not achieved, what is the gap)}

11. write the Function Update summary to update_logs.md. do not add additional contents, just the function update report from previous step. In addition, summarize the implementation changes in bullet points and write them to the chat.
