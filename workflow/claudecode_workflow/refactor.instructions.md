---
name: 'Code Refactor (Claude Code)'
description: 'Instructions for refactoring existing scripts, repositories, and functionalities — Claude Code CLI native'
---
# Refactor an existing repo

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
-->

**Safety: follow `_lib/safety_rules.md`.**
[inputs]:
input 1: target refactor functionalities, repository, or scripts
input 2: target files (optional)
input 3: target repo (optional)
Inputs specify the refactor targets.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md`, resolved by the Pack Path Resolution rule, before proceeding.
Every subagent created by this workflow must also read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md` (resolved by Pack Path Resolution rule).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

When ask to refactor existing functionalities, repositories, and scripts, always, first read the following files .github/harness_coding_instructions/repo_info (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
Understand them, and keep them inside the memory.


#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
then, for refactoring existing functionalities, repositories, and scripts, **CREATE ONE TODO FOR EACH STEP**:
1. if input 1 or input 2 are specified in [inputs], the main agent must read through the files associated with [inputs], then combine the understood knowledge with [key md files].

2. the main agent creates six subagents and **[PARALLEL EXECUTION — launch the following subagents simultaneously as Claude Code agent team; if parallel not supported, run sequentially]** (**Architecture Analyst** via `agents/architecture-analyst.agent.md`; **Redundancy Analyst** via `agents/redundancy-analyst.agent.md`; **Robustness Analyst** via `agents/robustness-analyst.agent.md`; **Free Analyst** via `agents/free-analyst.agent.md`; **Senior Engineer** via `agents/senior-engineer.agent.md` in code review mode; **Complexity Analyst** via `agents/complexity-analyst.agent.md`), pass [inputs] to the six subagents. The six subagents must be **launched in parallel**. The six subagents read through [key md files]. Then:

a. the **Architecture Analyst** first processes the refactor targets and [key md files]. Then based on the current code/repo/architecture and the refactor targets from [inputs], the subagent analyzes: 1) what functionalities and scripts must be refactored and why they must be refactored; 2) what functionalities are inappropriately designed/placed in the existing codebase and why they are inappropriately designed/placed; 3) how to improve the code architecture of the existing codebase/scripts and what the improvements are compared to the current code architecture. Then, based on the analysis, the subagent drafts an initial plan, including what can be improved, why it must be improved, and what the consequences of the improvements are. Based on the initial plan, the subagent reads through the associated files and scripts, specifically focused on validating and improving the initial plan. Then, based on the file reading, the subagent finalizes the initial plan that improves the architecture of the existing codebase/scripts/functionalities, and then drafts a comparison statement that shows how the code architecture is improved based on the original codebase diagram. The plan must keep the entire codebase stable, with NO bugs, and NO repeat of any known issues/bugs in known_issues.md. then the subagent feeds the plan and the comparison statement back to the main agent as [plan 1] and [comparison statement 1].

b. the **Redundancy Analyst** first processes the refactor targets and [key md files]. Then based on the current code/repo/architecture and the refactor targets from [inputs], the subagent analyzes: 1) what functionalities and scripts have redundancy and why they have redundancy; 2) whether there are overlapped implementations in the existing codebase/scripts/code and why they overlap; 3) how to reduce the redundancy of the existing codebase/scripts and what the improvements are compared to the current codebase/scripts. Then, based on the analysis, the subagent drafts an initial plan, including what can be improved/removed, why it must be improved/removed, and what the consequences of the improvements/removals are. Based on the initial plan, the subagent reads through the associated files and scripts, specifically focused on validating and improving the initial plan, and imagines what would happen if the planned redundancies are removed. Then, based on the file reading, the subagent finalizes the initial plan that reduces the redundancy of the existing codebase/scripts/functionalities, and then drafts a comparison statement that shows how the redundancy is reduced based on the original codebase/scripts. The plan must keep the entire codebase stable, with NO bugs, and NO repeat of any known issues/bugs in known_issues.md. then the subagent feeds the plan and the comparison statement back to the main agent as [plan 2] and [comparison statement 2].

c. the **Robustness Analyst** first processes the refactor targets and [key md files]. Then based on the current code/repo/architecture and the refactor targets from [inputs], the subagent analyzes: 1) what functionalities and scripts have robustness issues and why they have robustness issues; 2) whether there are potential bugs or issues in the existing codebase/scripts/code and why they are potential bugs or issues; 3) how to improve the robustness of the existing codebase/scripts and what the improvements are compared to the current codebase/scripts. Then, based on the analysis, the subagent drafts an initial plan, including what can be improved, why it must be improved, and what the consequences of the improvements are. Based on the initial plan, the subagent reads through the associated files and scripts, specifically focused on validating and improving the initial plan, and imagines what would happen if the planned improvements are implemented. Then, based on the file reading, the subagent finalizes the initial plan that improves the robustness of the existing codebase/scripts/functionalities, and then drafts a comparison statement that shows how the robustness is improved based on the original codebase/scripts. The plan must keep the entire codebase stable, with NO bugs, and NO repeat of any known issues/bugs in known_issues.md. then the subagent feeds the plan and the comparison statement back to the main agent as [plan 3] and [comparison statement 3].

d. the **Free Analyst** first processes [inputs] and [key md files]. Then the subagent decides what files to read and what scripts to check, based on the known information. Then the subagent analyzes what the refactor targets are, how to refactor the existing codebase, and what scripts and files could be associated with the refactor targets. Then, the subagent drafts a plan that refactors the existing codebase while maintaining the entire codebase stable. then the subagent feeds the plan and the implementation diagram back to the main agent as [plan 4].

e. the **Senior Engineer** (in code review mode) first processes the refactor targets and [key md files]. Then based on [inputs], the plan, and the repo structure from [key md files], the subagent decides a list of files and scripts that could be associated with [inputs] and the refactor targets as [associated files]. Then, the subagent starts reading files **LINE BY LINE** from [associated files] from a senior engineer perspective. While reading, if any files or scripts are found to be highly associated with the refactor targets, add them to [associated files] and read through them as well. After finishing reading one file from [associated files], add the read file into [read files]. Once [read files] and [associated files] are the same, the reading is finished. Then, based on the reading, the subagent reviews the code from a senior engineer perspective, finding what is weak in terms of code quality, readability, maintainability, and robustness. Then draft a code review report that includes what the issues are in the existing codebase/scripts/functionalities as [code issue review report], and what can be improved, why it must be improved, and how to improve it as [code improvement review report].
Then the subagent feeds the two review reports back to the main agent as [code issue review report] and [code improvement review report].

f. the **Complexity Analyst** first processes the refactor targets and [key md files]. The subagent may use `/simplify` (Claude Code native); it identifies: 1) unnecessary complexity in functions, modules, and scripts and why they are overly complex; 2) simplifiable logic paths that can be reduced without changing underlying behavior; 3) over-engineered abstractions that are convoluted and how they can be flattened or clarified. Then, based on the analysis, the subagent drafts an initial plan, including what can be simplified, why it must be simplified, and what the consequences of the simplifications are. Based on the initial plan, the subagent reads through the associated files and scripts, specifically focused on validating that each proposed simplification preserves existing behavior. Then, based on the file reading, the subagent finalizes the initial plan that reduces the complexity of the existing codebase/scripts/functionalities, and then drafts a comparison statement that shows how the complexity is reduced based on the original codebase/scripts. The plan must keep the entire codebase stable, with NO bugs, and NO repeat of any known issues/bugs in known_issues.md. then the subagent feeds the plan and the comparison statement back to the main agent as [plan 5] and [comparison statement 4].

3. the main agent creates a **Principal Engineer** subagent (`agents/principal-engineer.agent.md`), pass the refactor targets, all the plans ([plan 1], [plan 2], [plan 3], [plan 4], and [plan 5]), the comparison statements ([comparison statement 1], [comparison statement 2], [comparison statement 3], and [comparison statement 4]), the code review reports ([code issue review report] and [code improvement review report]), and [inputs] to this subagent. The subagent must additionally read through [key md files] and associated scripts in this repo. If the plan involves any repo outside this repo, go to that repo, if there are codebase_overview.md and scripts_overview.md, read through them too. Then the subagent reviews all plans, comparison statements, and code review reports from a principal engineer perspective, assesses the plans', comparison statements', and code review reports' correctness and feasibility, rejects redundant or incorrect plans, and makes sure that the plan can 100% achieve the refactor targets without breaking the current codebase. feed the [plan review] back to the main agent.

4. the main agent reviews all the plans ([plan 1], [plan 2], [plan 3], [plan 4], and [plan 5]), the comparison statements ([comparison statement 1], [comparison statement 2], [comparison statement 3], and [comparison statement 4]), the code review reports ([code issue review report] and [code improvement review report]) from step 2 and [plan review], and read necessary files. If the plans, comparison statements, code review reports, or [plan review] involve any other repos, go to those repos, read their codebase_overview.md and scripts_overview.md if they exist, and keep those in the memory. Finally, combine all that information and draft a [final plan] that is feasible, stable, and 100% correct. Then the main agent must go through [final plan]. For each step in [final plan], read through the associated code and scripts, imagine what would happen if the step is implemented, examine correctness, and make sure the changes would not break the current codebase. If any step in [final plan] is problematic, revise [final plan] accordingly, and make sure the revised [final plan] can 100% achieve the refactor targets without any issues.

5. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the following subagents simultaneously as Claude Code agent team; if parallel not supported, run sequentially]**, pass [final plan] and the refactor targets from [inputs] to the subagents.

a. The **Devils Advocate** must read through [key md files] and all relevant scripts, then critically challenge [final plan] — looking for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** must read through [key md files] and the refactor targets, then identify extra needs for skills, tools, packages, patterns, or migration references. The subagent searches online for reliable resources and solutions. The subagent reports the findings from online back to the main agent as [online resource].

5.5. The main agent incorporates [valid criticisms] and [online resource], and updates [final plan] accordingly.

6. Then, the main agent must print the updated [final plan], so the user can read it later. **If the user has requested for no code changes, THE MAIN AGENT MUST STOP AFTER PRINTING THE FINAL PLAN. OTHERWISE, KEEP PROCEEDING TO STEP 7**. If the user has NOT SPECIFIED or requires code changes, the main agent must continue to step 7.

7. the main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), pass [final plan] and the refactor targets to the subagent. **Implementer Model Verification (see `_lib/workflow_contract.md`):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon the subagent and perform the implementation directly itself following the same instructions below, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`. The subagent (or the main agent, if falling back) must also read through [key md files]. Then based on [final plan] and the refactor targets, read all scripts that are associated with [final plan]. Then the subagent starts implementing [final plan] and achieves the refactor targets accordingly. After finishing the implementation, the subagent must generate an [implementation report] (just what has been changed, **no explanation**), and report [implementation report] back to the main agent.

7.5. Since this is a Claude Code environment, search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at `skills/claude-native-skills-subagents/SKILL.md` after step 7.

8. the main agent creates two subagents and **[PARALLEL EXECUTION — launch the following subagents simultaneously as Claude Code agent team; if parallel not supported, run sequentially]** (**Senior Engineer** via `agents/senior-engineer.agent.md`; **QA Engineer** via `agents/qa-engineer.agent.md`). Then:
a. the main agent must pass [final plan], refactor targets, and [implementation report] to the **Senior Engineer** subagent. The subagent must additionally read through [key md files] and check all the code changes in the repo. Then the subagent reviews the code changes and the implementations from a senior staff engineer perspective, assess the code implementation correctness, challenge the implementations, question the effectiveness of the implementations, making sure that the refactor targets are 100% achieved without breaking the current codebase. Then the subagent must generate a [refactor code review report] and then feed the review back to the main agent as [refactor code review report].

b. the main agent must pass [final plan], refactor targets, and [implementation report] to the **QA Engineer** subagent. The subagent must additionally read through [key md files] and check all the code changes in the repo. Then the subagent reads through the entire repo pipeline, validate the refactor from a QA engineer perspective. Based on the validation, the subagent must generate a [refactor code QA report]. If the user has requested to actually **run the scripts**, the subagent must run through the entire codebase pipeline based on codebase_overview.md and scripts_overview.md from upstream to downstream, and validate if the entire repo still performs correctly and if the refactored functionalities perform as expected with 0 error. Then, the subagent must update [refactor code QA report] based on the running results, and then report [refactor code QA report] back to the main agent as [refactor code QA report].


9. the main agent must read through [final plan], [implementation report], [refactor code review report], and [refactor code QA report], then understand the code changes, the implementation, and the refactors to the codebase. Then, the main agent must accordingly update codebase_overview.md and scripts_overview.md based on the refactor targets and the actual code changes (including the failures based on [refactor code review report] and [refactor code QA report]).

10. the main agent must summarize the refactor changes in the following format:
{=============================Refactor Update===============================}
{Refactor Summary (very high level description of the refactor target) and refactor Id (assign a number in order, i.e., plus 1 to the last refactor id)}
{Refactor description (one or two sentences of description of what the refactor is)}
{Repo involved (what local repos are involved)}
{Implementation ( what has been implemented to achieve the refactor)}
{Achieved (whether the refactor has been achieved, if not achieved, what is the gap)}

11. write the Refactor Update summary to update_logs.md. do not add additional contents, just the refactor update report from previous step. In addition, summarize the refactor changes in bullet points and write them to the chat.
