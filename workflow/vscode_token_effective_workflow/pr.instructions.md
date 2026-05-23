---
name: 'Fast PR Creation'
description: 'Streamlined instructions for breaking down and creating pull requests from feature branches using the breakdown-pr skill'
---
# Create Pull Requests from a Feature Branch

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/breakdown-pr/SKILL.md
-->

**DO NOT COMMIT TO GITHUB WITHOUT USER APPROVAL | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target branch (optional, defaults to current branch)
- input 2: base branch (optional, defaults to repo default branch)
- input 3: mode - `plan` or `execute` (optional, defaults to `execute`)
- input 4: max lines per PR (optional, defaults to 1000)
- input 5: stack tool preference (optional, auto-detect)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `#file:../../_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/harness_coding_instructions/repo_info).

Also read the breakdown-pr skill at #file:../../skills/breakdown-pr/SKILL.md and keep it as [breakdown-pr skill].

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
If a target branch is specified in [inputs], inspect the branch and its diff against the base branch. Combine with [key md files] and [breakdown-pr skill]. Additionally, the main agent must:
- Run `git diff --name-only <base>...<branch>` to produce a complete [diff file manifest].
- Read the repository's `.gitignore` files and record [gitignore patterns].
- Identify auto-generated files in the diff by checking ignored patterns, common generated directories, lockfiles, compiled outputs, and auto-generation headers. Record these as [auto-generated files].
- Produce [filtered diff manifest] = [diff file manifest] minus [auto-generated files]. Log excluded auto-generated files so the user can override if needed.
- Pass [inputs], [diff file manifest], [filtered diff manifest], [gitignore patterns], and [auto-generated files] to all subagents.

### Step 2 - Parallel PR Planning
**[PARALLEL EXECUTION - launch ALL three subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + [breakdown-pr skill] + [inputs]. Analyze the diff, identify change types and logical groupings, use [filtered diff manifest] as the authoritative file list, exclude [auto-generated files], and draft [pr plan 1] + [dependency graph 1]. Every file must be assigned to exactly one PR. |
| Plan B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files] + [breakdown-pr skill] + [inputs]. Follow pipeline upstream->downstream, analyze pipeline impact, use [filtered diff manifest] as the authoritative file list, and draft [pr plan 2] + [dependency graph 2]. Every file must be assigned to exactly one PR. |
| Plan C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [breakdown-pr skill] + [inputs]. Decide the reading strategy, analyze the diff, use [filtered diff manifest] as the authoritative file list, and draft [pr plan 3]. Every file must be assigned to exactly one PR. |

### Step 3 - Main-Agent Final PR Plan
The main agent reviews [pr plan 1], [pr plan 2], [pr plan 3], [dependency graph 1], and [dependency graph 2], then reads necessary files. Reject incorrect or redundant parts. Draft [final pr plan] following the [breakdown-pr skill] output format. The plan must be feasible, each PR must be buildable, and the entire filtered diff must be covered.

Mandatory file completeness verification: after drafting [final pr plan], run `git diff --name-only <base>...<branch>` again and cross-reference the output against the files listed in [final pr plan]. Every file in [filtered diff manifest] must appear in exactly one PR. If any file is missing, add it to the most appropriate PR. If any file in the plan matches [gitignore patterns] or is in [auto-generated files], remove it unless the user explicitly requested its inclusion. Log discrepancies found and resolved.

### Step 4 - Final PR Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + [breakdown-pr skill] + [final pr plan] + [inputs]. Identify PRs that would break the build, incorrect dependency ordering, mixed concerns, missing changes, or stacking risks. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files] + [breakdown-pr skill] + [final pr plan] + [inputs]. Identify better stacking strategies, tools, or conventions. Search online for reliable solutions. Return [online resource]. |

### Step 5 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] into [final pr plan], then reruns the file completeness verification. Print [final pr plan].

**Approval gate:** See `_lib/approval_gate.md`.

### Step 6 - PR Stack Execution
Create **Implementer** subagent (`agents/implementer.agent.md`). Pass [final pr plan] + [inputs] + [key md files] + [breakdown-pr skill].

**Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback.

The subagent (or the main agent, if falling back) executes the PR stack creation following [breakdown-pr skill] step 6:
- Confirm the working tree policy for uncommitted changes.
- Record the original source branch and intended final stack top.
- Create each branch from the base or previous stack branch.
- Move changes using the safest granularity.
- Commit each PR with the approved title and concise body.
- Submit using the approved stack tool if approved by the user; otherwise stop after local branches are prepared.

Return [execution report] containing branches created, commits made, PRs submitted, and failures, with no explanations.

### Step 7 - Main-Agent Stack Review and QA
The main agent reads [execution report], verifies branch/commit structure, checks dependency order, ensures no unrelated or auto-generated files are included, confirms all necessary files are present, and verifies the final stack top matches the original branch diff.

Create **QA Engineer** subagent (`agents/qa-engineer.agent.md`). Pass [inputs] + [final pr plan] + [execution report] + [breakdown-pr skill]. The subagent runs [breakdown-pr skill] step 7 verification, including `git diff --exit-code` and `git range-diff` where appropriate. Return [pr stack QA report].

If the main-agent review or [pr stack QA report] finds issues, revise [final pr plan] and repeat the relevant execution or repair step.

### Step 8 - Documentation and Summary
1. Update update_logs.md with PR creation activity summary.
2. Write to update_logs.md:
```md
{=============================PR Creation Update===============================}
{PR Title and PR number in stack (e.g., PR 1/5)}
{PR description (one or two sentences of what the PR contains)}
{Branch name}
{Files changed}
{Dependencies (which PRs must land before this one)}
{Status (created / submitted / failed - and reason if failed)}
```
3. Summarize the PR stack in bullet points to chat.
