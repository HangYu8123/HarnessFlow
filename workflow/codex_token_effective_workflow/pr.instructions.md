---
name: 'Token-Effective PR Creation (Codex)'
description: 'Token-effective Codex instructions for breaking down and creating pull requests: main-agent diff analysis with file-completeness verification, one parallel challenge + research subagent step, and direct stack execution — with Codex agent workers and sequential fallback'
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
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent reads [key md files] in Step 1 and passes a context digest to each subagent; subagents must not re-read [key md files] unless a specific file path is needed for their task.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under .github/HarnessFlow/repo_info).

Also read the breakdown-pr skill at skills/breakdown-pr/SKILL.md and keep it as [breakdown-pr skill].

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files] and [breakdown-pr skill]. Inspect the target branch and its diff against the base branch. Additionally:
- Run `git diff --name-only <base>...<branch>` to produce a complete [diff file manifest].
- Read the repository's `.gitignore` files and record [gitignore patterns].
- Identify auto-generated files in the diff (ignored patterns, common generated directories, lockfiles, compiled outputs, auto-generation headers). Record [auto-generated files].
- Produce [filtered diff manifest] = [diff file manifest] minus [auto-generated files]. Log excluded auto-generated files so the user can override if needed.

### Step 2 - PR Planning
**Local skill discovery (before drafting [plan]):** [breakdown-pr skill] is already loaded and integrated as the primary skill. Additionally perform Local Skill Discovery per `_lib/local_skill_discovery.md` for any *other* local skill relevant to this task (skip breakdown-pr during matching); record the result as [local skills] (or "none relevant") and integrate it into [plan].

Based on the Step 1 manifests + [breakdown-pr skill] + [inputs], the main agent analyzes the diff, identifies change types and logical groupings, and proposes a [plan] + [dependency graph] following the [breakdown-pr skill] output format. Use [filtered diff manifest] as the authoritative file list; **every file in [filtered diff manifest] must be assigned to exactly one PR**, and each PR must be buildable.

File completeness verification: after drafting [plan], rerun `git diff --name-only <base>...<branch>` and cross-reference the output against [plan]. Add missing files to the most appropriate PR; remove files matching [gitignore patterns] or [auto-generated files] unless the user explicitly requested their inclusion. Log discrepancies found and resolved.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Read [breakdown-pr skill] + [plan] + [dependency graph] + [inputs], and additional files if needed. Assume the [plan] is wrong and flawed; identify PRs that would break the build, incorrect dependency ordering, mixed concerns, missing changes, and stacking risks. Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Read [breakdown-pr skill] + [plan] + [inputs]. Search online for reliable stacking strategies, tool references, and conventions. Return [online resource]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan], then reruns the file completeness verification. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for plan-only mode or a review first.

### Step 5 - PR Stack Execution
The main agent executes the PR stack creation directly, following [breakdown-pr skill] step 6:
- Confirm the working tree policy for uncommitted changes.
- Record the original source branch and intended final stack top.
- Create each branch from the base or previous stack branch.
- Move changes using the safest granularity.
- Commit each PR with the approved title and concise body.
- Submit using the stack tool only if the user approved submission; otherwise stop after local branches are prepared.

Record [execution report] containing branches created, commits made, PRs submitted, and failures, with no explanations.

### Step 6 - Stack Review and Verification
1. The main agent should claim every item in the [execution report] is wrong, and start explaining why it is wrong. After explaining all the items, the main agent should then draft a [challenge report].
2. The main agent verifies the stack directly against [final plan], [execution report], and [challenge report]: branch/commit structure, dependency order, no unrelated or auto-generated files included, all necessary files present, and the final stack top matches the original branch diff. Run [breakdown-pr skill] step 7 verification, including `git diff --exit-code` and `git range-diff` where appropriate.
3. PR re-organization authors no new logic, so only when source files were actually edited (e.g., conflict resolution) does the main agent review those edits directly.
4. If any verification fails, perform **one** remediation pass (repair the affected branches, then re-verify once); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Write to update_logs.md:
```md
{=============================PR Creation Update===============================}
{PR Title and PR number in stack (e.g., PR 1/5)}
{Request (what was requested)}
{PR description (one or two sentences of what the PR contains)}
{Branch name}
{Files changed}
{Dependencies (which PRs must land before this one)}
{Status (created / submitted / failed - and reason if failed)}
```
2. Summarize the PR stack in bullet points to chat.
