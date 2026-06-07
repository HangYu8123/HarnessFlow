---
name: 'Query Repo (Claude Code)'
description: 'Instructions for answering questions about an existing repo — Claude Code CLI native'
---
# Ask about an existing repo

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

**Safety: follow `_lib/safety_rules.md`.**
[inputs]:
input 1: target repo, questions
input 2: important files

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md`, resolved by the Pack Path Resolution rule, before proceeding.
Every subagent created by this workflow must also read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` before receiving [repo context digest] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md` (resolved by Pack Path Resolution rule).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

Before answering any questions, always, first read the following files from `repo_info/`, resolved by the Pack Path Resolution rule (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
5. past_Q&A.md
Understand them, keep them inside the memory, and create a condensed **[repo context digest]** — a brief summary of the repo structure, key scripts, known issues, and prior Q&A that can be passed to subagents instead of requiring them to re-read every file.
Use `past_Q&A.md` to understand prior questions and answers before drafting or writing a new answer.


then, for answering any questions to an existing codebase:
1. if important files are specified in [inputs], the main agent must read through the important files, then combine the understood knowledge with [key md files].
2. Then, the main agent must decide what are the most relevant codes, scripts, files, and functionalities to the questions from [inputs], and create a list of **BRIEF** [important information].
**[PARALLEL EXECUTION — launch the following subagents simultaneously as Claude Code agent team; if parallel not supported, run sequentially]**
3. the main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`), pass the questions, [important information], and [repo context digest] to the subagent. Based on [important information] and the repo structure from [repo context digest], read every file, function, and script mentioned in [important information]. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 1].
4. the main agent creates a **Broad Analyst** subagent (`agents/broad-analyst.agent.md`), pass the questions, [important information], and [repo context digest] to the subagent. Based on [important information] and the repo structure from [repo context digest], the subagent must go through the repo pipeline and read all scripts associated with the questions, and then read all upstream and downstream scripts associated with the questions along the codebase workflow. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 2].
5. the main agent creates a **Free Analyst** subagent (`agents/free-analyst.agent.md`), pass the questions and [repo context digest] to the subagent. Based on the questions and repo information from [repo context digest], the subagent must decide what files and scripts to read and check to get precise and well-verified answers. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 3].
6. the main agent must read through all three answers ([answers 1], [answers 2], and [answers 3]), read necessary files, understand each of them, combine the advantages of each answer, reject the redundant or incorrect parts of each answer, and draft precise and well-verified answers to answer questions in bullet points.
7. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the following subagents simultaneously as Claude Code agent team; if parallel not supported, run sequentially]**, pass the drafted answers and the original questions to the subagents.

a. The **Devils Advocate** receives [repo context digest] and [important information], then critically challenges the drafted answers — looking for factual errors, unsupported claims, missing edge cases, or contradictions with the codebase. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** receives [repo context digest], [important information], and the original questions, then identifies where online resources are needed to validate external facts, tools, packages, APIs, or current best practices. The subagent MUST actually call the `WebSearch` and `WebFetch` tools to search the live internet (never answer from prior knowledge) and MUST return the source URLs it fetched as proof — see `agents/online-researcher.agent.md`. The subagent reports the findings from online back to the main agent as [online resource].

7.5. The main agent incorporates [valid criticisms] and [online resource], prioritizes codebase evidence when it conflicts with external sources, and finalizes the answers.

8. the main agent must summarize the questions and answers in the following format, for question and answer pair:
{=============================Q&A: (fill an Q&A ID here, simply use last Q&A ID + 1)===============================}
Question: (fill a one sentence summary of the question here.)
Answer: (fill a brief but precise summary of the answer in bullet points here.)
Then the main agent must append it to past_Q&A.md, using the existing contents to determine the last Q&A ID.
