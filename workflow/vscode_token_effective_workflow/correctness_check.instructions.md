---
name: 'Fast Correctness Check'
description: 'Streamlined instructions for verifying repo correctness with maximum parallelization'
---
# Exam Existing Repo for 100% Correctness

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

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target repo
- input 2: target functionalities (optional)
- input 3: important files (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in #file:../../_lib/workflow_contract.md.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using VS Code Copilot's native `agent` tool. Coordinator agents declare `tools: ['agent']` and `agents: [...]` to orchestrate subagent invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under .github/harness_coding_instructions/repo_info). Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames.

---

## CREATE ONE TODO PER STEP

### Step 1 — Context Gathering
If important files or target functionalities are specified in [inputs], read them. Combine with [key md files]. Create [important information] — most relevant codes, scripts, functionalities. If checking entire repo, include full pipeline diagram. If checking target functionalities, include upstream/downstream pipeline.

### Step 2 — Parallel Correctness Check
**[PARALLEL EXECUTION — launch ALL FOUR subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Code A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files]. List important files, reorder upstream->downstream. Examine correctness. Return [answers 1]. |
| Code B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files]. List all files, reorder by pipeline flow. Examine correctness. Return [answers 2]. |
| Code C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files]. Decide own reading order/strategy. Check entire repo for correctness. Return [answers 3]. |
| QA | **QA Engineer** (`agents/qa-engineer.agent.md`) | QA/SQA engineer | Read [key md files]. List all runnable scripts, order by pipeline. Run each script. If script fails: log error and continue to next script. Record errors/unexpected outputs. Return [answers 4]. |

### Step 2.5 — Claude Debug Diagnostics
If and only if any scripts failed during step 2 execution and the main agent is Claude Code or another Claude agent with Claude Code skills available, create a **Debug sub-agent (`/debug`)**: Pass the failed scripts and their error outputs to this subagent. The subagent uses `/debug` to enable debug logging and diagnose why each script failed — identifying root causes such as missing dependencies, incorrect paths, data issues, or logic errors. Return [debug diagnosis report]. If the main agent is not a Claude agent or no scripts failed, skip step 2.5 and continue to step 3.

### Step 3 — Synthesize Report
Main agent reads [answers 1-4]. Combine insights, reject redundant/incorrect parts. If [debug diagnosis report] exists, incorporate its root cause findings. Draft precise correctness report in bullet points. Include all script failures from [answers 4].

### Step 3.5 — Challenge and Research
**[PARALLEL EXECUTION — launch the following two subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] and all relevant scripts, then critically challenge the draft correctness report — looking for false positives, overlooked issues, misattributed causes, or incorrect assumptions about the codebase. Return [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | External resource lookup | Read [key md files] and the draft correctness report, then identify any issues that require external documentation, known bugs in dependencies, or best-practice references to validate. Search online for reliable resources and solutions. Return [online resource]. |

### Step 3.75 — Incorporate Feedback
Main agent incorporates [valid criticisms] and [online resource], and updates the draft correctness report accordingly.

### Step 4 — Documentation
1. Append to past_Correctness_Check.md, using the existing contents to determine the last CC ID (create if missing):
```
{=============================Correctness Check: (last CC ID + 1)===============================}
Incorrect: (one sentence summary)
Potential Cause: (brief precise bullet points)
```
2. Cross-check known_issues.md — if any found problems were marked as "fixed" there, add: "the attempted fix actually failed."
