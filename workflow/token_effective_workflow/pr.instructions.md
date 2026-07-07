---
name: 'Fast PR Creation'
description: 'Unified token-effective (fast) PR-stack workflow for Claude Code, Codex, and VS Code Copilot: main-agent diff analysis with file-completeness verification, one parallel challenge + research subagent step, and direct stack execution using the breakdown-pr skill'
---
# Create Pull Requests from a Feature Branch

**Safety: follow `_lib/safety_rules.md`.**

**DO NOT COMMIT TO GITHUB WITHOUT USER APPROVAL | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

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
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
-->

[inputs]:
- input 1: target branch (optional, defaults to current branch)
- input 2: base branch (optional, defaults to repo default branch)
- input 3: mode — `plan` or `execute` (optional, defaults to `execute`)
- input 4: max lines per PR (optional, defaults to 1000)
- input 5: stack tool preference (optional, auto-detect)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `repo_info/`, resolved via Pack Path Resolution).

Also read the breakdown-pr skill at [`skills/breakdown-pr/SKILL.md`](../../skills/breakdown-pr/SKILL.md) and keep it as [breakdown-pr skill].

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.
The main agent reads [key md files] in Step 1 and condenses them (plus any target files) into a [repo context digest]; per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents, on **Claude Code** the digest is passed inline to subagents, and on **Codex** and **VS Code Copilot** subagents read [key md files] directly. The neutral phrase "the repo context (per §Context Passing)" resolves accordingly.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 — Context Gathering
Read [key md files] and [breakdown-pr skill], and condense [key md files] (plus any target files) into a [repo context digest] for handoff per §Context Passing. Inspect the target branch and its diff against the base branch. Additionally:
- Run `git diff --name-only <base>...<branch>` to produce a complete [diff file manifest] — the exhaustive list of every file touched in the diff. This manifest is the single source of truth for file inclusion.
- Read the repository's `.gitignore` file(s) (root and any nested `.gitignore` files) and record the ignored path patterns as [gitignore patterns].
- Identify auto-generated files in the diff by checking for: files matching [gitignore patterns], files in common generated directories (e.g., `node_modules/`, `dist/`, `build/`, `__pycache__/`, `.next/`, `vendor/`, `coverage/`), lockfiles (e.g., `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Pipfile.lock`, `poetry.lock`, `Cargo.lock`, `go.sum`), compiled outputs, and files with auto-generation headers. Record these as [auto-generated files].
- Produce [filtered diff manifest] = [diff file manifest] minus [auto-generated files]. Log excluded auto-generated files explicitly so the user can override if needed.

**Local Skill Discovery (before any plan drafting):** [breakdown-pr skill] is already loaded as the primary skill. Additionally perform Local Skill Discovery per `_lib/local_skill_discovery.md` for any *other* local skill relevant to this task (skip breakdown-pr during matching); fold the result [local skills] into the repo context (per §Context Passing) so the Step 3 subagents receive it, and integrate it when the main agent drafts [final plan]. If nothing else matches, record [local skills]: none relevant.

### Step 2 — PR Planning
Based on the Step 1 manifests + [breakdown-pr skill] + [inputs], the main agent analyzes the diff, identifies change types and logical groupings, and proposes a [plan] + [dependency graph] following the [breakdown-pr skill] output format. Use [filtered diff manifest] as the authoritative file list; **every file in [filtered diff manifest] must be assigned to exactly one PR**, and each PR must be buildable.

File completeness verification: after drafting [plan], rerun `git diff --name-only <base>...<branch>` and cross-reference the output against [plan]. Add missing files to the most appropriate PR; remove files matching [gitignore patterns] or [auto-generated files] unless the user explicitly requested their inclusion. Log discrepancies found and resolved.

### Step 3 — Plan Challenge and Research
**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | Receive [breakdown-pr skill] + [plan] + [dependency graph] + [inputs] + the repo context (per §Context Passing); read additional files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify PRs that would break the build, incorrect dependency ordering, mixed concerns, missing changes, stacking risks, over-engineering, and regressions. Then explain why the items are wrong, flawed, and over-engineered. Distinguish genuine defects from out-of-scope or speculative additions, and report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | Receive [breakdown-pr skill] + [plan] + [inputs] + the repo context (per §Context Passing). Search the live internet for reliable stacking strategies, tool references, and conventions (the subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof — see `agents/online-researcher.agent.md`). Return [online resource]. |

### Step 4 — Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan], then reruns the file completeness verification. Print [final plan] using the [breakdown-pr skill] output format.

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 — PR Stack Execution
The main agent executes the PR stack creation directly, following [breakdown-pr skill] step 6 (Execute Only After Approval). **Nested-skill note:** the skill's "Execute Only After Approval" / "ask before execution" wording maps to the single two-mode gate at Step 4 (`_lib/approval_gate.md` §Nested-skill approval language), not a second stop — in autonomous mode, create local branches/commits without re-asking and resolve ambiguous base/branch/stack-tool/uncommitted-change choices yourself as recorded assumptions; only the submit/push still needs explicit user approval.
- Confirm the working tree policy for uncommitted changes.
- Record the original source branch and intended final stack top.
- Create each branch from the base or previous stack branch.
- Move changes using the safest granularity (whole-file, patch mode, or cherry-pick as appropriate).
- Commit each PR with the approved title and a concise body.
- Submit using the stack tool only if the user approved submission; otherwise stop after local branches are prepared.

Record [execution report] containing branches created, commits made, PRs submitted, and failures, with no explanations.

### Step 6 — Stack Review and Verification
1. **Native review skills (platform-conditional):** PR re-organization authors no new logic, so the native skills run only when source files were actually edited (e.g., conflict resolution).
   - **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** only when source files were edited, run the native review as **two subagents, one skill each — no orchestration wrapper**, following the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) (subagents inherit [main agent model] / the `subagent_model` header; keep an activity log and record fallbacks). Run them **sequentially, not in parallel**, and invoke each skill exactly once: **(1)** **`/simplify` is opt-in — run step (1) only when the request's `simplify` header is `true`; when it is `false`, absent, or unset (the default), skip step (1) entirely and leave [simplify] unproduced.** spawn a **simplify subagent** — pass it the edited source files (the current diff) + [final plan] + [execution report] plus the relevant repo context and have it run `/simplify` to cut complexity and redundancy without changing behavior (it applies its edits to the working tree); record [simplify]. **(2)** **`/code-review` is opt-in — run step (2) only when the request's `code_review` header is `true`; when it is `false`, absent, or unset (the default), skip step (2) entirely and leave [code-review] unproduced (step (1) `/simplify` runs only when the request's `simplify` header is `true`).** *after that subagent returns*, spawn a **code-review subagent** — pass it the resulting post-simplify diff + [final plan] + [execution report] plus the relevant repo context and have it run **`/code-review medium`** (`medium` is the skill's own effort level on its `low|medium|high|max|ultra` scale — a property of the skill call, not the subagent's model), **review-only** (never `--fix` or `--comment`), for correctness bugs and reuse/simplification/efficiency cleanups; record [code-review]. The `medium` gate is the skill's own argument — a per-subagent model reasoning-effort override is not settable on an ad-hoc Task spawn. When step (2) runs, order matters: `/simplify` writes the working tree and `/code-review` reads the resulting diff. **Fallback:** if a subagent cannot invoke its slash command or fails to spawn, the main agent runs that skill directly — or reviews the diff inline if the skill itself is unavailable — and records a `[fallback result]` (`status: fallback-single-agent`). Skip when no source was edited or the native skills are unavailable.
   - **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the native skills; only when source files were edited, the main agent reviews those edits directly.
2. After the native review sub-step completes, the main agent spawns a **Devils Advocate** (`agents/devils-advocate.agent.md`) that reads [breakdown-pr skill] + [final plan] + [execution report] and reviews the stack assuming the PR stack breakdown is wrong — broken builds, incorrect dependency ordering, mixed concerns, missing or misplaced files, stacking risks — explains why each part is wrong, and returns the report as [devils-advocate review].
3. While the **Devils Advocate** is working, the main agent verifies the stack directly against [final plan] and [execution report]: branch/commit structure, dependency order, no unrelated or auto-generated files included, all necessary files present, and the final stack top matches the original branch diff. Run [breakdown-pr skill] step 7 verification, including `git diff --exit-code` and `git range-diff` where appropriate. Save the conclusion as [direct review].

Based on whichever of [simplify] + [code-review] + [devils-advocate review] + [direct review] were produced, the main agent analyzes and validates them all, and generates a [final report]. Then the main agent applies the clearly-correct, low-risk findings (do not auto-apply uncertain or behavior-changing ones), then records any remaining gaps for Step 7.

### Step 7 — Documentation and Summary
1. Write to update_logs.md (one entry per PR in the stack):
```md
{=============================PR Creation Update===============================}
{PR Title and PR number in stack (e.g., PR 1/5)}
{Request (what was requested)}
{PR description (one or two sentences of what the PR contains)}
{Branch name}
{Files changed}
{Dependencies (which PRs must land before this one)}
{Status (created / submitted / failed — and reason if failed)}
```
2. Summarize the PR stack and [final report] in bullet points to chat, and a yes/no answer indicating whether the stack was created with no issues. If there are gaps, describe them.
