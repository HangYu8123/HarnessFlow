---
name: 'Fast Query'
description: 'Streamlined repo Q&A: main-agent answer drafting with one parallel challenge + research subagent step. Read-only'
---
# Ask About an Existing Repo

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Q&A.md
-->

**Safety: follow `_lib/safety_rules.md`.**

This workflow is read-only — it answers questions and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `#file:../../_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under .github/HarnessFlow/repo_info). Read existing past_Q&A.md before drafting or writing a new answer.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Condense the understanding and identify [important information] — the most relevant code, scripts, files, and functionalities for the questions.

### Step 2 - Answer Drafting
Based on [key md files] + [important information] + [inputs], the main agent reads the relevant files and drafts [draft answers] grounded in the codebase.

### Step 3 - Answer Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [key md files] + [important information] + [draft answers] + [inputs], and additional files if needed. Assume [draft answers] are wrong and flawed; challenge factual errors, unsupported claims, missing edge cases, and contradictions with the codebase. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [key md files] + [draft answers] + [inputs]. Search online to validate external facts (APIs, tools, versions) and find reliable references. Return [online resource]. |

### Step 4 - Final Answers
The main agent incorporates [challenge report] and [online resource] (when produced) into the final answers, prioritizing codebase evidence when it conflicts with external sources. Print the final answers in bullet points.

### Step 5 - Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```md
{=============================Q&A: (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```
