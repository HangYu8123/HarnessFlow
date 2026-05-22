---
name: 'Fast Refactor'
description: 'Streamlined instructions for refactoring with maximum parallelization'
---
# Refactor an Existing Repo

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
- input 1: target refactor functionalities/repository/scripts
- input 2: target files (optional)
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
If input files are specified in [inputs], read them. Combine with [key md files] understanding.

### Step 2 — Parallel Analysis
**[PARALLEL EXECUTION — launch ALL SIX subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Architecture Analyst** (`agents/architecture-analyst.agent.md`) | Architecture | Read [key md files] + refactor targets. Analyze inappropriate designs and architecture improvements. Draft [plan 1] + [comparison 1]. |
| Plan B | **Redundancy Analyst** (`agents/redundancy-analyst.agent.md`) | Redundancy | Read [key md files] + refactor targets. Analyze redundant code and overlapping implementations. Draft [plan 2] + [comparison 2]. |
| Plan C | **Robustness Analyst** (`agents/robustness-analyst.agent.md`) | Robustness | Read [key md files] + refactor targets. Analyze robustness issues and potential bugs. Draft [plan 3] + [comparison 3]. |
| Plan D | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files]. Decide own strategy. Draft [plan 4]. |
| Review E | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Senior code review | Read [key md files]. Identify [associated files]. Read all line-by-line. Produce [code issue report] + [code improvement report]. |
| Plan F | **Complexity Analyst** (`agents/complexity-analyst.agent.md`) | Complexity reduction | Read [key md files] + refactor targets. Use `/simplify` only if the main agent is Claude Code or another Claude agent with Claude Code skills available; otherwise analyze complexity directly. Draft a plan to simplify without changing behavior. Draft [plan 5] + [comparison 4]. |

### Step 3 — Synthesize + Challenge
**[PARALLEL EXECUTION — launch ALL THREE subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Principal | **Principal Engineer** (`agents/principal-engineer.agent.md`) | Principal engineer | Read [key md files] + all repo scripts. Review all plans, comparisons, code reports. Assess correctness/feasibility. Reject redundant/incorrect plans. Return [plan review]. |
| Advocate | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + relevant scripts. Identify side effects, integration risks, incorrect assumptions, regressions. Return [challenge report]. |
| Resource | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + refactor targets. Identify extra needs for skills, tools, packages, patterns, or migration references. Search online for reliable resources and solutions. Return [online resource]. |

Main agent combines [plan 1-5], [comparison 1-4], [code issue report], [code improvement report], [plan review], [challenge report], and [online resource], and reads necessary files. Draft [final plan]. Verify for each step: (1) target files identified, (2) no conflict with known_issues.md, (3) upstream/downstream dependencies covered. Incorporate valid criticisms and relevant online findings. Finalize [final plan].

Print [final plan]. **If user requested no code changes → STOP here.**

### Step 4 — Implementation
Create **Implementer** subagent (`agents/implementer.agent.md`). **Implementer Model Verification (see `_lib/workflow_contract.md`):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon the subagent and perform the implementation directly itself, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`. Pass [final plan] + refactor targets + [key md files]. The subagent (or the main agent, if falling back) implements [final plan]. Returns [implementation report] (changes only, no explanations).

### Step 4.5 — Claude Native Skills
If and only if the main agent is Claude Code or another Claude agent with Claude Code skills available, search .github/harness_coding_instructions/skills/index.md for `claude-native-skills-subagents`, then use the skill at .github/harness_coding_instructions/skills/claude-native-skills-subagents/SKILL.md after step 4. If the main agent is not a Claude agent, skip step 4.5 and continue to step 5.

### Step 5 — Parallel Validation
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Review A | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Senior staff engineer | Read [key md files] + code changes. Review refactor correctness. Challenge the implementation and ensure refactor achieves goals without breaking codebase. Return [code review report]. |
| Review B | **QA Engineer** (`agents/qa-engineer.agent.md`) | QA engineer | Read [key md files] + code changes. Validate the refactor from a QA engineer perspective. If user requested script runs, execute pipeline upstream->downstream. If script fails: log error, continue to next. Return [QA report]. |

### Step 6 — Documentation & Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```
{=============================Refactor Update===============================}
{Refactor Summary + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.
