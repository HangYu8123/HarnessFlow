---
name: 'Fast Query'
description: 'Unified token-effective (fast) workflow for Claude Code, Codex, and VS Code Copilot: main-agent answer drafting with one parallel challenge + research subagent step. Read-only.'
---
# Ask about an existing repo

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

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

This workflow is read-only — it answers questions and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/repo_info/`, resolved by Pack Path Resolution). Read existing past_Q&A.md before drafting or writing a new answer. In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work. The main agent reads [key md files] in Step 1 and hands off repo context per §Context Passing; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Condense the understanding into a [repo context digest] and identify [important information] — the most relevant code, scripts, files, and functionalities for the questions. Per §Context Passing: on **Claude Code** pass the [repo context digest] inline to subagents; on **Codex** and **VS Code Copilot** keep [key md files] for subagents to read directly.

### Step 2 - Answer Drafting
Based on the repo context (per §Context Passing) + [important information] + [inputs], the main agent reads the relevant files and drafts [draft answers] grounded in the codebase.

### Step 3 - Answer Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Receive the repo context (per §Context Passing) + [important information] + [draft answers] + [inputs]; read additional files if needed. Assume every item in [draft answers] is wrong, flawed, or unsupported, then explain why — challenge factual errors, unsupported claims, missing edge cases, and contradictions with the codebase. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Receive the repo context (per §Context Passing) + [draft answers] + [inputs]. Identify where online resources are needed, then actually call the platform's live web search/fetch tool(s) to validate external facts (APIs, tools, packages, versions, best practices) and find reliable references — never answer from prior knowledge — and return the source URLs as proof (see `agents/online-researcher.agent.md`). Return [online resource]. |

### Step 4 - Final Answers
The main agent incorporates [challenge report] and [online resource] (when produced) into the final answers, prioritizing codebase evidence when it conflicts with external sources. Print the final answers in bullet points.

### Step 5 - Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```md
{=============================Q&A: (current time, YYYY-MM-DD HH:MM) — (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```
