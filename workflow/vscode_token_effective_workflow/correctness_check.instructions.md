---
name: 'Fast Correctness Check'
description: 'Streamlined instructions for verifying repo correctness with maximum parallelization'
---
# Examine Existing Repo for Correctness

<!-- Required Context Files:
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
- Before creating any subagent, the main agent must identify [main agent model].
- Every subagent prompt must include [inputs], exact task, expected output label, required context files, and: "**Create subagent with the exact [main agent model] - do not downgrade.**"
- Subagents must use [main agent model].
- After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.
- If a subagent is not created, uses a different model, fails, or returns a low-quality or irrelevant result, retry that same subagent up to 3 times. If it still fails, the main agent performs that subagent's task directly and records a [fallback result].

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using VS Code Copilot's native `agent` tool. Coordinator agents declare `tools: ['agent']` and `agents: [...]` to orchestrate subagent invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Correctness_Check.md (under .github/harness_coding_instructions/repo_info). Use `past_Correctness_Check.md` as the canonical correctness-check history file; do not create alternate correctness history filenames.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If important files or target functionalities are specified in [inputs], read them. Combine with [key md files]. Create [important information] - the most relevant code, scripts, and functionalities. If checking the entire repo, include the full pipeline diagram. If checking target functionalities, include upstream/downstream pipeline context.

### Step 2 - Parallel Correctness Check
**[PARALLEL EXECUTION - launch ALL four subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Code A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + [important information] + [inputs]. List important files, order them upstream->downstream, examine correctness, and return [answers 1]. |
| Code B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files] + [inputs]. List all relevant files, order them by pipeline flow, examine correctness, and return [answers 2]. |
| Code C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [inputs]. Decide the reading order and strategy, check the repo for correctness, and return [answers 3]. |
| QA | **QA Engineer** (`agents/qa-engineer.agent.md`) | QA/SQA engineer | Read [key md files] + [inputs]. List runnable scripts, order them by pipeline, run scripts when requested by the user, record errors/unexpected outputs, and return [answers 4]. |

### Step 3 - Main-Agent Draft Correctness Report
The main agent reads [answers 1], [answers 2], [answers 3], and [answers 4]. Combine insights, reject redundant or incorrect parts, read necessary files, and draft [draft correctness report]. Include all script failures from [answers 4].

### Step 4 - Draft Report Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + all relevant scripts + [draft correctness report] + [inputs]. Challenge false positives, overlooked issues, misattributed causes, and incorrect assumptions. Return [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | External resource lookup | Read [key md files] + [draft correctness report] + [inputs]. Identify issues needing external documentation, known dependency bugs, or best-practice references. Search online for reliable resources and solutions. Return [online resource]. |

### Step 5 - Main-Agent Final Correctness Report
The main agent incorporates [valid criticisms] and [online resource], prioritizing codebase evidence over external sources. Finalize the correctness report.

### Step 6 - Documentation
1. Append to past_Correctness_Check.md, using the existing contents to determine the last CC ID (create if missing):
```md
{=============================Correctness Check: (last CC ID + 1)===============================}
Incorrect: (one sentence summary)
Potential Cause: (brief precise bullet points)
```
2. Cross-check known_issues.md. If any found problems were marked as fixed there, add: "the attempted fix actually failed."
