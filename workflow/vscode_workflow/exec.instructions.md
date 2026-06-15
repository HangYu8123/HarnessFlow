---
name: 'Cmd/Skill Execution'
description: 'Instructions for executing commands and skills with structured planning and validation'
---
# Execute cmds/skills in a repo

**Safety: follow `_lib/safety_rules.md`.**
[inputs]:
input 1: target cmds/skills to execute
input 2: important files (optional)
input 3: target repo (optional)

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in `#file:../../_lib/workflow_contract.md`.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

When asked to execute cmds/skills, always, first read the following files .github/HarnessFlow/repo_info (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
Understand them, and keep them inside the memory.


**Local Skill Discovery (before any plan drafting):** When the target involves a named skill, or the task could be aided by a local skill, perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`); pass the result [local skills] to the planning subagents, and integrate it when the main agent drafts [final plan]. Skip for plain shell commands with no relevant skill ([local skills]: none relevant).

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
then, for executing cmds/skills, **CREATE ONE TODO FOR EACH STEP**:
1. if preferred files are specified, the main agent must read through the preferred files, then combine the understood knowledge with [key md files].

2. the main agent creates two subagents and **[PARALLEL EXECUTION — launch the following two subagents in parallel via VS Code Copilot `agent` tool]** (**Focus Analyst** via `agents/focus-analyst.agent.md`; **Free Analyst** via `agents/free-analyst.agent.md`), pass [inputs] to the two subagents. The two subagents must be launched in parallel. The two subagents read through [key md files]. Then:

a. the **Focus Analyst** (`agents/focus-analyst.agent.md`) first processes [inputs] and [key md files], and analyzes what the target cmds/skills are, what pre-conditions are needed, what scripts and files are associated with the execution, and what the expected outcomes should be. Then, the subagent reads through the highly associated files and scripts. Then, the subagent drafts an execution plan that covers pre-conditions, exact commands to run, expected outputs, and potential failure modes, while referencing any known issues in known_issues.md. then the subagent feeds the plan and the execution diagram back to the main agent as [plan 1] and [diagram 1].

b. the **Free Analyst** (`agents/free-analyst.agent.md`) must first process [inputs] and [key md files], then it must decide what files to read, what scripts to check, following its own logic. Then analyze what the target cmds/skills are, what dependencies exist, how to execute them safely, and what validation criteria should be used. Then, the subagent must draft an execution plan with its own approach. then the subagent feeds the plan back to the main agent as [plan 2].

3. the main agent reviews [plan 1], [plan 2], and [diagram 1], and reads necessary files. Reject incorrect or redundant parts. Combine all that information and draft a [final plan] that covers: exact commands to run, pre-conditions, expected outputs, validation criteria, and rollback strategy if applicable. The [final plan] must be feasible, safe, and 100% correct.

4. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the following two subagents in parallel via VS Code Copilot `agent` tool]**, pass [final plan] and the target cmds/skills from [inputs] to the subagents.

a. The **Devils Advocate** must read through [key md files] and all relevant scripts, then critically challenge [final plan] — looking for wrong flags, destructive side effects, missing prerequisites, environment assumptions, or potential failures. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** must read through [key md files], then identify extra needs for tools, packages, command syntax, known issues, and version compatibility. The subagent searches online for resources and reliable solutions. The subagent reports the findings from online back to the main agent as [online resource].

4.5 The main agent incorporates [valid criticisms] and [online resource], and updates [final plan] accordingly.

5. Then, the main agent must print the updated [final plan], so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

6. the main agent creates an **Executor** subagent (`agents/executor.agent.md`), pass [final plan] and the target cmds/skills to the subagent. **Executor Model Verification (see `_lib/workflow_contract.md`):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon the subagent and perform the execution directly itself following the same instructions below, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: executor-model-mismatch`. The subagent (or the main agent, if falling back) must also read through [key md files]. Then based on [final plan] and the target cmds/skills, validate pre-conditions (environment, dependencies, required files). Then the subagent executes the cmds/skills per [final plan], capturing stdout, stderr, and exit codes. If a command fails, the subagent records the failure and continues to the next command unless [final plan] specifies otherwise. After finishing the execution, the subagent must generate an [execution report] (commands run, outputs, exit codes, pass/fail — **no explanation**), and report [execution report] back to the main agent.

6.5. If and only if the main agent is Claude Code or another Claude agent with Claude Code skills available, and the execution produced or modified files, search .github/HarnessFlow/skills/index.md for `claude-native-skills-subagents`, then use the skill at .github/HarnessFlow/skills/claude-native-skills-subagents/SKILL.md after step 6. If the main agent is not a Claude agent or no files were modified, skip step 6.5 and continue to step 7.

7. the main agent creates two subagents and **[PARALLEL EXECUTION — launch the following two subagents in parallel via VS Code Copilot `agent` tool]** (**Senior Engineer** via `agents/senior-engineer.agent.md`; **QA Engineer** via `agents/qa-engineer.agent.md`). Then:
a. the main agent must pass [final plan], target cmds/skills, and [execution report] to the **Senior Engineer** subagent. The subagent must additionally read through [key md files] and review the execution results. Then the subagent analyzes the execution output from a senior staff engineer perspective: assess whether the execution produced correct and expected results, validate output against the expected outcomes defined in [final plan], identify any unexpected behaviors or anomalies in the output. Then the subagent must generate an [execution review report] and then feed the review back to the main agent as [execution review report].

b. the main agent must pass [final plan], target cmds/skills, and [execution report] to the **QA Engineer** subagent. The subagent must additionally read through [key md files] and review the execution results. Then the subagent validates the execution from a QA engineer perspective: check for side effects, state changes, file modifications, environment changes, and errors. If the user has requested to actually **run validation scripts**, the subagent must run them and validate if the execution results are as expected with 0 error. Then, the subagent must generate an [execution QA report] based on the validation, and then report [execution QA report] back to the main agent as [execution QA report].


8. the main agent must read through [final plan], [execution report], [execution review report], and [execution QA report], then understand the execution, the results, and any changes to the codebase. If the execution changed the repo state, the main agent must accordingly update codebase_overview.md and scripts_overview.md based on the actual changes (including the failures based on [execution review report] and [execution QA report]).

9. the main agent must summarize the execution in the following format, for each cmd/skill executed:
{=============================Execution Update===============================}
{Cmd/Skill Name (very high level description) and Execution Id (assign a number in order, i.e., plus 1 to the last functionality id in update_logs.md)}
{Execution description (one or two sentences of what was executed)}
{Repo involved (what local repos are involved)}
{Commands/Skills executed (what cmds/skills were run and with what parameters)}
{Result (success/failure, key outputs, side effects)}
{Achieved (whether the execution achieved the goal, if not achieved, what is the gap)}

10. write the Execution Update summary to update_logs.md. do not add additional contents, just the execution update report from previous step. In addition, summarize the execution results in bullet points and write them to the chat.
