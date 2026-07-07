---
name: 'Query Repo'
description: 'Instructions for answering questions about an existing repo'
---
# Ask About an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

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

[inputs]:
- input 1: target repo, questions
- input 2: important files

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under `repo_info/`, resolved by the Pack Path Resolution rule).

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a brief summary of the repo structure, key scripts, known issues, and prior Q&A — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.
Use `past_Q&A.md` to understand prior questions and answers before drafting or writing a new answer.

If important files are specified in [inputs], the main agent must read through the important files, then combine the understood knowledge with [key md files].

### Step 2 - Identify Important Information
The main agent decides what are the most relevant codes, scripts, files, and functionalities to the questions from [inputs], and creates a list of **BRIEF** [important information].

### Step 3 - Answer Panel
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass the questions, [important information], and the repo context (per §Context Passing) to the subagents (the Free Analyst receives the questions and the repo context).

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Focus answers | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Always | Based on [important information] and the repo structure from the repo context (per §Context Passing), read every file, function, and script mentioned in [important information]. Answer the questions accordingly. Return [answers 1]. |
| Broad answers | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Always | Based on [important information] and the repo structure from the repo context (per §Context Passing), go through the repo pipeline and read all scripts associated with the questions, then read all upstream and downstream scripts associated with the questions along the codebase workflow. Answer the questions accordingly. Return [answers 2]. |
| Free answers | **Free Analyst** (`agents/free-analyst.agent.md`) | Always | Based on the questions and repo information from the repo context (per §Context Passing), decide what files and scripts to read and check to get precise and well-verified answers. Answer the questions accordingly. Return [answers 3]. |

### Step 4 - Synthesize Answers
The main agent reads through all three answers ([answers 1], [answers 2], and [answers 3]), reads necessary files, understands each of them, combines the advantages of each answer, rejects the redundant or incorrect parts of each answer, and drafts precise and well-verified answers to the questions in bullet points.

### Step 5 - Answer Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass the drafted answers and the original questions to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Receive the repo context (per §Context Passing) and [important information], then critically challenge the drafted answers — looking for factual errors, unsupported claims, missing edge cases, or contradictions with the codebase. Return flaws as [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Receive the repo context (per §Context Passing), [important information], and the original questions, then identify where online resources are needed to validate external facts, tools, packages, APIs, or current best practices. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |

### Step 6 - Finalize Answers
The main agent incorporates [valid criticisms] and [online resource], prioritizes codebase evidence when it conflicts with external sources, and finalizes the answers.

### Step 7 - Record the Q&A
The main agent summarizes the questions and answers in the following format, for each question and answer pair:
```md
{=============================Q&A: (fill an Q&A ID here, simply use last Q&A ID + 1)===============================}
Question: (fill a one sentence summary of the question here.)
Answer: (fill a brief but precise summary of the answer in bullet points here.)
```
Then the main agent must append it to past_Q&A.md, using the existing contents to determine the last Q&A ID.
