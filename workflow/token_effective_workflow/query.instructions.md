---
name: 'Fast Query'
description: 'Unified token-effective (fast) workflow for Claude Code, Codex, and VS Code Copilot: main-agent answer drafting with one parallel challenge + research subagent step. Read-only.'
---
# Ask about an existing repo

**Safety: follow `_lib/safety_rules.md`.**

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/subagent_effectiveness.md
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

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under `repo_info/`, resolved by Pack Path Resolution). Read existing past_Q&A.md before drafting or writing a new answer. In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work. The main agent reads [key md files] in Step 1 and hands off repo context per §Context Passing; subagents must not re-read [key md files] unless a specific file path is needed for their task.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Condense the understanding into a [repo context digest] and identify [important information] — the most relevant code, scripts, files, and functionalities for the questions. Per §Context Passing: pass the [repo context digest] inline to subagents, plus the excerpts of [full repo context] each subagent's task needs.

### Step 2 - Answer Drafting
Based on the repo context (per §Context Passing) + [important information] + [inputs], the goal for the agent is to correctly ad comprehensively answer the queries, the main agent reads the relevant files and drafts [draft answers] grounded in the codebase.

### Step 3 - Answer Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Receive the repo context (per §Context Passing) + [important information] + [draft answers] + [inputs]; read additional files if needed. Assume every item in [draft answers] is wrong, flawed, or unsupported, then explain why — challenge factual errors, unsupported claims, missing edge cases, and contradictions with the codebase. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Receive the repo context (per §Context Passing) + [draft answers] + [inputs]. Identify where online resources are needed, then actually call the platform's live web search/fetch tool(s) to validate external facts (APIs, tools, packages, versions, best practices) and find reliable references — never answer from prior knowledge — and return the source URLs as proof (see `agents/online-researcher.agent.md`). Return [online resource]. |

### Step 4 - Final Answers
The main agent incorporates [challenge report] and [online resource] (when produced) into the final answers, prioritizing codebase evidence when it conflicts with external sources. Print the final answers in bullet points.

### Step 5 - Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```md
{=============================Q&A: (current time, YYYY-MM-DD HH:MM) — (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```

### Step 6 - Subagent Effectiveness Record
Record [subagent effectiveness] per [`_lib/subagent_effectiveness.md`](../../_lib/subagent_effectiveness.md): for each opt-in helper this workflow actually ran — Devils Advocate, Diversifier, Online Researcher, `simplify`, `code_review` — write exactly two sentences (what it contributed, anchored to the accept/reject adjudication already recorded; then a `useful` / `partly useful` / `not useful` verdict in a few words), then append the entry to `repo_info/subagent_effectiveness.md`.
