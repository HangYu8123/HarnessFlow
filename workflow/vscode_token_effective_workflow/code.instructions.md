---
name: 'Fast Code Implementation'
description: 'Streamlined instructions for implementing new functionalities with maximum parallelization'
---
# Add New Functions to an Existing Repo

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: [target functionalities]
- input 2: [important files] (optional)
- input 3: [target repo] (optional, default to current repo)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in #file:../../_lib/workflow_contract.md.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]
- If a subagent's model does not match [main agent model], the main agent stop that subagent and re-create it (retry up to 3 times). If after 3 retries, the main agent must abandon that subagent and perform that subagent's task directly itself. 

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using VS Code Copilot's native `agent` tool. Coordinator agents declare `tools: ['agent']` and `agents: [...]` to orchestrate subagent invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/harness_coding_instructions/repo_info).

---

## CREATE ONE TODO PER STEP

### Step 1 — Context Gathering
If important files are specified in [inputs], read them. Combine with [key md files] understanding.

### Step 2 — Parallel Planning & Review
**[PARALLEL EXECUTION — launch ALL three subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files]. Identify highly associated scripts/files, read them. Draft [plan 1] + [diagram 1] for integrating new functionalities while keeping codebase stable. |
| Plan B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files]. Follow pipeline upstream->downstream, read all scripts. Draft [plan 2] + [diagram 2] for integrating new functionalities. |
| Plan C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files]. Decide own reading strategy. Draft [plan 3] with integration approach. |


### Step 3 — Synthesize Final Plan
Main agent reviews [plan 1], [plan 2], [plan 3], [diagram 1], [diagram 2], [challenge report], and [online resource], and reads necessary files. Reject incorrect/redundant parts. Incorporate valid criticisms from [challenge report] and relevant findings from [online resource]. Draft [final plan] that is feasible, stable, and 100% correct.


### Step 4 — Final Plan Refinement
**[PARALLEL EXECUTION — launch ALL two subagents in parallel via VS Code Copilot `agent` tool]**
| Advocate | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + all relevant scripts + [final plan]. Identify overlooked side effects, integration risks, incorrect assumptions, regressions. Return [challenge report]. |
| Resource | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + [final plan]. Identify extra needs for skills, tools, and packages. Search online for reliable resources and better solutions. Return [online resource]. |

**If user requested no code changes → STOP here and print [final plan].**

### Step 5 — Pre-Implementation Review
Main agent reviews [challenge report] and [online resource]. The main agent improve and finalize [final plan] by incorporating valid criticisms from [challenge report] and findings from [online resource].

### Step 6 — Implementation
Create **Implementer** subagent (`agents/implementer.agent.md`). **Implementer Model Verification (see `_lib/workflow_contract.md`):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon the subagent and perform the implementation directly itself, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`. Pass [final plan] + refactor targets + [key md files]. The subagent (or the main agent, if falling back) implements [final plan]. Returns [implementation report] (changes only, no explanations).



### Step 6 — Validation

The main agent reviews [implementation report], reads changed files, and validates that the implementation matches [final plan], codes are correct and highquality, and is free of new issues. If any problems are found, go step 2. This loop continues until the implementation is correct and complete.

### Step 7 — Documentation & Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```
{=============================Function Update===============================}
{Functionality Name + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
