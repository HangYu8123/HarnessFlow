---
name: 'Fast Query'
description: 'Streamlined instructions for answering repo questions with maximum parallelization'
---
# Ask About an Existing Repo

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Q&A.md
-->

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

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

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under .github/harness_coding_instructions/repo_info). Read existing past_Q&A.md before drafting or writing a new answer.

---

## CREATE ONE TODO PER STEP

### Step 1 — Context Gathering
If important files are specified in [inputs], read them. Combine with [key md files]. Identify [important information] — most relevant codes, scripts, files, functionalities to the questions.

### Step 2 — Parallel Research + Challenge
**[PARALLEL EXECUTION — launch ALL FIVE subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Code A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + every file in [important information]. Answer questions. Return [answers 1]. |
| Code B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files]. Follow pipeline, read all upstream/downstream scripts. Answer questions. Return [answers 2]. |
| Code C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files]. Decide own reading strategy to get 100% correct answers. Return [answers 3]. |
| Advocate | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + [important information]. Challenge answers for factual errors, unsupported claims, missing edge cases, contradictions. Return [challenge report]. |
| Resource | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + [important information] + original questions. Identify where online resources are needed to validate external facts, tools, packages, APIs, or current best practices. Search online for reliable resources and solutions. Return [online resource]. |

### Step 3 — Synthesize & Finalize
Main agent reads [answers 1], [answers 2], [answers 3], [challenge report], and [online resource], and reads necessary files. Combine advantages, reject redundant/incorrect parts. Incorporate valid criticisms and relevant online findings, prioritizing codebase evidence when it conflicts with external sources. Draft precise final answers.

### Step 4 — Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```
{=============================Q&A: (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```
