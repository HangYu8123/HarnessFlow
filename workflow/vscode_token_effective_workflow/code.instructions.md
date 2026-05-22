---
name: 'Fast Code Implementation'
description: 'Streamlined instructions for implementing new functionalities with maximum parallelization'
---
# Add New Functions to an Existing Repo

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
-->

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target functionalities
- input 2: important files (optional)
- input 3: target repo (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before reading [key md files] or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in #file:../../_lib/workflow_contract.md.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]

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


### Step 3.5 — Final Plan Refinement
**[PARALLEL EXECUTION — launch ALL two subagents in parallel via VS Code Copilot `agent` tool]**
| Advocate | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + all relevant scripts. Identify overlooked side effects, integration risks, incorrect assumptions, regressions. Return [challenge report]. |
| Resource | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files]. Identify extra needs for skills, tools, and packages. Search online for reliable resources and solutions. Return [online resource]. |

**If user requested no code changes → STOP here and print [final plan].**

### Step 4 — Parallel Implementation
Based on the [final plan], identify how many files need to be changed/created.
For each file, create an **Implementer** subagent (`agents/implementer.agent.md`).
**Implementer Model Verification (see `_lib/workflow_contract.md`):** Before each **Implementer** subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon that subagent and perform that file's implementation directly itself, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`.
The main agent then breaks down [final plan] into [file-level tasks].
The main agent creates subagents, passes [file-level tasks] + [key md files] to each subagent. Subagents implement [file-level tasks]. Return [single agent implementation reports] (changes only, no explanations).
Then main agent collects all [single agent implementation reports], reviews them for correctness, and applies the changes to the codebase. If any implementation fails, main agent must fix the issue (either by self-debugging or by creating a debug subagent) before proceeding to the next steps.
Then main agent summarizes the implementation into one [implementation report].

### Step 4.5 — Claude Native Skills
If and only if the main agent is Claude Code or another Claude agent with Claude Code skills available, search .github/harness_coding_instructions/skills/index.md for `claude-native-skills-subagents`, then use the skill at .github/harness_coding_instructions/skills/claude-native-skills-subagents/SKILL.md after step 4. If the main agent is not a Claude agent, skip step 4.5 and continue to step 5.

### Step 5 — Parallel Validation
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Review A | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Senior staff engineer | Read [key md files] + code changes. Review implementation correctness. Challenge the implementation and ensure new functionalities work without breaking codebase. Return [code review report]. |
| Review B | **QA Engineer** (`agents/qa-engineer.agent.md`) | QA engineer | Read [key md files] + code changes. Validate the implementation from a QA engineer perspective. If user requested script runs, execute pipeline upstream->downstream. If script fails: log error, continue to next. Return [QA report]. |

### Step 6 — Documentation & Summary
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
