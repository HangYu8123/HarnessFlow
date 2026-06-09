---
name: 'Fast Query (Claude Code)'
description: 'Fast repo Q&A for Claude Code: repo-grounded answers with optional analyst exploration and external fact-checking. Read-only'
---
# Ask About an Existing Repo

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - workflow/claudecode_token_effective_workflow/_fast_rules.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Q&A.md
-->

**Safety: follow `_lib/safety_rules.md`.** This workflow is read-only — it answers questions and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.
> **Fast-tier rules (apply to every step below):** See `workflow/claudecode_token_effective_workflow/_fast_rules.md` — no Broad Analyst, single-analyst default (main answers focused questions directly), conditional Devils Advocate / Online Researcher.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under .github/HarnessFlow/repo_info). Read existing past_Q&A.md before drafting or writing a new answer.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If important files are specified in [inputs], read them. Combine with [key md files] into [repo context digest]. Identify [important information] — the most relevant code, scripts, files, and functionalities for the questions.

### Step 2 - Answer Drafting
Per _fast_rules §1: for a focused question answerable from [important information], the **main agent reads those files and answers directly** — skip to Step 5. For a broad / whole-repo question, launch **one Free Analyst** (`agents/free-analyst.agent.md`): pass the questions + [important information] + [repo context digest]; it decides the reading strategy across upstream/downstream scripts and returns [answers].

### Step 3 - Main-Agent Draft Answers
If a Free Analyst ran, the main agent reads [answers], reads any necessary files, rejects redundant or incorrect parts, and drafts [draft answers]. (If the main agent answered directly in Step 2, that is [draft answers].)

### Step 4 - Draft Answer Challenge and Research (conditional)
Per _fast_rules §4–5, spawn only when triggered; otherwise the main agent self-checks against codebase evidence.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | high-stakes or contested answer | Read [important information] + [draft answers] + [inputs]. Challenge factual errors, unsupported claims, missing edge cases, and contradictions with the codebase. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | answer depends on external facts/APIs/tools/versions | Read [important information] + [draft answers] + [inputs]. Search online to validate the external facts. Return [online resource]. |

### Step 5 - Main-Agent Final Answers
The main agent incorporates [challenge report] and [online resource] (when produced), prioritizing codebase evidence when it conflicts with external sources, and drafts precise final answers in bullet points.

### Step 6 - Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```md
{=============================Q&A: (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```
