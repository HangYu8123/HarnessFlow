---
name: 'PR Creation'
description: 'Instructions for breaking down and creating pull requests from feature branches using the breakdown-pr skill'
---
# Create Pull Requests from a Feature Branch

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/breakdown-pr/SKILL.md
-->

**Safety: follow `_lib/safety_rules.md`.**

**DO NOT COMMIT TO GITHUB WITHOUT USER APPROVAL | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

[inputs]:
- input 1: target branch (optional, defaults to current branch)
- input 2: base branch (optional, defaults to repo default branch)
- input 3: mode — `plan` or `execute` (optional, defaults to `execute`)
- input 4: max lines per PR (optional, defaults to 1000)
- input 5: stack tool preference (optional, auto-detect)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved by the Pack Path Resolution rule). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering and Local Skill Discovery
Read [key md files]. Understand them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, create a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes — and pass it, plus the excerpts of [full repo context] each subagent's task needs, inline to every subagent.

Also read the breakdown-pr skill at [`skills/breakdown-pr/SKILL.md`](../../skills/breakdown-pr/SKILL.md) and keep it as [breakdown-pr skill].

**Local Skill Discovery (before any plan drafting):** [breakdown-pr skill] is already loaded as the primary skill. Additionally perform Local Skill Discovery per `_lib/local_skill_discovery.md` for any *other* local skill relevant to this task (skip breakdown-pr during matching); fold the result [local skills] into the repo context (per §Context Passing) so every planning subagent receives it, and integrate it when the main agent drafts [final pr plan]. If nothing else matches, record [local skills]: none relevant.

### Step 2 - Diff Manifest
If a target branch is specified, the main agent must inspect the branch and its diff against the base branch. Then combine the understood knowledge with [key md files]. Additionally, the main agent must:
- Run `git diff --name-only <base>...<branch>` to produce a **complete [diff file manifest]** — the exhaustive list of every file touched in the diff. This manifest is the single source of truth for file inclusion.
- Read the repository's `.gitignore` file(s) (root and any nested `.gitignore` files) to identify ignored path patterns. Record these as [gitignore patterns].
- Identify auto-generated files in the diff by checking for: files matching [gitignore patterns], files in common generated directories (e.g., `node_modules/`, `dist/`, `build/`, `__pycache__/`, `.next/`, `vendor/`, `coverage/`), lockfiles (e.g., `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Pipfile.lock`, `poetry.lock`, `Cargo.lock`, `go.sum`), compiled outputs, and files with auto-generation headers. Record these as [auto-generated files].
- Produce a [filtered diff manifest] = [diff file manifest] minus [auto-generated files]. If any auto-generated files are excluded, log them explicitly so the user can override if needed.
- Pass [diff file manifest], [filtered diff manifest], [gitignore patterns], and [auto-generated files] to all subagents in subsequent steps.

### Step 3 - PR Breakdown Panel
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [inputs], [breakdown-pr skill], and the repo context (per §Context Passing) to all three subagents. Every subagent must use [filtered diff manifest] as the authoritative file list, must not include files from [auto-generated files] or matching [gitignore patterns] (unless they are source-generating inputs), and must run a **file completeness check** before finalizing: cross-reference its plan against [filtered diff manifest] and confirm every file in the manifest is assigned to exactly one PR; if any file is unaccounted for, add it.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Focus breakdown | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Always | Process [inputs] and the repo context (per §Context Passing), and analyze the diff on the feature branch — what changes exist, how they relate to the existing codebase, and what logical groupings of changes can be identified. Read through the highly associated files and scripts affected by the diff. Draft a PR breakdown plan following the [breakdown-pr skill] methodology — classifying changes, building a dependency graph, and designing a stack of small reviewable PRs, while ensuring each PR leaves the repo buildable and testable. Return [pr plan 1] and [dependency graph 1]. |
| Broad breakdown | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Always | Follow the pipeline diagram from the repo context (per §Context Passing), read through all scripts from upstream of the diagram to downstream. Analyze the feature branch diff — what changes exist, how they affect the pipeline, and what logical PR boundaries emerge. Draft a PR breakdown plan following the [breakdown-pr skill] methodology and draft a dependency graph for the stack, while ensuring each PR is independently buildable and testable. Return [pr plan 2] and [dependency graph 2]. |
| Free breakdown | **Free Analyst** (`agents/free-analyst.agent.md`) | Always | Process [inputs] and the repo context (per §Context Passing), then decide what files to read and what scripts to check, following its own logic. Analyze the feature branch diff and determine the best way to split it into reviewable PRs. Draft a PR breakdown plan following the [breakdown-pr skill] methodology while ensuring each PR is buildable and reviewable. Return [pr plan 3]. |

### Step 4 - Senior Engineer Plan Review
The main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), passing all three plans [pr plan 1], [pr plan 2], and [pr plan 3], the dependency graphs [dependency graph 1] and [dependency graph 2], [inputs], and the repo context (per §Context Passing). The subagent reviews associated scripts in this repo. Then the subagent reviews all PR breakdown plans and dependency graphs from a senior staff engineer perspective, assesses the plans' correctness and feasibility — ensuring each proposed PR is independently buildable, that the dependency order is correct, that no PR contains unrelated concerns, and that the final stack top is equivalent to the original branch. The subagent rejects redundant or incorrect plans. Feed the [senior staff engineer review] back to the main agent.

### Step 5 - Draft the Final PR Plan
The main agent reviews the plans, the dependency graphs from Step 3, [senior staff engineer review], and reads necessary files. Finally, combine all that information and draft a [final pr plan] that follows the [breakdown-pr skill] output format, is feasible, leaves each PR buildable, and correctly covers the entire diff.

**Mandatory file completeness verification:** After drafting [final pr plan], the main agent must run `git diff --name-only <base>...<branch>` again and cross-reference the output against the files listed in [final pr plan]. Every file in [filtered diff manifest] must appear in exactly one PR. If any file is missing, add it to the most appropriate PR. If any file in the plan matches [gitignore patterns] or is in [auto-generated files], remove it from the plan (unless the user explicitly requested its inclusion). Log any discrepancies found and resolved.

### Step 6 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final pr plan], [inputs], and the repo context (per §Context Passing) to all three subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | Read all relevant scripts, then critically challenge [final pr plan] — looking for PRs that would break the build, incorrect dependency ordering, PRs that mix unrelated concerns, missing changes that would leave a PR incomplete, or stacking risks. Return flaws as [valid criticisms]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | Identify whether there are better stacking strategies, tools, or conventions for the repo's stack tool. MUST actually call the platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs fetched as proof — see `agents/online-researcher.agent.md`. Return [online resource]. |
| Diversify | **Diversifier** (`agents/diversifier.agent.md`) | `diversifier: on` · default `on` | Process [inputs], [final pr plan], and the repo context (per §Context Passing). Then propose 5 alternative breakdown plans that each ship the same change set — including one **risky**, one **aggressive**, and one **rare** — each structurally different from [final pr plan] and from each other (different split boundaries, stacking order, or dependency shape), each carrying a calibrated `P(better)` that it beats [final pr plan]. Return [diverse plans]. |

### Step 7 - Incorporate Criticisms
The main agent incorporates [valid criticisms] and [online resource], and updates [final pr plan] accordingly. When [diverse plans] was produced, it weighs them: where an alternative's `P(better)` and evidence show it beats [final pr plan], adopt it — or graft in the part of it that wins — and restate [final pr plan] on that basis; otherwise keep [final pr plan] and record in one line why the alternatives were not taken.

### Step 8 - Print Plan and Approval Gate
The main agent prints the updated [final pr plan] using the [breakdown-pr skill] output format, so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

### Step 9 - Execute the PR Stack
The main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), passing [final pr plan], [inputs], and the repo context (per §Context Passing). **Implementer Model Verification:** See `_lib/implementer_fallback.md`. The subagent (or the main agent, if falling back) receives the repo context (per §Context Passing) and [breakdown-pr skill]. Then based on [final pr plan], the subagent executes the PR stack creation following the [breakdown-pr skill] step 6 (Execute Only After Approval). **Nested-skill note:** the skill's "Execute Only After Approval" / "ask before execution" wording maps to the single two-mode gate already evaluated at Step 8 above (`_lib/approval_gate.md` §Nested-skill approval language), not a second stop — in autonomous mode, create local branches/commits without re-asking and resolve ambiguous base/branch/stack-tool/uncommitted-change choices yourself as recorded assumptions; only the submit/push (final bullet) still needs explicit user approval. The execution steps:
- Confirm the working tree policy for uncommitted changes.
- Record the original source branch and intended final stack top.
- Create each branch from the base or previous stack branch.
- Move changes using the safest granularity (whole-file, patch mode, or cherry-pick as appropriate).
- Commit each PR with the approved title and a concise body.
- Submit using the approved stack tool (if approved by user); otherwise stop after local branches are prepared.

After finishing the execution, the subagent must generate an [execution report] (just what has been done — branches created, commits made, PRs submitted — **no explanation**), and report [execution report] back to the main agent.

### Step 10 - Post-Implementation Review (platform-conditional)
- **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely.
- **When a header is `true` and the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — it is the only caller of the native `/simplify` and `/code-review`; do not invoke either separately. (`/code-review` additionally requires that the implementation changed code files.)
- **When a header is `local` (any platform, no Claude Code dependency):** skip that wrapper skill and spawn the local-skill subagent directly per [`_lib/review_skills.md`](../../_lib/review_skills.md) — `skills/code-simplification/SKILL.md` for `simplify`, `skills/code-review-and-quality/SKILL.md` for `code_review`.
- **Otherwise (`true` on Codex, or VS Code Copilot without Claude Code skills):** the native skills do not exist — skip them; instead, the main agent performs a manual review of all created branches for correctness and consistency before proceeding.
- **Parallel launch (speed-for-accuracy trade):** launch **every** review subagent this step spawns — the native wrapper's, or the `local` ones — **in parallel, including simplify** (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback). Simplify writes the working tree while the reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before applying anything. Degrade to sequential (simplify first) only if parallel launch is unavailable.

### Step 11 - Stack Review and QA
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Pass [final pr plan], [inputs], [execution report], and the repo context (per §Context Passing) to both subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Stack review | **Senior Engineer** (`agents/senior-engineer.agent.md`) | Always | Verify all created branches. Review the branch/commit structure from a senior staff engineer perspective — verifying that each branch is buildable, that the dependency order is correct, that no branch contains unrelated changes, no auto-generated files are included, all necessary files are present, and that the final stack top matches the original branch diff. Return [pr stack review report]. |
| Stack QA | **QA Engineer** (`agents/qa-engineer.agent.md`) | Always | Verify all created branches. Validate the PR stack from a QA engineer perspective — running the [breakdown-pr skill] step 7 (Verify the Stack) to confirm that each PR branch passes its verification command and that the final stack top is equivalent to the original branch via `git diff --exit-code` and `git range-diff`. Return [pr stack QA report]. |

### Step 12 - Summarize the PR Creation
The main agent reads through [final pr plan], [execution report], [pr stack review report], and [pr stack QA report], then understands the PR stack creation results. The main agent summarizes the PR creation in the following format, for each PR in the stack:
```md
{=============================PR Creation Update===============================}
{PR Title, Timestamp (current time, YYYY-MM-DD HH:MM), and PR number in stack (e.g., PR 1/5)}
{PR description (one or two sentences of what the PR contains)}
{Branch name}
{Files changed}
{Dependencies (which PRs must land before this one)}
{Status (created / submitted / failed — and reason if failed)}
```

### Step 13 - Write Logs and Chat Summary
Write the PR Creation Update summary to update_logs.md per `_lib/doc_logging.md` (timestamps, IDs, two-file rule). Do not add additional contents, just the PR creation report from Step 12. In addition, summarize the PR stack in bullet points and write them to the chat.
