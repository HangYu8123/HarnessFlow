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

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in _lib/workflow_contract.md.
- Before creating any subagent, the main agent must identify [main agent model].
- Every subagent prompt must include [inputs], exact task, expected output label, required context files, and: "**Create subagent with the exact [main agent model] - do not downgrade.**"
- Subagents must use [main agent model].
- After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.
- If a subagent is not created, uses a different model, fails, or returns a low-quality or irrelevant result, retry that same subagent up to 3 times. If it still fails, the main agent performs that subagent's task directly and records a [fallback result].

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using Codex agent workers when available. This applies to Codex CLI and Codex running in VS Code; if worker spawning or model parity is unavailable, run the same tasks sequentially or perform the documented fallback in the main agent.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under .github/harness_coding_instructions/repo_info). Read existing past_Q&A.md before drafting or writing a new answer.

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
