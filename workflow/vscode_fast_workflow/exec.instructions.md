---
name: 'Fast Cmd/Skill Execution'
description: 'Streamlined instructions for executing commands and skills with maximum parallelization'
---
# Execute cmds/skills in a repo

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
- input 1: target cmds/skills to execute
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

### Step 2 — Parallel Planning, Challenge & Research
**[PARALLEL EXECUTION — launch ALL FOUR subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files]. Identify associated scripts/files for the target cmds/skills, read them. Draft [plan 1] + [diagram 1] covering pre-conditions, commands to run, expected outputs, and failure modes. |
| Plan B | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files]. Decide own reading strategy. Draft [plan 2] with execution approach and validation criteria. |
| Advocate | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + all relevant scripts. Identify wrong flags, destructive side effects, missing prerequisites, environment assumptions. Return [challenge report]. |
| Resource | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files]. Identify needs for tools, command syntax, known issues, version compatibility. Search online for reliable resources. Return [online resource]. |

### Step 3 — Synthesize Execution Plan
Main agent reviews [plan 1], [plan 2], [diagram 1], [challenge report], and [online resource], and reads necessary files. Reject incorrect/redundant parts. Incorporate valid criticisms from [challenge report] and relevant findings from [online resource]. Draft [final plan] covering: exact commands to run, pre-conditions, expected outputs, validation criteria, and rollback strategy. The plan must be feasible, safe, and 100% correct.

**If user requested no execution → STOP here and print [final plan].**

### Step 4 — Execution
Create an **Executor** subagent (`agents/executor.agent.md`).
**Executor Model Verification (see `_lib/workflow_contract.md`):** Before the **Executor** subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon that subagent and perform the execution directly itself, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: executor-model-mismatch`.
Pass [final plan] + target cmds/skills to the Executor. The Executor:
1. Reads [key md files]
2. Validates pre-conditions (environment, dependencies, required files)
3. Executes cmds/skills per [final plan], capturing stdout, stderr, exit codes
4. If a command fails, records the failure and continues unless [final plan] specifies otherwise
5. Generates [execution report]: commands run, outputs, exit codes, pass/fail (no explanations)

### Step 4.5 — Claude Native Skills
If and only if the main agent is Claude Code or another Claude agent with Claude Code skills available, and the execution produced or modified files, search .github/harness_coding_instructions/skills/index.md for `claude-native-skills-subagents`, then use the skill at .github/harness_coding_instructions/skills/claude-native-skills-subagents/SKILL.md after step 4. If the main agent is not a Claude agent or no files were modified, skip step 4.5 and continue to step 5.

### Step 5 — Parallel Result Analysis
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Review A | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Execution correctness reviewer | Read [key md files] + [execution report]. Analyze whether execution produced correct/expected results. Validate output against expected outcomes from [final plan]. Identify unexpected behaviors or anomalies. Return [execution review report]. |
| Review B | **QA Engineer** (`agents/qa-engineer.agent.md`) | Execution side-effect reviewer | Read [key md files] + [execution report]. Check for side effects, state changes, file modifications, errors. If user requested validation runs, execute validation scripts. Return [execution QA report]. |

### Step 6 — Documentation & Summary
1. If execution changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```
{=============================Execution Update===============================}
{Cmd/Skill Name + Execution ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Commands/Skills executed (what was run and parameters)}
{Result (success/failure, key outputs, side effects)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize execution results in bullet points to chat.
