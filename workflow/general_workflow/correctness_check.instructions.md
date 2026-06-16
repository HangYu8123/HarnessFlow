---
name: 'Correctness Check'
description: 'Instructions for examining, testing, and running an existing repo for verified correctness and full consistency'
---
# EXAM THE EXISTING REPO FOR VERIFIED CORRECTNESS AND FULL CONSISTENCY

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

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

[inputs]:
input 1: target repo
input 2: target functionalities (optional)
input 3: important files (optional)
if target functionalities are specified, focus more on target functionalities, but still go through the entire repo.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

Before checking correctness, always, first read the following files under `repo_info/`, resolved by the Pack Path Resolution rule (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
5. past_Correctness_Check.md
Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes from update_logs, active known issues, and past correctness-check findings — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.
Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames.

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
then, for checking the full correctness and full consistency of an existing codebase, **CREATE ONE TODO FOR EACH STEP**:
1. if important files are specified in [inputs], the main agent must read through the important files, then combine the understood knowledge with [key md files].
2. if target functionalities are specified in [inputs], according to [key md files], the main agent must read through the related scripts, then combine the understood knowledge with [key md files].
3. Then, the main agent must decide what are the most relevant codes, scripts, files, and functionalities to the correctness objectives from [inputs], and create a list of **BRIEF** [important information]. If the goal is to check the correctness of the entire repo, [important information] must include the pipeline diagram of the repo. If the goal is to check target functionalities, [important information] must at least contain the pipeline upstream and downstream of the target functionalities. UPDATE [important information].
**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**
4. the main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`), pass [important information] and the repo context (per §Context Passing) to the subagent.
Then the subagent must list out all important files and functionalities in the repo as [all important file list]. Based on [important information] and the repo structure from the repo context (per §Context Passing), the subagent must add or remove files in [all important file list] based on importance of functionalities and re-order [all important file list] from upstream of the workflow to downstream of workflow. Then, the subagent must read through all files in [all important file list] in order and understand the files and code while carefully examining correctness to ensure verified correctness. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 1].
5. the main agent creates a **Broad Analyst** subagent (`agents/broad-analyst.agent.md`), pass [important information] and the repo context (per §Context Passing) to the subagent.
Then the subagent must list out all files in the repo as [all file list].
Based on [important information] and the repo structure from the repo context (per §Context Passing), the subagent must re-order all files in [all file list] based on workflow (from upstream of the pipeline to downstream of the pipeline). Then, the subagent must read through all files in [all file list] in order and understand the files and code while carefully examining correctness to ensure verified correctness. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 2].
6. the main agent creates a **Free Analyst** subagent (`agents/free-analyst.agent.md`), pass the correctness objectives, [important information], and the repo context (per §Context Passing) to the subagent. Based on the correctness objectives and repo information from the repo context (per §Context Passing), the subagent must decide what files and scripts to read and in what order to read, and thus check the entire repo to ensure every functionality is verified correct. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 3].
7. the main agent creates a **QA Engineer** subagent (`agents/qa-engineer.agent.md`) in exam mode, pass [important information] and the repo context (per §Context Passing) to the subagent. Then the subagent must list out all runnable Python/C/C++/Java scripts in the repo as [all script file list]. Based on [important information] and the repo structure from the repo context (per §Context Passing), the subagent must re-order all script files in [all script file list] based on workflow (from upstream of the pipeline diagram to downstream of the pipeline diagram) to make sure the entire pipeline runs correctly. Then, the subagent must **run** through all script files in [all script file list] in order. If the subagent encounters any errors, or receives any unexpected outputs from the scripts, record it. If any errors prevent the current script from running, the subagent must record the errors, and then run the next script in [all script file list] in order. Then, the subagent must report any incorrectness accordingly, and report the final assessment back to the main agent as [answers 4].

7.5. **Diagnosis (platform-conditional):**
- **If the main agent is Claude Code:** create a **Diagnosis subagent** (`agents/focus-analyst.agent.md`, diagnosis mode): pass the failed scripts and their error outputs to this subagent. The subagent inspects each failure's stdout/stderr/traceback and reads the relevant code — re-running with verbose flags where helpful — to diagnose why each script failed, identifying root causes such as missing dependencies, incorrect paths, data issues, or logic errors. (Do not rely on a `/debug` skill — it is not a standard Claude Code skill.) Report back a [debug diagnosis report] to the main agent.
- **Otherwise (Codex or VS Code Copilot):** the main agent reviews the relevant error output, stack traces, and any existing logs manually to reach the same diagnosis, and documents the root causes as [debug diagnosis report].

If no scripts failed, skip step 7.5 and continue to step 8.

8. the main agent must read through all four answers ([answers 1], [answers 2], [answers 3], and [answers 4]), understand each of them, examine all the pointed out correctness issues, combine the insights of each report, reject the redundant or incorrect parts of each report, and draft a precise and verified correct report to report any incorrectness of the repo in bullet points.

8.5. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, pass the draft correctness report, [important information], and the repo context (per §Context Passing) to the subagents.

a. The **Devils Advocate** must use the repo context (per §Context Passing) for codebase context and read all relevant scripts, then critically challenge the draft correctness report — looking for false positives, overlooked issues, misattributed causes, or incorrect assumptions about the codebase. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** must use the repo context (per §Context Passing) for codebase context and review the draft correctness report, then identify any issues that require external documentation, known bugs in dependencies, or best-practice references to validate. The subagent MUST actually call its platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs it fetched as proof — see `agents/online-researcher.agent.md`. The subagent reports the findings from online back to the main agent as [online resource].

8.75. The main agent incorporates [valid criticisms] and [online resource], and updates the draft correctness report accordingly.

9. the main agent must summarize the correctness check report in the following format, for incorrectness:
{=============================Correctness Check: (fill a CC ID here, simply use last CC ID + 1)===============================}
Incorrect: (fill a one sentence summary of the Incorrect here.)
Potential Cause: (fill a brief but precise summary of the Potential Cause in bullet points here.)
Then the main agent must append it to past_Correctness_Check.md, using the existing contents to determine the last CC ID. If the file does not exist, create it.


10. Furthermore, based on the correctness check results, the main agent must check known_issues.md and check if the found problems are marked as fixed in known_issues.md. If yes, add an additional line and say "the attempted fix actually failed."
