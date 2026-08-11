---
name: 'Skill-Based Refactor'
description: 'Unified skill-backed (skill mode) refactor workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast workflow, but the planning, challenge, research, and implementation instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback.'
---
# Refactor an Existing Repo

**Safety: follow `_lib/safety_rules.md`.**

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

> **Skill-backed variant (skill mode).** Selected step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue — never block on a missing external skill. Verified star counts and verification dates live **only** in that registry (single source — re-verify there); do not restate them in this file.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - _lib/subagent_effectiveness.md
  - skills/skill_workflow_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - skills/index.md
  - skills/claude-native-skills-subagents/SKILL.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - agents/diversifier.agent.md
-->

[inputs]:
- input 1: target refactor functionalities/repository/scripts
- input 2: target files (optional)
- input 3: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under repo_info/). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading [key md files] or performing task-specific work.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If target files are specified in [inputs], read them. Everything read in this step — [key md files] plus any additional files read — is **[full repo context]**; keep it in your own context for the rest of the run. Condense [key md files] (plus any target files read) into a [repo context digest] per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: pass [inputs], [repo context digest], and the excerpts of [full repo context] each subagent's task needs.

### Step 2 - Refactor Analysis
**Skill (replaces this step's instructions):** Produce the refactor [plan] by following **`writing-plans`** (`obra/superpowers:skills/writing-plans/SKILL.md`) — feed it the repo context (per §Context Passing) + [inputs]; it returns dependency-ordered, bite-sized tasks naming the exact files to touch and a verification step per task. Alongside [plan], record a [comparison] (before/after) and behavior-preservation notes.
**Fallback if the skill is unavailable:** read the relevant files and propose a [plan] for the target refactors + a [comparison] (before/after) + behavior-preservation notes, as in the fast workflow.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | `devils_advocate: on` · default `off` | **Skill-backed:** run the challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) — a structured devil's-advocate / pre-mortem over the repo context (per §Context Passing) + [plan] + [comparison] + [inputs], reading additional files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify overlooked side effects, integration risks, incorrect assumptions, over-engineering, and regressions; report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate task as written in the fast workflow. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | `online_research: on` · default `on` | **Skill-backed:** draft [online resource] by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`) — plan/search/read/synthesize a **cited report** of reliable references, established refactoring/migration solutions, and available resources for [plan] + [comparison] + [inputs]. The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof (see `agents/online-researcher.agent.md`). **Fallback if `deep-research` is unavailable:** perform the Online Researcher task as written in the fast workflow. |
| Diversify | **Diversifier** (`agents/diversifier.agent.md`) | `diversifier: on` · default `on` | **No skill binding** — no vetted ≥1000★ skill covers plan diversification, so run the Diversifier agent definition directly: Receive the repo context (per §Context Passing) + [plan] + [comparison] + [inputs], and read additional files if needed. Propose 3–5 alternative refactor plans that each achieve the refactor targets — searching the **risky**, **aggressive**, and **rare** archetypes and reporting any archetype with no viable candidate rather than filling it — each structurally different from [plan] and from each other, each carrying a calibrated `P(better)` that it beats [plan] and a `graftable:` component. Return [diverse plans]. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]; when [diverse plans] was produced, it adopts any alternative from them whose `P(better)` and evidence beat the current plan (otherwise keeping it, with a one-line note why), then sweeps the rejected alternatives' `graftable:` fields and merges any component that improves the plan on its own. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no code/file changes or a plan-only review.

### Step 5 - Implementation
**Skill (replaces this step's instructions):** Implement [final plan] by following **`executing-plans`** (`obra/superpowers:skills/executing-plans/SKILL.md`) — reinforced by **`test-driven-development`** (`obra/superpowers:skills/test-driven-development/SKILL.md`) to keep behavior green across the refactor (tests pass before and after). Record an [implementation report] containing changes only, with no explanations.
**Fallback if the skills are unavailable:** the main agent implements [final plan] and records an [implementation report] (changes only, no explanations).

### Step 6 - Code Review and Validation

**[PARALLEL EXECUTION — launch the review-skill subagents and the `the-fool` self-challenge in one batch; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** Issue every enabled subagent invocation below before waiting on any result, and perform the main agent's own direct review while they run. **Speed-for-accuracy trade:** simplify writes the working tree while the other reviewers read it, so reconcile their findings per [`_lib/review_skills.md`](../../_lib/review_skills.md) §Parallel-review caveats before the remediation pass. Degrade to sequential (simplify first) only if parallel launch is unavailable.
1. The main agent first reviews the changes, save the conclusion as [direct review].
2. **Review skills** (`true` = Claude Code native · `local` = the pack's local skills; see [`_lib/review_skills.md`](../../_lib/review_skills.md)):
   - **Review skills (opt-in; both headers default to `false`):** resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely. When a header is **`true`** and the main agent is Claude Code (or another Claude agent with Claude Code skills available), run the native review **once** via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — that skill is the only caller of `/simplify` and `/code-review`; do not run either yourself in addition to it. When a header is **`local`**, skip that wrapper and spawn the local-skill subagent directly (`skills/code-simplification/SKILL.md`, resp. `skills/code-review-and-quality/SKILL.md`) — this works on every platform. Record [simplify] and/or [code-review] for whichever ran. If a `true` header's native skill is unavailable, skip it.
3. **Skill-backed self-challenge:** run **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) over the [implementation report] — claim every item is wrong, explain why, then draft a [post-impl challenge report]. **Fallback if unavailable:** the main agent performs this self-challenge inline.

Based on whichever of [simplify] + [code-review] + [post-impl challenge report] + [direct review] were produced, perform **one** remediation pass (fix, then re-validate once); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. Update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md per `_lib/doc_logging.md` (timestamps, IDs, two-file rule):
```md
{=============================Refactor Update===============================}
{Refactor Summary + Timestamp (current time, YYYY-MM-DD HH:MM) + ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
{Implementation (what was changed)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize changes in bullet points to chat.

### Step 8 - Subagent Effectiveness Record
Record [subagent effectiveness] per [`_lib/subagent_effectiveness.md`](../../_lib/subagent_effectiveness.md): for each opt-in helper this workflow actually ran — Devils Advocate, Diversifier, Online Researcher, `simplify`, `code_review` — write one line carrying the dials it ran under (`[model · effort]`, from the launch resolution), its adoption count (`adopted n/m` plus what the accepted items changed), its novelty and importance tokens, and a `useful` / `partly useful` / `not useful` verdict — record effect, never what the helper did — then append the entry to `repo_info/subagent_effectiveness.md`.
