---
name: 'Skill-Based Query'
description: 'Unified skill-backed (skill mode) repo-Q&A workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast workflow, but the challenge and online-research instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback. Read-only.'
---
# Ask about an existing repo

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: the main agent builds a condensed **[repo context digest]** from **[key md files]**, keeps the files themselves as **[full repo context]**, and passes the digest — plus the excerpts of [full repo context] each subagent's task needs — inline to subagents.

> **Skill-backed variant (skill mode).** The challenge and research step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). The codebase-grounded answer-drafting step has no qualifying skill and is unchanged. Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue. Verified star counts and verification dates live **only** in that registry (single source — re-verify there); do not restate them in this file.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - skills/skill_workflow_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - repo_info/past_Q&A.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
-->

This workflow is read-only — it answers questions and does not modify code, so there is no approval gate or implementation step.

[inputs]:
- input 1: target repo, questions
- input 2: important files (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md (under `repo_info/`, resolved by Pack Path Resolution). Read existing past_Q&A.md before drafting or writing a new answer. In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work. The main agent reads [key md files] in Step 1 and hands off repo context per §Context Passing; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). **Every spawn carries two dials, not one:** model from the `subagent_model` header, effort from the `subagent_effort` header (and from `online_researcher_effort` for the Online Researcher). Unless the resolved effort is `inherit`, set the platform effort field where the spawn exposes one, otherwise put the line `effort: <level> — binding budget, not a hint` in the subagent prompt. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Condense the understanding into a [repo context digest] and identify [important information] — the most relevant code, scripts, files, and functionalities for the questions. Per §Context Passing: pass the [repo context digest] inline to subagents, plus the excerpts of [full repo context] each subagent's task needs.

### Step 2 - Answer Drafting
*(Unchanged — no qualifying skill; answers must be grounded in this specific codebase.)*
Based on the repo context (per §Context Passing) + [important information] + [inputs], the main agent reads the relevant files and drafts [draft answers] grounded in the codebase.

### Step 3 - Answer Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | **Skill-backed:** run the challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) — a structured critical-reasoning pass over the repo context (per §Context Passing) + [important information] + [draft answers] + [inputs]. Assume every answer is wrong, flawed, or unsupported, then explain why — challenge factual errors, unsupported claims, missing edge cases, and contradictions with the codebase; report only evidence-backed criticisms. Return [challenge report]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate task as written in the fast workflow. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | **Skill-backed:** draft [online resource] by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`) — plan/search/read/synthesize a **cited report** validating external facts (APIs, tools, packages, versions, best practices) referenced by [draft answers] + [inputs]. The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof — never answer from prior knowledge (see `agents/online-researcher.agent.md`). **Fallback if `deep-research` is unavailable:** perform the Online Researcher task as written in the fast workflow. |

### Step 4 - Final Answers
The main agent incorporates [challenge report] and [online resource] (when produced) into the final answers, prioritizing codebase evidence when it conflicts with external sources. Print the final answers in bullet points.

### Step 5 - Documentation
Append to past_Q&A.md, using the existing contents to determine the last Q&A ID:
```md
{=============================Q&A: (current time, YYYY-MM-DD HH:MM) — (last ID + 1)===============================}
Question: (one sentence summary)
Answer: (brief precise summary in bullet points)
```
