---
name: 'Correctness Check'
description: 'Instructions for examining, testing, and running an existing repo for 100% correctness and consistency'
---
# EXAM THE EXISTING REPO FOR 100% CORRECTNESS AND CONSISTENCY

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Correctness_Check.md
-->

**DO NOT TRY TO COMMIT CHANGES TO GITHUB**
**DO NOT WRITE SPAM FILES INTO THE REPO**
**DO NOT USE SUDO**
[inputs]:
input 1: target repo
input 2: target functionalities (optional)
input 3: important files (optional)
if target functionalities are specified, focus more on target functionalities, but still go through the entire repo.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in #file:../../_lib/workflow_contract.md.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using VS Code Copilot's native `agent` tool. Coordinator agents declare `tools: ['agent']` and `agents: [...]` to orchestrate subagent invocation.

Before checking correctness, always, first read the following files .github/harness_coding_instructions/repo_info (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
5. past_Correctness_Check.md
Understand them, and keep them inside the memory.
Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames.

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
then, for checking the 100% correctness and 100% consistency to an existing codebase, **CREATE ONE TODO FOR EACH STEP**:
1. if important files are specified in [inputs], the main agent must read through the important files, then combine the understood knowledge with [key md files].
2. if target functionalities are specified in [inputs], according to [key md files], the main agent must read through the related scripts, then combine the understood knowledge with [key md files].
3. Then, the main agent must decide what are the most relevant codes, scripts, files, and functionalities to the correctness objectives from [inputs], and create a list of **BRIEF** [important information]. If the goal is to check the correctness of the entire repo, [important information] must include the pipeline diagram of the repo. If the goal is to check target functionalities, [important information] must at least contain the pipeline upstream and downstream of the target functionalities. UPDATE [important information].
**[PARALLEL EXECUTION — launch steps 4, 5, 6, and 7 in parallel via VS Code Copilot `agent` tool]**
4. the main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`), pass [important information] to the subagent. The subagent must also read through [key md files].
Then the subagent must list out all important files and functionalities in the repo as [all important file list]. Based on [important information] and the repo structure from [key md files], the subagent must add or remove files in [all important file list] based on importance of functionalities and re-order [all important file list] from upstream of the workflow to downstream of workflow. Then, the subagent must read through all files in [all important file list] in order and understand the files and code while carefully examining correctness to make sure 100% correctness. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 1].
5. the main agent creates a **Broad Analyst** subagent (`agents/broad-analyst.agent.md`), pass [important information] to the subagent. The subagent must also read through [key md files].
Then the subagent must list out all files in the repo as [all file list].
Based on [important information] and the repo structure from [key md files], the subagent must re-order all files in [all file list] based on workflow (from upstream of the pipeline to downstream of the pipeline). Then, the subagent must read through all files in [all file list] in order and understand the files and code while carefully examining correctness to make sure 100% correctness. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 2].
6. the main agent creates a **Free Analyst** subagent (`agents/free-analyst.agent.md`), pass the correctness objectives and [important information] to the subagent. The subagent must also read through [key md files]. Based on the correctness objectives and repo information from [key md files], the subagent must decide what files and scripts to read and in what order to read, and thus check the entire repo to make sure every functionality is 100% correct. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 3].
7. the main agent creates a **QA Engineer** subagent (`agents/qa-engineer.agent.md`) in exam mode, pass [important information] to the subagent. The subagent must also read through [key md files]. Then the subagent must list out all runnable Python/C/C++/Java scripts in the repo as [all script file list]. Based on [important information] and the repo structure from [key md files], the subagent must re-order all script files in [all script file list] based on workflow (from upstream of the pipeline diagram to downstream of the pipeline diagram) to make sure the entire pipeline runs correctly. Then, the subagent must **run** through all script files in [all script file list] in order. If the subagent encounters any errors, or receives any unexpected outputs from the scripts, record it. If any errors prevent the current script from running, the subagent must record the errors, and then run the next script in [all script file list] in order. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 4].

7.5. If and only if any scripts failed during step 7 execution and the main agent is Claude Code or another Claude agent with Claude Code skills available, the main agent creates a **Debug sub-agent (`/debug`)**: Pass the failed scripts and their error outputs to this subagent. The subagent uses `/debug` to enable debug logging and diagnose why each script failed — identifying root causes such as missing dependencies, incorrect paths, data issues, or logic errors. Report back a [debug diagnosis report] to the main agent. If the main agent is not a Claude agent or no scripts failed, skip step 7.5 and continue to step 8.

8. the main agent must read through all four answers ([answers 1], [answers 2], [answers 3], and [answers 4]), read necessary files, understand each of them, examine all the pointed out correctness issues, combine the insights of each report, reject the redundant or incorrect parts of each report, and draft a precise and 100% correct report to report any incorrectness of the repo in bullet points.

8.5. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the following two subagents in parallel via VS Code Copilot `agent` tool]**, pass the draft correctness report and [important information] to the subagents.

a. The **Devils Advocate** must read through [key md files] and all relevant scripts, then critically challenge the draft correctness report — looking for false positives, overlooked issues, misattributed causes, or incorrect assumptions about the codebase. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** must read through [key md files] and the draft correctness report, then identify any issues that require external documentation, known bugs in dependencies, or best-practice references to validate. The subagent searches online for reliable resources and solutions. The subagent reports the findings from online back to the main agent as [online resource].

8.75. The main agent incorporates [valid criticisms] and [online resource], and updates the draft correctness report accordingly.

9. the main agent must summarize the correctness check report in the following format, for incorrectness:
{=============================Correctness Check: (fill a CC ID here, simply use last CC ID + 1)===============================}
Incorrect: (fill a one sentence summary of the Incorrect here.)
Potential Cause: (fill a brief but precise summary of the Potential Cause in bullet points here.)
Then the main agent must append it to past_Correctness_Check.md, using the existing contents to determine the last CC ID. If the file does not exist, create it.


10. Furthermore, based on the correctness check results, the main agent must check known_issues.md and check if the found problems are marked as fixed in known_issues.md. If yes, add an additional line and say "the attempted fix actually failed."
