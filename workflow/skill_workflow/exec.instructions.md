---
name: 'Skill-Based Exec'
description: 'Unified skill-backed (skill mode) Cmd/Skill execution workflow for Claude Code, Codex, and VS Code Copilot: same steps as the fast workflow, but the challenge, research, and post-execution self-challenge instructions are replaced by confirmed ≥1000-star community skills, each with an inline fallback.'
---
# Execute Cmds/Skills in a Repo

**Safety: follow `_lib/safety_rules.md`.**

**Stay active: follow `_lib/stay_active.md`.** The main agent never stands by while a command or subagent is in flight, and any unavoidable wait must arm **two wake triggers through two different mechanisms** before it begins.

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

> **Skill-backed variant (skill mode).** The challenge, research, and post-execution self-challenge step *instructions* below are replaced by a confirmed ≥1000-star community skill, cited as `owner/repo:path` (resolve it from that GitHub repo or install it — **not** via Pack Path Resolution; see [`skills/skill_workflow_skills.md`](../../skills/skill_workflow_skills.md)). The execution-planning and execution steps have no qualifying skill (command execution is not a code-implementation plan) and are unchanged. Every replaced step keeps an inline **fallback**; if the skill is not installed, perform the fallback and continue. Verified star counts and verification dates live **only** in that registry (single source — re-verify there); do not restate them in this file.

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/stay_active.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - _lib/review_skills.md
  - _lib/local_skill_discovery.md
  - skills/skill_workflow_skills.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
  - agents/devils-advocate.agent.md
  - agents/online-researcher.agent.md
  - skills/claude-native-skills-subagents/SKILL.md
  - skills/index.md
-->

[inputs]:
- input 1: target cmds/skills to execute
- input 2: important files (optional)
- input 3: target repo (optional)

[key md files]: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md (under `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/repo_info/`, resolved via Pack Path Resolution). In multi-layer repos, also read the `codebase_overview.md` + `scripts_overview.md` of each discovered layer per `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos.

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md). After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Context Gathering
Read [key md files]. If important files are specified in [inputs], read them. Then, per [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, condense the understanding into a **[repo context digest]** (a concise bullet-point summary covering codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues) to pass inline to subagents; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.

### Step 2 - Execution Planning
*(Unchanged — no qualifying skill fits command/skill-execution planning.)*
**Local Skill Discovery (before drafting [plan]):** When the target involves a named skill, or the task could be accomplished or aided by a local skill, perform Local Skill Discovery per `_lib/local_skill_discovery.md` (scan `skills/index.md`; on a confirmed match, read its `SKILL.md`), recorded as [local skills]. Skip when the target is plainly shell commands with no relevant skill ([local skills]: none relevant).

Based on the repo context (per §Context Passing) + [inputs] + [local skills], the main agent reads the relevant files and proposes a [plan] covering exact commands/skills to run, preconditions, expected outputs, validation criteria, failure modes, and rollback strategy.

### Step 3 - Plan Challenge and Research
**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`/Users/hangyu/UMI_2026/agentic_training_loop/.github/HarnessFlow/_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | When to spawn | Task |
|----------|-------|---------------|------|
| Challenge | **Devils Advocate** (`agents/devils-advocate.agent.md`) | Always | **Skill-backed:** run the challenge by following **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) — a structured devil's-advocate / pre-mortem over the repo context (per §Context Passing) + [plan] + [inputs], reading relevant scripts/files if needed. Assume every step in the [plan] is wrong, flawed, and over-engineered; identify wrong flags, destructive or irreversible side effects, missing prerequisites, environment assumptions, over-engineering, and regressions; report only evidence-backed criticisms (do not manufacture problems). Return [challenge report]. **Fallback if `the-fool` is unavailable:** perform the Devil's Advocate task as written in the fast workflow. |
| Research | **Online Researcher** (`agents/online-researcher.agent.md`) | Always | **Skill-backed:** draft [online resource] by running **`deep-research`** (`davila7/claude-code-templates:cli-tool/components/skills/ai-research/deep-research/SKILL.md`) — plan/search/read/synthesize a **cited report** of reliable command/skill references, known issues, and version compatibility for [plan] + [inputs]. The subagent MUST call its platform's live web search/fetch tool(s) and return source URLs as proof (see `agents/online-researcher.agent.md`). **Fallback if `deep-research` is unavailable:** perform the Online Researcher task as written in the fast workflow. |

### Step 4 - Refine and Approval Gate
The main agent incorporates [challenge report] and [online resource] (when produced) into a [final plan]. Print [final plan].

**Approval gate (opt-in):** see `_lib/approval_gate.md` — proceed directly to Step 5 unless the user asked for no changes or a plan-only review.

### Step 5 - Execution
*(Unchanged — command/skill execution with captured output, not a code-implementation plan.)*
The main agent validates preconditions (environment, dependencies, required files), executes the commands or skills per [final plan] directly, and captures stdout, stderr, exit codes, and pass/fail state into [execution report] with no explanations.

**Stay active through execution (`_lib/stay_active.md`).** The main agent stays engaged from the first command to the last: it does not end its turn, idle, or hand back to the user while a command is still running, and it never asks the user to report when something finishes. Any command that blocks on a background process, a long build, or an external event must be **bounded** and must have **two wake triggers armed through two different mechanisms before the wait begins** — one event-driven (completion notification / condition watch) and one time-driven fallback (bounded timer or bounded polling re-check). Whichever fires first, re-verify the real state (exit code, output, files) rather than trusting the trigger. If the bounded fallback expires, record it as a hard blocker and escalate — never wait indefinitely. Record each wait (what was awaited, both triggers, which fired, duration) in [execution report].

### Step 6 - Review and Validation
1. **Review skills** (`true` = Claude Code native · `local` = vendored pack skills; see [`_lib/review_skills.md`](../../_lib/review_skills.md)):
   - **Review skills (opt-in; both headers default to `false`):** only when the execution edited source files, resolve the request's `simplify` and `code_review` headers per [`_lib/review_skills.md`](../../_lib/review_skills.md). `false` skips that skill entirely. When a header is **`true`** and the main agent is Claude Code (or another Claude agent with Claude Code skills available), run the native review **once** via [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) — that skill is the only caller of `/simplify` and `/code-review`; do not run either yourself in addition to it. When a header is **`local`**, skip that wrapper and spawn the vendored-skill subagent directly (`skills/code-simplification/SKILL.md`, resp. `skills/code-review-and-quality/SKILL.md`) — this works on every platform. Record [simplify] and/or [code-review] for whichever ran. If a `true` header's native skill is unavailable, skip it. Skip the whole sub-step when the execution only ran commands without editing source; in that case the main agent still reviews any edited source directly.
2. **Skill-backed self-challenge:** run **`the-fool`** (`Jeffallan/claude-skills:skills/the-fool/SKILL.md`) over the [execution report] — claim every item is wrong, explain why, then draft a [post-impl challenge report]. **Fallback if unavailable:** the main agent performs this self-challenge inline.
3. The main agent validates [execution report] against [final plan]: outputs match expectations, side effects and state changes are intended, and modified files are inspected when applicable. Save the conclusion as [direct review].
4. Based on whichever of [simplify] + [code-review] + [post-impl challenge report] + [direct review] were produced, if any validation fails, perform **one** remediation pass (revise [final plan] and re-execute once, only when another attempt is safe); record any remaining gaps for Step 7.

### Step 7 - Documentation and Summary
1. If execution changed repo state, update codebase_overview.md and scripts_overview.md based on actual changes.
2. Write to update_logs.md:
```md
{=============================Execution Update===============================}
{Cmd/Skill Name + Timestamp (current time, YYYY-MM-DD HH:MM) + Execution ID (last ID + 1)}
{Description (1-2 sentences)}
{Repos involved}
{Request (what was requested)}
{Commands/Skills executed (what was run and parameters)}
{Result (success/failure, key outputs, side effects)}
{Achieved (yes/no, gaps if any)}
```
3. Summarize execution results in bullet points to chat.
