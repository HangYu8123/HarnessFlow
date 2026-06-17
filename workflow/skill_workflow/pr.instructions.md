---
name: 'Skill-Based PR Creation'
description: 'Unified skill-backed (skill mode) PR-stack workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast workflow; PR planning already uses the local breakdown-pr skill, and the challenge, research, and post-execution self-challenge instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback.'
---
# Create Pull Requests from a Feature Branch

**Safety: follow `_lib/safety_rules.md`.**

**DO NOT COMMIT TO GITHUB WITHOUT USER APPROVAL | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

> **Skill-backed variant (skill mode).** PR planning is already skill-based (the local `breakdown-pr` skill). The challenge, research, and post-execution self-challenge step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - _lib/local_skill_discovery.md
  - skills/skill_workflow_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/breakdown-pr/SKILL.md
  - skills/claude-native-skills-subagents/SKILL.md
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

### Step 2 — PR Planning
*(Already skill-based — uses the local `breakdown-pr` skill; unchanged.)*
**Local Skill Discovery (before drafting [plan]):** [breakdown-pr skill] is already loaded and integrated as the primary skill. Additionally perform Local Skill Discovery per `_lib/local_skill_discovery.md` for any *other* local skill relevant to this task (skip breakdown-pr during matching); record the result as [local skills] (or "none relevant") and integrate it into [plan].

Based on the Step 1 manifests + [breakdown-pr skill] + [inputs], the main agent analyzes the diff, identifies change types and logical groupings, and proposes a [plan] + [dependency graph] following the [breakdown-pr skill] output format. Use [filtered diff manifest] as the authoritative file list; **every file in [filtered diff manifest] must be assigned to exactly one PR**, and each PR must be buildable.

File completeness verification: after drafting [plan], rerun `git diff --name-only <base>...<branch>` and cross-reference the output against [plan]. Add missing files to the most appropriate PR; remove files matching [gitignore patterns] or [auto-generated files] unless the user explicitly requested their inclusion. Log discrepancies found and resolved.

### Step 3 — Plan Challenge and Research
**[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | **Skill-backed:** run the challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`, 9,938★ verified 2026-06-16) — a structured devil's-advocate / pre-mortem over [breakdown-pr skill] + [plan] + [dependency graph] + [inputs] + the repo context (per §Context Passing), reading additional files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify PRs that would break the build, incorrect dependency ordering, mixed concerns, missing changes, stacking risks, over-engineering, and regressions; report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate task as written in the fast workflow. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | **Skill-backed:** draft [online resource] by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`, 28,103★ verified 2026-06-16) — plan/search/read/synthesize a **cited report** of reliable stacking strategies, tool references, and conventions for [breakdown-pr skill] + [plan] + [inputs] + the repo context (per §Context Passing). The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof (see `agents/online-researcher.agent.md`). **Fallback if `deep-research` is unavailable:** perform the Online Researcher task as written in the fast workflow. |

### Step 4 — Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan], then reruns the file completeness verification. Print [final plan] using the [breakdown-pr skill] output format.

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for plan-only mode or a review first.

### Step 5 — PR Stack Execution
The main agent executes the PR stack creation directly, following [breakdown-pr skill] step 6 (Execute Only After Approval):
- Confirm the working tree policy for uncommitted changes.
- Record the original source branch and intended final stack top.
- Create each branch from the base or previous stack branch.
- Move changes using the safest granularity (whole-file, patch mode, or cherry-pick as appropriate).
- Commit each PR with the approved title and a concise body.
- Submit using the stack tool only if the user approved submission; otherwise stop after local branches are prepared.

Record [execution report] containing branches created, commits made, PRs submitted, and failures, with no explanations.

### Step 6 — Stack Review and Verification
1. **Native review skills (platform-conditional):** PR re-organization authors no new logic, so the native skills run only when source files were actually edited (e.g., conflict resolution).
   - **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** only when source files were edited, run the native review skills via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md): `/simplify` first on the resulting diff, record results as [simplify]; then `/code-review` on the resulting diff, record as [code-review]. Skip when no source was edited or the native skills are unavailable.
   - **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the native skills; only when source files were edited, the main agent reviews those edits directly.
2. **Skill-backed self-challenge:** run **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) over the [execution report] — claim every item is wrong, explain why, then draft a [post-impl challenge report]. **Fallback if unavailable:** the main agent performs this self-challenge inline.
3. The main agent verifies the stack directly against [final plan] and [execution report]: branch/commit structure, dependency order, no unrelated or auto-generated files included, all necessary files present, and the final stack top matches the original branch diff. Run [breakdown-pr skill] step 7 verification, including `git diff --exit-code` and `git range-diff` where appropriate. Save the conclusion as [direct review].
4. Based on whichever of [simplify] + [code-review] + [post-impl challenge report] + [direct review] were produced, if any verification fails, perform **one** remediation pass (repair the affected branches, then re-verify once); record any remaining gaps for Step 7.

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
2. Summarize the PR stack in bullet points to chat.
