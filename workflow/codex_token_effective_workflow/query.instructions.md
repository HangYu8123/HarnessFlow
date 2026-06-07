---
name: 'Token-Effective Query Repo (Codex)'
description: 'Token-effective Codex instructions for answering repo questions with Codex agent workers, Codex-in-VS-Code compatibility, and sequential fallback'
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

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under .github/HarnessFlow/repo_info). Read existing past_Q&A.md before drafting or writing a new answer.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If important files are specified in [inputs], read them. Combine with [key md files]. Identify [important information] - the most relevant code, scripts, files, and functionalities for the questions.

### Step 2 - Parallel Answer Drafting
**[PARALLEL EXECUTION - launch ALL three subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Code A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + [important information] + [inputs]. Answer the questions from the most relevant files. Return [answers 1]. |
| Code B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files] + [inputs]. Follow the pipeline and read upstream/downstream scripts needed for the questions. Return [answers 2]. |
| Code C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [inputs]. Decide the reading strategy needed for correct answers. Return [answers 3]. |

### Step 3 - Main-Agent Draft Answers
The main agent reads [answers 1], [answers 2], and [answers 3], then reads any necessary files. Combine advantages, reject redundant or incorrect parts, and draft [draft answers].

### Step 4 - Draft Answer Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + [important information] + [draft answers] + [inputs]. Challenge answers for factual errors, unsupported claims, missing edge cases, and contradictions. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + [important information] + [draft answers] + [inputs]. Identify where online resources are needed to validate external facts, tools, packages, APIs, or current best practices. Search online for reliable resources and solutions. Return [online resource]. |

### Step 5 - Main-Agent Final Answers
The main agent incorporates [challenge report] and [online resource], prioritizing codebase evidence when it conflicts with external sources. Draft precise final answers.

### Step 6 - Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```md
{=============================Q&A: (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```
