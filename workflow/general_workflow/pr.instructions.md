---
name: 'PR Creation'
description: 'Instructions for breaking down and creating pull requests from feature branches using the breakdown-pr skill'
---
# create pull requests from a feature branch

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

**DO NOT TRY TO COMMIT CHANGES TO GITHUB WITHOUT USER APPROVAL**
**DO NOT WRITE SPAM FILES INTO THE REPO**
**DO NOT USE SUDO**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

[inputs]:
input 1: target branch (optional, defaults to current branch)
input 2: base branch (optional, defaults to repo default branch)
input 3: mode — `plan` or `execute` (optional, defaults to `execute`)
input 4: max lines per PR (optional, defaults to 1000)
input 5: stack tool preference (optional, auto-detect)

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

When asked to create PRs from a feature branch, always first read the following files from `repo_info/`, resolved by the Pack Path Resolution rule (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.

Also read the breakdown-pr skill at [`skills/breakdown-pr/SKILL.md`](../../skills/breakdown-pr/SKILL.md) and keep it as [breakdown-pr skill].

**Local Skill Discovery (before any plan drafting):** [breakdown-pr skill] is already loaded as the primary skill. Additionally perform Local Skill Discovery per `_lib/local_skill_discovery.md` for any *other* local skill relevant to this task (skip breakdown-pr during matching); fold the result [local skills] into the repo context (per §Context Passing) so every planning subagent receives it, and integrate it when the main agent drafts [final pr plan]. If nothing else matches, record [local skills]: none relevant.

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
then, for creating PRs from a feature branch, **CREATE ONE TODO FOR EACH STEP**:
1. if a target branch is specified, the main agent must inspect the branch and its diff against the base branch. Then combine the understood knowledge with [key md files]. Additionally, the main agent must:
   - Run `git diff --name-only <base>...<branch>` to produce a **complete [diff file manifest]** — the exhaustive list of every file touched in the diff. This manifest is the single source of truth for file inclusion.
   - Read the repository's `.gitignore` file(s) (root and any nested `.gitignore` files) to identify ignored path patterns. Record these as [gitignore patterns].
   - Identify auto-generated files in the diff by checking for: files matching [gitignore patterns], files in common generated directories (e.g., `node_modules/`, `dist/`, `build/`, `__pycache__/`, `.next/`, `vendor/`, `coverage/`), lockfiles (e.g., `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Pipfile.lock`, `poetry.lock`, `Cargo.lock`, `go.sum`), compiled outputs, and files with auto-generation headers. Record these as [auto-generated files].
   - Produce a [filtered diff manifest] = [diff file manifest] minus [auto-generated files]. If any auto-generated files are excluded, log them explicitly so the user can override if needed.
   - Pass [diff file manifest], [filtered diff manifest], [gitignore patterns], and [auto-generated files] to all subagents in subsequent steps.

2. the main agent creates three subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** (**Focus Analyst** via `agents/focus-analyst.agent.md`; **Broad Analyst** via `agents/broad-analyst.agent.md`; **Free Analyst** via `agents/free-analyst.agent.md`), pass [inputs], [breakdown-pr skill], and the repo context (per §Context Passing) to the three subagents. The three subagents must be launched in parallel. Then:

a. the **Focus Analyst** (`agents/focus-analyst.agent.md`) first processes [inputs] and the repo context (per §Context Passing), and analyzes the diff on the feature branch — what changes exist, how they relate to the existing codebase, and what logical groupings of changes can be identified. The subagent must use [filtered diff manifest] as the authoritative file list and must not include files from [auto-generated files] unless they are source-generating inputs. Then, the subagent reads through the highly associated files and scripts affected by the diff. Then, the subagent drafts a PR breakdown plan following the [breakdown-pr skill] methodology — classifying changes, building a dependency graph, and designing a stack of small reviewable PRs, while ensuring each PR leaves the repo buildable and testable. **File completeness check:** Before finalizing, the subagent must cross-reference its plan against [filtered diff manifest] and confirm every file in the manifest is assigned to exactly one PR. If any file is unaccounted for, it must be added. Then the subagent feeds the plan and the dependency graph back to the main agent as [pr plan 1] and [dependency graph 1].

b. the **Broad Analyst** (`agents/broad-analyst.agent.md`) must follow the pipeline diagram from the repo context (per §Context Passing), read through all scripts from upstream of the diagram to downstream of the diagram. Then analyze the feature branch diff — what changes exist, how they affect the pipeline, and what logical PR boundaries emerge. The subagent must use [filtered diff manifest] as the authoritative file list and must exclude files matching [gitignore patterns] or identified as auto-generated. Then, the subagent must draft a PR breakdown plan following the [breakdown-pr skill] methodology and draft a dependency graph for the stack, while ensuring each PR is independently buildable and testable. **File completeness check:** Before finalizing, the subagent must cross-reference its plan against [filtered diff manifest] and confirm every file in the manifest is assigned to exactly one PR. If any file is unaccounted for, it must be added. Then the subagent feeds the plan and the dependency graph back to the main agent as [pr plan 2] and [dependency graph 2].

c. the **Free Analyst** (`agents/free-analyst.agent.md`) must first process [inputs] and the repo context (per §Context Passing), then it must decide what files to read, what scripts to check, following its own logic. Then analyze the feature branch diff and determine the best way to split it into reviewable PRs. The subagent must use [filtered diff manifest] as the authoritative file list and must not include auto-generated files or files matching [gitignore patterns]. Then, the subagent must draft a PR breakdown plan following the [breakdown-pr skill] methodology while ensuring each PR is buildable and reviewable. **File completeness check:** Before finalizing, the subagent must cross-reference its plan against [filtered diff manifest] and confirm every file in the manifest is assigned to exactly one PR. If any file is unaccounted for, it must be added. Then the subagent feeds the plan back to the main agent as [pr plan 3].

3. the main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), pass all three plans [pr plan 1], [pr plan 2], and [pr plan 3] and the dependency graphs [dependency graph 1] and [dependency graph 2] from the other subagents, [inputs], and the repo context (per §Context Passing) to this subagent. The subagent receives the repo context (per §Context Passing) and reviews associated scripts in this repo. Then the subagent reviews all PR breakdown plans and dependency graphs from a senior staff engineer perspective, assesses the plans' correctness and feasibility — ensuring each proposed PR is independently buildable, that the dependency order is correct, that no PR contains unrelated concerns, and that the final stack top is equivalent to the original branch. The subagent rejects redundant or incorrect plans. Feed the [senior staff engineer review] back to the main agent.

4. the main agent reviews the plans, the dependency graphs from step 2, [senior staff engineer review], and reads necessary files. Finally, combine all that information and draft a [final pr plan] that follows the [breakdown-pr skill] output format, is feasible, leaves each PR buildable, and correctly covers the entire diff.

   **Mandatory file completeness verification:** After drafting [final pr plan], the main agent must run `git diff --name-only <base>...<branch>` again and cross-reference the output against the files listed in [final pr plan]. Every file in [filtered diff manifest] must appear in exactly one PR. If any file is missing, add it to the most appropriate PR. If any file in the plan matches [gitignore patterns] or is in [auto-generated files], remove it from the plan (unless the user explicitly requested its inclusion). Log any discrepancies found and resolved.

5. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, pass [final pr plan], [inputs], and the repo context (per §Context Passing) to the subagents.

a. The **Devils Advocate** receives the repo context (per §Context Passing) and reads all relevant scripts, then critically challenge [final pr plan] — looking for PRs that would break the build, incorrect dependency ordering, PRs that mix unrelated concerns, missing changes that would leave a PR incomplete, or stacking risks. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** receives the repo context (per §Context Passing), then identifies if there are better stacking strategies, tools, or conventions for the repo's stack tool. The subagent MUST actually call its platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs it fetched as proof — see `agents/online-researcher.agent.md`. The subagent reports the findings from online back to the main agent as [online resource].

5.5 The main agent incorporates [valid criticisms] and [online resource], and updates [final pr plan] accordingly.

6. Then, the main agent must print the updated [final pr plan] using the [breakdown-pr skill] output format, so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

7. the main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), pass [final pr plan], [inputs], and the repo context (per §Context Passing) to the subagent. **Implementer Model Verification:** See `_lib/workflow_contract.md` §Implementer Model Verification Fallback. The subagent (or the main agent, if falling back) receives the repo context (per §Context Passing) and [breakdown-pr skill]. Then based on [final pr plan], the subagent executes the PR stack creation following the [breakdown-pr skill] step 6 (Execute Only After Approval). **Nested-skill note:** the skill's "Execute Only After Approval" / "ask before execution" wording maps to the single two-mode gate already evaluated at step 6 above (`_lib/approval_gate.md` §Nested-skill approval language), not a second stop — in autonomous mode, create local branches/commits without re-asking and resolve ambiguous base/branch/stack-tool/uncommitted-change choices yourself as recorded assumptions; only the submit/push (final bullet) still needs explicit user approval. The execution steps:
   - Confirm the working tree policy for uncommitted changes.
   - Record the original source branch and intended final stack top.
   - Create each branch from the base or previous stack branch.
   - Move changes using the safest granularity (whole-file, patch mode, or cherry-pick as appropriate).
   - Commit each PR with the approved title and a concise body.
   - Submit using the approved stack tool (if approved by user); otherwise stop after local branches are prepared.
   After finishing the execution, the subagent must generate an [execution report] (just what has been done — branches created, commits made, PRs submitted — **no explanation**), and report [execution report] back to the main agent.

7.5. **Post-implementation review (platform-conditional):**
- **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) after step 7. (That skill runs `/simplify` automatically — do not invoke it separately.)
- **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the skill; instead, the main agent performs a manual review of all created branches for correctness and consistency before proceeding.

8. the main agent creates two subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** (**Senior Engineer** via `agents/senior-engineer.agent.md`; **QA Engineer** via `agents/qa-engineer.agent.md`). Then:
a. the main agent must pass [final pr plan], [inputs], [execution report], and the repo context (per §Context Passing) to the **Senior Engineer** subagent. The subagent receives the repo context (per §Context Passing) and verifies all created branches. Then the subagent reviews the branch/commit structure from a senior staff engineer perspective — verifying that each branch is buildable, that the dependency order is correct, that no branch contains unrelated changes, no auto generated files are included, all necessary files are present, and that the final stack top matches the original branch diff. Then the subagent must generate a [pr stack review report] and feed it back to the main agent.

b. the main agent must pass [final pr plan], [inputs], [execution report], and the repo context (per §Context Passing) to the **QA Engineer** subagent. The subagent receives the repo context (per §Context Passing) and verifies all created branches. Then the subagent validates the PR stack from a QA engineer perspective — running the [breakdown-pr skill] step 7 (Verify the Stack) to confirm that each PR branch passes its verification command and that the final stack top is equivalent to the original branch via `git diff --exit-code` and `git range-diff`. Then, the subagent must generate a [pr stack QA report] and report it back to the main agent.

9. the main agent must read through [final pr plan], [execution report], [pr stack review report], and [pr stack QA report], then understand the PR stack creation results. Then, the main agent must accordingly update update_logs.md with a summary of the PR creation activity.

10. the main agent must summarize the PR creation in the following format, for each PR in the stack:
{=============================PR Creation Update===============================}
{PR Title and PR number in stack (e.g., PR 1/5)}
{PR description (one or two sentences of what the PR contains)}
{Branch name}
{Files changed}
{Dependencies (which PRs must land before this one)}
{Status (created / submitted / failed — and reason if failed)}

11. write the PR Creation Update summary to update_logs.md. do not add additional contents, just the PR creation report from previous step. In addition, summarize the PR stack in bullet points and write them to the chat.
