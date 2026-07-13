---
name: 'Correctness Check'
description: 'Instructions for examining, testing, and running an existing repo for verified correctness and full consistency'
---
# Exam the Existing Repo for Verified Correctness and Full Consistency

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

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

[inputs]:
- input 1: target repo
- input 2: target functionalities (optional)
- input 3: important files (optional)

If target functionalities are specified, focus more on target functionalities, but still go through the entire repo.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/repo_info/`, resolved by the Pack Path Resolution rule). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. Understand them. Then, per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes from update_logs, active known issues, and past correctness-check findings — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.
Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames.

If important files are specified in [inputs], the main agent must read through the important files, then combine the understood knowledge with [key md files]. If target functionalities are specified in [inputs], according to [key md files], the main agent must read through the related scripts, then combine the understood knowledge with [key md files].

### Step 2 - Identify Important Information
The main agent decides what are the most relevant codes, scripts, files, and functionalities to the correctness objectives from [inputs], and creates a list of **BRIEF** [important information]. If the goal is to check the correctness of the entire repo, [important information] must include the pipeline diagram of the repo. If the goal is to check target functionalities, [important information] must at least contain the pipeline upstream and downstream of the target functionalities. UPDATE [important information].

### Step 3 - Correctness Examination Panel
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [important information] and the repo context (per §Context Passing) to the subagents (the Free Analyst also receives the correctness objectives).

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Focus exam | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Always | List out all important files and functionalities in the repo as [all important file list]. Based on [important information] and the repo structure from the repo context (per §Context Passing), add or remove files in [all important file list] based on importance of functionalities and re-order it from upstream of the workflow to downstream. Read through all files in [all important file list] in order and understand the files and code while carefully examining correctness to ensure verified correctness. Report any incorrectness accordingly. Return the final assessment as [answers 1]. |
| Broad exam | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Always | List out all files in the repo as [all file list]. Based on [important information] and the repo structure from the repo context (per §Context Passing), re-order all files in [all file list] based on workflow (from upstream of the pipeline to downstream). Read through all files in [all file list] in order and understand the files and code while carefully examining correctness to ensure verified correctness. Report any incorrectness accordingly. Return the final assessment as [answers 2]. |
| Free exam | **Free Analyst** (`agents/free-analyst.agent.md`) | Always | Based on the correctness objectives and repo information from the repo context (per §Context Passing), decide what files and scripts to read and in what order, and thus check the entire repo to ensure every functionality is verified correct. Report any incorrectness accordingly. Return the final assessment as [answers 3]. |
| Script run | **QA Engineer** (`agents/qa-engineer.agent.md`, exam mode) | Always | List out all runnable Python/C/C++/Java scripts in the repo as [all script file list]. Based on [important information] and the repo structure from the repo context (per §Context Passing), re-order all script files in [all script file list] based on workflow (from upstream of the pipeline diagram to downstream) to make sure the entire pipeline runs correctly. **Run** through all script files in [all script file list] in order. If any errors are encountered, or any unexpected outputs are received from the scripts, record them. If any errors prevent the current script from running, record the errors, then run the next script in [all script file list] in order. Report any incorrectness accordingly. Return the final assessment as [answers 4]. |

### Step 4 - Failure Diagnosis (platform-conditional)
If no scripts failed, skip this step and continue to Step 5.

- **If the main agent is Claude Code:** create a **Diagnosis subagent** (`agents/focus-analyst.agent.md`, diagnosis mode): pass the failed scripts and their error outputs to this subagent. The subagent inspects each failure's stdout/stderr/traceback and reads the relevant code — re-running with verbose flags where helpful — to diagnose why each script failed, identifying root causes such as missing dependencies, incorrect paths, data issues, or logic errors. (Do not rely on a `/debug` skill — it is not a standard Claude Code skill.) Report back a [debug diagnosis report] to the main agent.
- **Otherwise (Codex or VS Code Copilot):** the main agent reviews the relevant error output, stack traces, and any existing logs manually to reach the same diagnosis, and documents the root causes as [debug diagnosis report].

### Step 5 - Synthesize the Correctness Report
The main agent reads through all four answers ([answers 1], [answers 2], [answers 3], and [answers 4]) and, when Step 4 produced one, [debug diagnosis report]; understands each of them, examines all the pointed-out correctness issues, combines the insights of each report, rejects the redundant or incorrect parts of each report, and drafts a precise and verified correct report of any incorrectness of the repo in bullet points.

### Step 6 - Report Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass the draft correctness report, [important information], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Use the repo context (per §Context Passing) for codebase context and read all relevant scripts, then critically challenge the draft correctness report — looking for false positives, overlooked issues, misattributed causes, or incorrect assumptions about the codebase. Return flaws as [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Use the repo context (per §Context Passing) for codebase context and review the draft correctness report, then identify any issues that require external documentation, known bugs in dependencies, or best-practice references to validate. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |

### Step 7 - Finalize the Report
The main agent incorporates [valid criticisms] and [online resource], and updates the draft correctness report accordingly.

### Step 8 - Record the Correctness Check
The main agent summarizes the correctness check report in the following format, for each incorrectness:
```md
{=============================Correctness Check: (fill the current time here, YYYY-MM-DD HH:MM) — (fill a CC ID here, simply use last CC ID + 1)===============================}
Incorrect: (fill a one sentence summary of the Incorrect here.)
Potential Cause: (fill a brief but precise summary of the Potential Cause in bullet points here.)
```
Then the main agent must append it to past_Correctness_Check.md, using the existing contents to determine the last CC ID. If the file does not exist, create it.

### Step 9 - Cross-Check known_issues.md
Based on the correctness check results, the main agent checks known_issues.md and checks whether the found problems are marked as fixed in known_issues.md. If yes, add an additional line and say "the attempted fix actually failed."
