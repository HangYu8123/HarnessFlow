# Workflow Contract

The shared rules for all workflows, agents, and subagents in HarnessFlow. This is the **always-loaded core**; rarely-needed sections live in trigger-gated `_lib/` files that each section below names — read those only when their trigger fires (progressive disclosure).

---

## Universal Safety Rules (Always Apply)

These rules apply to **every** workflow, agent, and subagent — no exceptions.

1. **DO NOT TRY TO COMMIT CHANGES TO GITHUB**
2. **DO NOT WRITE SPAM FILES INTO THE REPO**
3. **DO NOT USE SUDO**

---

## Approval Gate (Code / Debug / Refactor / Exec / PR / Loop Workflows)

The gate has two modes, selected once at workflow start: **Plan-Only / No-Changes** (opt-in via a clearly-delimited trigger phrase — print the plan and stop before any file change) and **Autonomous** (default — proceed end-to-end, no clarification questions). The operative rule — trigger phrases, per-mode behavior, nested-skill approval language — is canonical in `_lib/approval_gate.md`; read that file, this section deliberately does not restate it.

---

## Philosophy Reference (Mandatory)

Before doing any workflow-specific work, the main agent must read and follow `philosophy/philosophy.instructions.md`.

Every subagent created by any workflow must read and follow `_lib/subagent_contract.md` — the subagent-facing subset of this contract — and `philosophy/philosophy.instructions.md` before reading context files or performing task-specific work. Subagents do **not** read this file: the orchestration rules here are the main agent's to apply.

---

## Pack Path Resolution

The installed pack root is `.github/HarnessFlow` from the target repo root.

When a workflow references a pack-relative path such as `workflow/...`, `repo_info/...`, `philosophy/...`, `_lib/...`, or `skills/...`, resolve it in this order:

1. `.github/HarnessFlow/<path>` from the target repo root (installed layout).
2. `<path>` from the repo root when running in the source repo or when the pack root is the repo root.

In installed repos, do not create `repo_info/` outside `.github/HarnessFlow/repo_info/`.

---

## Subagent Launch Contract

- **Model:** resolve the `subagent_model` header as [specified subagent model]; note your own model as [main agent model]. Create every subagent on exactly [specified subagent model]. A specific model id is a deliberate override — honor it even if smaller than [main agent model]. `inherit` or unset falls back to [main agent model], which must not be downgraded: in **fast mode** (`mode: fast`) the default main model is **Sonnet 4.6**, so `inherit` subagents run on Sonnet 4.6; in general and skill modes they run on whatever model the main agent runs. (Request templates ship `subagent_model: claude-opus-5`.)
- **Effort:** the **second dial on every spawn** — resolve the `subagent_effort` header (`inherit` | `low` | `medium` | `high` | `xhigh` | `max`) as [specified subagent effort] alongside the model, never instead of it. **`inherit` or absent = use the session/main-agent effort:** set no platform effort field, add no `effort:` prompt line, log `effort: inherit`. Any other value is a deliberate override (even when lower) and must reach the subagent through one of two channels: **(a) the installed agent definition** — `effort:` frontmatter in `.claude/agents/*.md` / `--agents` JSON, `model_reasoning_effort` in `.codex/agents/*.toml`; per **role**, not per request: set it in the source `agents/<slug>.agent.md` and re-run `sync_agent_definitions.py` (Codex clamps `xhigh`/`max` to `high`). **(b) The prompt** — neither Claude Code's `Task` tool nor a Codex worker exposes a per-invocation effort parameter, so include the line `effort: [specified subagent effort] — binding budget, not a hint` in the subagent prompt and log `effort: prompt-enforced` (`_lib/subagent_contract.md` §Working Rules binds the subagent to it). Log `effort: not-applied` only when neither channel exists — never block a launch over effort. (Templates ship `subagent_effort: low` — a deliberate pin; `inherit` follows the session.)
- **Online Researcher effort:** resolve the `online_researcher_effort` header (same scale) as [specified online researcher effort]; when spawning the **Online Researcher** (`agents/online-researcher.agent.md`), use it **in place of** [specified subagent effort] — a per-role override, honored even when *lower*, enforced through the same two channels. `inherit` or absent falls back to [specified subagent effort]. The model is unaffected. (Templates ship `medium`; `initialize` omits it — that family spawns no Online Researcher.)
- **Analysis gates (`diversifier`, `devils_advocate`, `online_research`):** binary toggles for whether the **Diversifier**, **Devils Advocate**, and **Online Researcher** rows run where a workflow contains them. Defaults: `diversifier` **on** · `online_research` **on** · `devils_advocate` **off**; absent or unrecognized values resolve to the default. `on` spawns the subagent exactly as its row specifies; `off` skips it and leaves its output label unproduced — downstream steps consume whichever labels exist (as `_lib/review_skills.md` handles a skipped review skill). **Loop-family exception:** the exit-gater Devils Advocate is a safety guardrail and always runs; the toggle governs only the advisory spec-critique pass. (Templates ship `diversifier: on`, `devils_advocate: off`, `online_research: on`; query and loop omit `diversifier`, initialize omits all three.)
- **Turn cap (derived from effort):** `low` 12 · `medium` 20 · `high` 30 · `xhigh` 45 · `max` 60 — one turn = one assistant step; a batch of parallel tool calls counts as one. Same two channels: **(a)** every generated definition carries the cap (a native `maxTurns:` frontmatter field where the format has one, else a `turn budget:` body line), set by `sync_agent_definitions.py` from the def's pinned `effort:`, an explicit `max_turns:` source override, else the `max`-tier backstop (60). **(b)** Whenever the spawn's resolved effort is not `inherit`, append `turn budget: at most <N> tool-call turns` (N from the table) next to the `effort:` prompt line. The definition cap is the outer ceiling — a subagent stopped by it returns what it has; treat that as incomplete under the quality check below, not as a launch failure.
- A subagent means a separate spawned agent invocation with its own context. Main-agent roleplay, self-simulation, or inline execution must not be labeled as subagent output.
- Each subagent prompt must include: the exact task, required inputs, context files to read, the expected output label, and the `effort:` line whenever that role's resolved effort is not `inherit`. Ad-hoc fallback prompts (no installed definition — see §Subagent Invocation) must additionally include the role/mode and references to `_lib/subagent_contract.md` and `philosophy/philosophy.instructions.md`.
- For a parallel group, follow §Parallel Execution & Fallback below. If native subagent creation is unavailable, blocked, or cannot use the [specified subagent model], do not hide the failure: record a fallback result with the same output label and `status: fallback-single-agent` or `status: blocked`, then continue only where the workflow allows fallback.
- Maintain an in-memory activity log for every subagent group: role, output label, launch mechanism, requested model, confirmed model when available, requested effort and whether it was applied, context files, start status, completion status, and fallback reason if any.
- The `[subagent result]` and `[fallback result]` header blocks, and when they are required, are canonical in `_lib/subagent_contract.md` §Result Format; validate every returned result against that format.
- **Returned-result quality check (every spawn).** After each subagent returns, check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label. A result failing any of these is incomplete — retry per §Parallel Execution & Fallback or record a fallback; never consume it as if it had succeeded.

---

## Parallel Execution & Fallback

Canonical rule for every `[PARALLEL EXECUTION]` tag in the workflow files (the tags point here — this is the single source; do not restate it at the point of use):

1. **Launch in parallel:** launch all listed subagents as separate invocations, using your platform's subagent mechanism (see §Subagent Invocation), before waiting for any result. Preserve each subagent's expected output label.
2. **Validate creation:** after launching, verify each subagent was created successfully and returned a result.
3. **Retry on failure:** if any subagent fails to create or does not return a successful result, retry that specific subagent up to 3 times.
4. **Degrade to sequential:** if parallel launch is unavailable, or a subagent still fails after 3 retries, launch the same subagent prompts one at a time — sequential execution produces equivalent results.
5. **Fallback record:** if sequential creation also fails, record a `[fallback result]` with the same output label (per §Subagent Launch Contract) and do not label the work as subagent output. Continue only where the workflow or user allows fallback; otherwise report the blocked subagent step.

---

## Subagent Invocation — Platform-Specific Mechanisms

Use the platform's native mechanism; **prefer the installed agent definition over an ad-hoc prompt**. `sync_agent_definitions.py` projects every `agents/<slug>.agent.md` into a native definition — `.claude/agents/<slug>.md` (Claude Code), `.codex/agents/<slug>.toml` (Codex) — installed by `cli_setup.sh`; each role's **agent type is `<slug>`** (`agents/focus-analyst.agent.md` → `focus-analyst`). Spawning by agent type puts the role text in the subagent's *system prompt* — never re-sent as prompt tokens — and applies that role's tool/sandbox restriction. When a workflow names an agent file, resolve it to its agent type and spawn that.

| Platform | How to invoke |
|---|---|
| **VS Code + Copilot** | `agent` tool — invoke by agent name (`name:` in `.agent.md` frontmatter, case-sensitive). Preflight: the orchestrator's `tools:` includes `agent`, its `agents:` lists the target worker, and the `.agent.md` exists in `chat.agentFilesLocations` (default `.github/HarnessFlow/agents/`). |
| **Claude Code CLI** | `Task` tool, `subagent_type: <slug>`. The prompt carries **only** task-specific content — task, inputs, `[repo context digest]`, output label, `effort:` line when one applies — never the role text, behavioral contract, or output format (already the subagent's system prompt). |
| **Codex CLI** | Named agent worker (`.codex/agents/<slug>.toml`), same task-only prompt. Project definitions load only in a **trusted** project. If parallel workers are unavailable, launch sequentially and preserve output labels. |

**Fallback when no definition is installed** (definitions missing, project untrusted, or a platform without them): spawn ad-hoc with a complete prompt — role, task, required context files, output label, and references to `_lib/subagent_contract.md` and `philosophy/philosophy.instructions.md` — and log `launch mechanism: ad-hoc prompt` so the extra cost is visible. If invocation fails, record a fallback result and continue as the Subagent Launch Contract specifies.

---

## Implementer Model Verification Fallback

Canonical in `_lib/implementer_fallback.md` — read that file only when a workflow step creates an **Implementer** or **Executor** subagent (model verification, retries, and the direct-execution fallback live there).

---

## Key Context Files (repo_info/)

When any workflow instruction tells you to read context files (`[key md files]`), look for them under `repo_info/` (resolved via Pack Path Resolution):

1. `codebase_overview.md`
2. `scripts_overview.md`
3. `update_logs.md`
4. `known_issues.md`

- **Budgets:** the two overviews are token-budgeted (codebase ≤ 4k; scripts ≤ 4k, 8k for super-large repos) per `_lib/repo_map.md` — any step that updates either overview must first read `_lib/repo_map.md` and keep the file within budget.
- **`update_logs.md` holds only the 10 most recent entries.** The complete history lives in `repo_info/update_logs_all.md`, which is **not** part of [key md files] and is **not** read by default — open it only when the task depends on history older than the live file.
- **Documentation steps:** before writing any repo_info log entry (update_logs.md, past_Q&A.md, past_Correctness_Check.md), read `_lib/doc_logging.md` — canonical for entry timestamps, ID continuation, and the update_logs two-file rule.

### Multi-Layer / Nested Repos (cross-repo context)

Canonical in `_lib/multilayer_repos.md` — read that file only when the target repo may be multi-layer: it contains sub-repos, or itself sits inside an enclosing repo, with layers carrying their own `repo_info/`. Single-layer repos skip it.

---

## Context Passing for Subagents

Repo context reaches subagents the same way on every platform. To reduce redundant file reads across subagents, follow this pattern:

1. The main agent reads [key md files] **once** at workflow start and **keeps them as [full repo context]** in its own context for the rest of the run — the digest below is what subagents get, not a replacement for what the main agent itself retains.
2. The main agent creates a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes — plus, in multi-layer repos, a labeled per-layer summary of each discovered layer's overviews (§Key Context Files → Multi-Layer / Nested Repos).
3. When spawning a subagent, include [repo context digest] inline in its prompt together with the **specific excerpts of [full repo context] that subagent's task needs**, chosen per subagent. Never paste [full repo context] wholesale. Whenever a subagent's task references known issues, the relevant `known_issues.md` entries are a **required** excerpt, not an optional one — the digest does not carry them.
4. Rule 3 applies to every spawn. For the **Devils Advocate**, the **Online Researcher**, the `simplify` and `code_review` subagents (`_lib/review_skills.md`), and every review or validation subagent spawned after the implementation / execution step, it is also a **ceiling**: each receives **only** [repo context digest] plus the excerpts the main agent selected for it, and nothing beyond that.
5. Subagents use what they were handed for codebase context and only read additional **specific code files** directly relevant to their task. Subagents do **not** independently re-read the repo_info files.

In the workflow files, the neutral phrase "the repo context (per §Context Passing)" refers to this rule.
