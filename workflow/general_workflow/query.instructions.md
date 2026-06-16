---
name: 'Query Repo'
description: 'Instructions for answering questions about an existing repo'
---
# Ask about an existing repo

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
input 1: target repo, questions
input 2: important files

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

Before answering any questions, always, first read the following files from `repo_info/`, resolved by the Pack Path Resolution rule (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
5. past_Q&A.md
Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a brief summary of the repo structure, key scripts, known issues, and prior Q&A — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.
Use `past_Q&A.md` to understand prior questions and answers before drafting or writing a new answer.


then, for answering any questions to an existing codebase:
1. if important files are specified in [inputs], the main agent must read through the important files, then combine the understood knowledge with [key md files].
2. Then, the main agent must decide what are the most relevant codes, scripts, files, and functionalities to the questions from [inputs], and create a list of **BRIEF** [important information].
**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**
3. the main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`), pass the questions, [important information], and the repo context (per §Context Passing) to the subagent. Based on [important information] and the repo structure from the repo context (per §Context Passing), read every file, function, and script mentioned in [important information]. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 1].
4. the main agent creates a **Broad Analyst** subagent (`agents/broad-analyst.agent.md`), pass the questions, [important information], and the repo context (per §Context Passing) to the subagent. Based on [important information] and the repo structure from the repo context (per §Context Passing), the subagent must go through the repo pipeline and read all scripts associated with the questions, and then read all upstream and downstream scripts associated with the questions along the codebase workflow. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 2].
5. the main agent creates a **Free Analyst** subagent (`agents/free-analyst.agent.md`), pass the questions and the repo context (per §Context Passing) to the subagent. Based on the questions and repo information from the repo context (per §Context Passing), the subagent must decide what files and scripts to read and check to get precise and well-verified answers. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 3].
6. the main agent must read through all three answers ([answers 1], [answers 2], and [answers 3]), read necessary files, understand each of them, combine the advantages of each answer, reject the redundant or incorrect parts of each answer, and draft precise and well-verified answers to answer questions in bullet points.
7. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, pass the drafted answers and the original questions to the subagents.

a. The **Devils Advocate** receives the repo context (per §Context Passing) and [important information], then critically challenges the drafted answers — looking for factual errors, unsupported claims, missing edge cases, or contradictions with the codebase. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** receives the repo context (per §Context Passing), [important information], and the original questions, then identifies where online resources are needed to validate external facts, tools, packages, APIs, or current best practices. The subagent MUST actually call its platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs it fetched as proof — see `agents/online-researcher.agent.md`. The subagent reports the findings from online back to the main agent as [online resource].

7.5. The main agent incorporates [valid criticisms] and [online resource], prioritizes codebase evidence when it conflicts with external sources, and finalizes the answers.

8. the main agent must summarize the questions and answers in the following format, for question and answer pair:
{=============================Q&A: (fill an Q&A ID here, simply use last Q&A ID + 1)===============================}
Question: (fill a one sentence summary of the question here.)
Answer: (fill a brief but precise summary of the answer in bullet points here.)
Then the main agent must append it to past_Q&A.md, using the existing contents to determine the last Q&A ID.
