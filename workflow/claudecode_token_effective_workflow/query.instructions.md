---
name: 'Fast Query (Claude Code)'
description: 'Fast repo Q&A for Claude Code: main-agent answer drafting with parallel challenge + research subagents. Read-only'
---
# Ask About an Existing Repo

This workflow is read-only — it answers questions and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under .github/HarnessFlow/repo_info). Read existing past_Q&A.md before drafting or writing a new answer.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents read repo_info/codebase_overview.md and repo_info/scripts_overview.md directly.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Condense into a [repo context digest] and identify [important information] — the most relevant code, scripts, files, and functionalities for the questions.

### Step 2 - Answer Drafting
Based on [repo context digest] + [important information] + [inputs], read the relevant files and draft [draft answers] grounded in the codebase.

### Step 3 - Answer Challenge and Research
**Spawn 2 subagents in parallel.** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [repo context digest] + [important information] + [draft answers] + [inputs]. Read additional files if needed. Assume [draft answers] are wrong and flawed; challenge factual errors, unsupported claims, missing edge cases, and contradictions with the codebase. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [repo context digest] + [draft answers] + [inputs]. Search online to validate external facts (APIs, tools, versions) and find reliable references. Return [online resource]. |

### Step 4 - Final Answers
The main agent incorporates [challenge report] and [online resource] (when produced) into the final answers, prioritizing codebase evidence when it conflicts with external sources. Print the final answers in bullet points.

### Step 5 - Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```md
{=============================Q&A: (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```
