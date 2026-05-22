---
name: 'Fast PR Creation'
description: 'Streamlined instructions for breaking down and creating pull requests from feature branches using the breakdown-pr skill'
---
# Create Pull Requests from a Feature Branch

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
  - skills/breakdown-pr/SKILL.md
-->

**DO NOT COMMIT TO GITHUB WITHOUT USER APPROVAL | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

[inputs]:
- input 1: target branch (optional, defaults to current branch)
- input 2: base branch (optional, defaults to repo default branch)
- input 3: mode — `plan` or `execute` (optional, defaults to `execute`)
- input 4: max lines per PR (optional, defaults to 1000)
- input 5: stack tool preference (optional, auto-detect)

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

Also read the breakdown-pr skill at #file:../../skills/breakdown-pr/SKILL.md and keep it as [breakdown-pr skill].

---

## CREATE ONE TODO PER STEP

### Step 1 — Context Gathering
If a target branch is specified in [inputs], inspect the branch and its diff against the base branch. Combine with [key md files] understanding. Additionally, the main agent must:
- Run `git diff --name-only <base>...<branch>` to produce a **complete [diff file manifest]** — the exhaustive list of every file touched in the diff. This manifest is the single source of truth for file inclusion.
- Read the repository's `.gitignore` file(s) (root and any nested `.gitignore` files) to identify ignored path patterns. Record these as [gitignore patterns].
- Identify auto-generated files in the diff by checking for: files matching [gitignore patterns], files in common generated directories (e.g., `node_modules/`, `dist/`, `build/`, `__pycache__/`, `.next/`, `vendor/`, `coverage/`), lockfiles (e.g., `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Pipfile.lock`, `poetry.lock`, `Cargo.lock`, `go.sum`), compiled outputs, and files with auto-generation headers. Record these as [auto-generated files].
- Produce a [filtered diff manifest] = [diff file manifest] minus [auto-generated files]. If any auto-generated files are excluded, log them explicitly so the user can override if needed.
- Pass [diff file manifest], [filtered diff manifest], [gitignore patterns], and [auto-generated files] to all subagents in subsequent steps.

### Step 2 — Parallel Planning & Review
**[PARALLEL EXECUTION — launch ALL FIVE subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Focus mode | Read [key md files] + [breakdown-pr skill]. Analyze the diff — identify change types, associated files, and logical groupings. Use [filtered diff manifest] as the authoritative file list; exclude files in [auto-generated files]. Draft [pr plan 1] + [dependency graph 1] following the breakdown-pr methodology, ensuring each PR is buildable and testable. **File completeness check:** cross-reference plan against [filtered diff manifest] — every file must be assigned to exactly one PR. |
| Plan B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Broad mode | Read [key md files] + [breakdown-pr skill]. Follow pipeline upstream→downstream, read all scripts. Analyze how changes affect the pipeline. Use [filtered diff manifest] as the authoritative file list; exclude files matching [gitignore patterns] or auto-generated. Draft [pr plan 2] + [dependency graph 2] with independently buildable PRs. **File completeness check:** cross-reference plan against [filtered diff manifest] — every file must be assigned to exactly one PR. |
| Plan C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [key md files] + [breakdown-pr skill]. Decide own reading strategy. Analyze diff and determine best PR split. Use [filtered diff manifest] as the authoritative file list; exclude auto-generated files. Draft [pr plan 3] with buildable, reviewable PRs. **File completeness check:** cross-reference plan against [filtered diff manifest] — every file must be assigned to exactly one PR. |
| Advocate | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Critical challenger | Read [key md files] + relevant scripts. Identify PRs that would break the build, incorrect dependency ordering, mixed concerns, missing changes, or stacking risks. Return [challenge report]. |
| Resource | **Online Researcher** (`agents/online-researcher.agent.md`) | Resource lookup | Read [key md files]. Identify better stacking strategies, tools, or conventions. Search online for reliable solutions. Return [online resource]. |

### Step 3 — Synthesize Final PR Plan
Main agent reviews [pr plan 1], [pr plan 2], [pr plan 3], [dependency graph 1], [dependency graph 2], [challenge report], and [online resource], and reads necessary files. Reject incorrect/redundant parts. Incorporate valid criticisms from [challenge report] and relevant findings from [online resource]. Draft [final pr plan] following the [breakdown-pr skill] output format — feasible, each PR buildable, correctly covering the entire diff.

**Mandatory file completeness verification:** After drafting [final pr plan], the main agent must run `git diff --name-only <base>...<branch>` again and cross-reference the output against the files listed in [final pr plan]. Every file in [filtered diff manifest] must appear in exactly one PR. If any file is missing, add it to the most appropriate PR. If any file in the plan matches [gitignore patterns] or is in [auto-generated files], remove it from the plan (unless the user explicitly requested its inclusion). Log any discrepancies found and resolved.

**If mode is `plan` (default) → STOP here and print [final pr plan] for user approval.**

### Step 4 — Parallel Execution
Based on the [final pr plan], the main agent creates an **Implementer** subagent (`agents/implementer.agent.md`).
**Implementer Model Verification (see `_lib/workflow_contract.md`):** Before the subagent begins any work, the main agent must confirm the subagent's model matches [main agent model]. If the model does not match, stop that subagent and re-create it (retry up to 3 times). If after 3 retries the subagent still cannot use [main agent model], the main agent must abandon that subagent and perform the execution directly itself, recording a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`.
The subagent (or the main agent, if falling back) must read [key md files] and [breakdown-pr skill]. Then execute the PR stack creation following the [breakdown-pr skill] step 6:
- Confirm the working tree policy for uncommitted changes.
- Record the original source branch and intended final stack top.
- Create each branch from the base or previous stack branch.
- Move changes using the safest granularity (whole-file, patch mode, or cherry-pick as appropriate).
- Commit each PR with the approved title and a concise body.
- Submit using the approved stack tool (if approved by user); otherwise stop after local branches are prepared.
Return [execution report] (branches created, commits made, PRs submitted — no explanations).

### Step 4.5 — Claude Native Skills
If and only if the main agent is Claude Code or another Claude agent with Claude Code skills available, search .github/harness_coding_instructions/skills/index.md for `claude-native-skills-subagents`, then use the skill at .github/harness_coding_instructions/skills/claude-native-skills-subagents/SKILL.md after step 4. If the main agent is not a Claude agent, skip step 4.5 and continue to step 5.

### Step 5 — Parallel Validation
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Review A | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Senior staff engineer | Read [key md files] + verify created branches. Review branch/commit structure — verify each branch is buildable, dependency order is correct, no unrelated changes, no auto generated files are included, all necessary files are present, and that the final stack top matches the original branch diff. Return [pr stack review report]. |
| Review B | **QA Engineer** (`agents/qa-engineer.agent.md`) | QA engineer | Read [key md files] + verify created branches. Run [breakdown-pr skill] step 7 verification — `git diff --exit-code` and `git range-diff` to confirm stack equivalence. Return [pr stack QA report]. |

### Step 6 — Documentation & Summary
1. Update update_logs.md with PR creation activity summary.
2. Write to update_logs.md:
```
{=============================PR Creation Update===============================}
{PR Title and PR number in stack (e.g., PR 1/5)}
{PR description (one or two sentences of what the PR contains)}
{Branch name}
{Files changed}
{Dependencies (which PRs must land before this one)}
{Status (created / submitted / failed — and reason if failed)}
```
3. Summarize the PR stack in bullet points to chat.
