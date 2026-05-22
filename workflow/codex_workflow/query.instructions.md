---
name: 'Query Repo (Codex)'
description: 'Instructions for answering questions about an existing repo — Codex CLI native'
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

**DO NOT TRY TO COMMIT CHANGES TO GITHUB**
**DO NOT WRITE SPAM FILES INTO THE REPO**
**DO NOT USE SUDO**
[inputs]:
input 1: target repo, questions
input 2: important files

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` before proceeding.
Every subagent created by this workflow must also read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in `_lib/workflow_contract.md`.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]

## Subagent Definitions
When creating subagents, invoke them by their agent name. Codex CLI discovers agent definitions from `agents/` directory. For parallel execution, use Codex agent workers with concurrency controlled by `agents.max_threads` in the Codex configuration. If parallel agent workers are not available, launch subagents sequentially — the results are equivalent.

Before answering any questions, always, first read the following files .github/harness_coding_instructions/repo_info (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
5. past_Q&A.md
Understand them, and keep them inside the memory.
Use `past_Q&A.md` to understand prior questions and answers before drafting or writing a new answer.


then, for answering any questions to an existing codebase:
1. if important files are specified in [inputs], the main agent must read through the important files, then combine the understood knowledge with [key md files].
2. Then, the main agent must decide what are the most relevant codes, scripts, files, and functionalities to the questions from [inputs], and create a list of **BRIEF** [important information].
**[PARALLEL EXECUTION via Codex agent workers — launch in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]**
3. the main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`), pass the questions and [important information] to the subagent. The subagent must also read through [key md files]. Based on [important information] and the repo structure from [key md files], read every file, function, and script mentioned in [important information]. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 1].
4. the main agent creates a **Broad Analyst** subagent (`agents/broad-analyst.agent.md`), pass the questions and [important information] to the subagent. The subagent must also read through [key md files]. Based on [important information] and the repo structure from [key md files], the subagent must go through the repo pipeline and read all scripts associated with the questions, and then read all upstream and downstream scripts associated with the questions along the codebase workflow. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 2].
5. the main agent creates a **Free Analyst** subagent (`agents/free-analyst.agent.md`), pass the questions to the subagent. The subagent must also read through [key md files]. Based on the questions and repo information from [key md files], the subagent must decide what files and scripts to read and check to get 100% correct answers. Then, the subagent must answer the questions accordingly, and report the answers back to the main agent as [answers 3].
6. the main agent must read through all three answers ([answers 1], [answers 2], and [answers 3]), read necessary files, understand each of them, combine the advantages of each answer, reject the redundant or incorrect parts of each answer, and draft precise and 100% correct answers to answer questions in bullet points.
7. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION via Codex agent workers — launch in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]**, pass the drafted answers and the original questions to the subagents.

a. The **Devils Advocate** must read through [key md files] and [important information], then critically challenge the drafted answers — looking for factual errors, unsupported claims, missing edge cases, or contradictions with the codebase. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** must read through [key md files], [important information], and the original questions, then identify where online resources are needed to validate external facts, tools, packages, APIs, or current best practices. The subagent searches online for reliable resources and solutions. The subagent reports the findings from online back to the main agent as [online resource].

7.5. The main agent incorporates [valid criticisms] and [online resource], prioritizes codebase evidence when it conflicts with external sources, and finalizes the answers.

8. the main agent must summarize the questions and answers in the following format, for question and answer pair:
{=============================Q&A: (fill an Q&A ID here, simply use last Q&A ID + 1)===============================}
Question: (fill a one sentence summary of the question here.)
Answer: (fill a brief but precise summary of the answer in bullet points here.)
Then the main agent must append it to past_Q&A.md, using the existing contents to determine the last Q&A ID.
