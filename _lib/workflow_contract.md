# Workflow Contract

This document consolidates the shared rules, principles, and requirements that apply to all workflows, agents, and subagents in HarnessFlow.

---

## Universal Safety Rules (Always Apply)

These rules apply to **every** workflow, agent, and subagent — no exceptions.

1. **DO NOT TRY TO COMMIT CHANGES TO GITHUB**
2. **DO NOT WRITE SPAM FILES INTO THE REPO**
3. **DO NOT USE SUDO**

---

## Approval Gate (Code / Debug / Refactor / Exec / PR / Loop Workflows)

The gate has two modes, selected once at workflow start: **Plan-Only / No-Changes** (opt-in via a clearly-delimited trigger phrase — print the plan and stop before any file change) and **Autonomous** (default — proceed end-to-end, no clarification questions).
The operative rule — the trigger-phrase list, per-mode behavior, and nested-skill approval language — lives in `_lib/approval_gate.md` (canonical; read that file — this section deliberately does not restate it).

---

## Philosophy Reference (Mandatory)

Before doing any workflow-specific work, the main agent must read and follow `philosophy/philosophy.instructions.md`.

Every subagent created by any workflow must also read and follow this contract and `philosophy/philosophy.instructions.md` before reading context files or performing task-specific work.

---

## Pack Path Resolution

The installed pack root is `.github/HarnessFlow` from the target repo root.

When a workflow references a pack-relative path such as `workflow/...`, `repo_info/...`, `philosophy/...`, `_lib/...`, or `skills/...`, resolve it in this order:

1. `.github/HarnessFlow/<path>` from the target repo root (installed layout).
2. `<path>` from the repo root when running in the source repo or when the pack root is the repo root.

In installed repos, do not create `repo_info/` outside `.github/HarnessFlow/repo_info/`.

---

## Subagent Launch Contract

- Before creating any subagent, resolve the model the instructions specify for subagents — the `subagent_model` header value — and refer to it as [specified subagent model]. Also note what model the main agent is itself running, and refer to that as [main agent model], because [specified subagent model] resolves to [main agent model] whenever `subagent_model` is `inherit` or unset.
- when creating any subagent, explicitly instruct the main agent to: "**Create the subagent with the exact [specified subagent model]. When `subagent_model` is a specific model id, use that exact id — a deliberate override; honor it even if it is smaller than [main agent model]. When `subagent_model` is `inherit` or unset, use [main agent model] and do not downgrade.**"
- Subagents must use the [specified subagent model]
- **Subagent model (specified by the instructions):** Every subagent uses the model the instructions specify via the `subagent_model` header. When `subagent_model` is a specific model id, all subagents run on that exact id (a deliberate override — honor it even if it is smaller than [main agent model]). When `subagent_model` is `inherit` or unset, [specified subagent model] falls back to [main agent model] — the model the main agent is running — which must not be downgraded: in **fast mode** (`mode: fast`) the default main model is **Sonnet 4.6**, so `inherit` subagents run on Sonnet 4.6; in **general** and **skill** modes `inherit` subagents run on whatever model the main agent is running. (Request templates ship with `subagent_model: inherit`.)
- **Subagent effort (optional header):** When the request includes a `subagent_effort` header (`low` | `medium` | `high` | `xhigh` | `max` — Claude Code's documented effort scale; available levels depend on the model), resolve it as [specified subagent effort]. Where the platform exposes a reasoning-effort control for the subagent being created — Claude Code custom-agent definitions (`.claude/agents/*.md`) and `--agents` JSON support an `effort:` frontmatter field separate from `model:`, which overrides the session effort and inherits from the session when unset — create the subagent with [specified subagent effort]. Ad-hoc prompt-only spawns (e.g. the Claude Code `Task` tool, Codex workers) have **no per-invocation effort parameter**: record `effort: not-applied` in the activity log and continue — never block or fail a launch over effort. When the header is absent, subagents inherit the session/main-agent effort. Role-specific effort headers (see §Online Researcher effort below) override [specified subagent effort] for the named role when present.
- **Online Researcher effort (optional header):** When the request includes an `online_researcher_effort` header (same scale: `low` | `medium` | `high` | `xhigh` | `max`), resolve it as [specified online researcher effort]. When spawning the **Online Researcher** subagent (`agents/online-researcher.agent.md`), use [specified online researcher effort] in place of [specified subagent effort]. The same platform caveat applies: ad-hoc prompt-only spawns record `effort: not-applied`; only agent-definition-time effort fields are enforceable. When the header is absent, the Online Researcher uses [specified subagent effort] (which itself inherits the session effort when absent). The model is unaffected — the Online Researcher still uses [specified subagent model].
- A subagent means a separate spawned agent invocation with its own context. Main-agent roleplay, self-simulation, or inline execution must not be labeled as subagent output.
- Each subagent prompt must include: the role/mode, exact task, required inputs, context files to read, expected output label, this contract path, and `philosophy/philosophy.instructions.md`.
- For a parallel group, follow §Parallel Execution & Fallback below.
- If native subagent creation is unavailable, blocked, or cannot use the [specified subagent model], do not hide the failure. Record a fallback result with the same output label and `status: fallback-single-agent` or `status: blocked`, then continue only where the workflow allows fallback.
- Maintain an in-memory activity log for every subagent group with: role, output label, launch mechanism, requested model, confirmed model when available, requested effort and whether it was applied (see §Subagent effort), context files, start status, completion status, and fallback reason if any.
- Every real subagent result should include the following metadata. **In VS Code Copilot and Codex**, the result must begin with this header block. **In Claude Code**, the header is optional — the `Task` tool scopes results automatically, so subagents may return their analysis directly without the header:

```md
[subagent result]
role:
output_label:
status: completed | skipped | blocked | failed
model:
result:
```

- Every fallback result must begin with:

```md
[fallback result]
role:
output_label:
status: fallback-single-agent | blocked
model:
result:
```

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

When a workflow says to "launch" or "create" a subagent, use the platform's native mechanism:

| Platform | Mechanism | How to invoke |
|---|---|---|
| **VS Code + Copilot** | `agent` tool (built-in tool set) | Invoke by agent name (matches `name:` in `.agent.md` frontmatter). Ensure the orchestrating agent's `tools:` includes `agent` and `agents:` lists the target worker-agent names. |
| **Claude Code CLI** | `Task` tool | Pass a complete prompt including role, task, required context files, output label, and references to `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md`. |
| **Codex CLI** | Agent workers / sequential fallback | Pass same prompt structure. If parallel workers are unavailable, launch sequentially and preserve output labels. |

Before invoking a subagent in VS Code, ensure:
1. The orchestrating agent's frontmatter declares `tools: ['agent', ...]` and lists the target worker agent in `agents: [...]`.
2. The target agent exists as a `.agent.md` file in the configured `chat.agentFilesLocations` directory (default: `.github/HarnessFlow/agents/`).
3. The target agent's `name:` field matches the name used in the `agents:` list exactly (case-sensitive).

If subagent invocation fails (e.g., tool is unavailable, agent not found), record a fallback result and continue as specified in the Subagent Launch Contract above.

---

## Implementer Model Verification Fallback

When creating an **Implementer** subagent, the main agent must ensure the subagent runs on the [specified subagent model] (per §Subagent Launch Contract) before the subagent begins any implementation work.

**Claude Code CLI:** The main agent launches the Implementer on the [specified subagent model] by setting the subagent's model explicitly when spawning it — when `subagent_model` is a specific id, spawn on that exact id (honor it even if smaller); when it is `inherit` or unset, the subagent inherits the session model ([main agent model]) and must not be downgraded. No retry loop is needed. If a subagent spawn fails for any reason, the main agent performs the implementation directly and records a `[fallback result]` with `status: fallback-single-agent`.

**Other platforms (VS Code Copilot, Codex CLI):**

1. After creating the **Implementer** subagent, the main agent must confirm the subagent's model matches the [specified subagent model] before the subagent starts implementing.
2. If the subagent's model does not match the [specified subagent model], stop that subagent immediately.
3. Re-create the **Implementer** subagent (retry up to 3 times total).
4. If after 3 retries the **Implementer** subagent still cannot use the [specified subagent model], the main agent must abandon the subagent approach and perform the implementation directly itself, following the same plan and instructions that would have been given to the **Implementer** subagent. Record a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`.

This fallback applies to every workflow step that creates an **Implementer** or **Executor** subagent.

---

## Key Context Files (repo_info/)

When any workflow instruction tells you to read context files (`[key md files]`), look for them under `repo_info/` (resolved via Pack Path Resolution):

1. `codebase_overview.md`
2. `scripts_overview.md`
3. `update_logs.md`
4. `known_issues.md`

### Multi-Layer / Nested Repos (cross-repo context)

A target repo may be multi-layer: it may contain sub-repos (workspace packages, git submodules, vendored repos), or itself be a sub-repo inside an enclosing repo beside adjacent sibling repos — several layers each carrying their own `repo_info/` (resolved per Pack Path Resolution from that layer's root: `<layer>/.github/HarnessFlow/repo_info/` or `<layer>/repo_info/`).

Whenever a workflow says to read [key md files], the main agent must also, **once at context-gathering time**:

1. **Discover layers downward.** Prefer explicit signals at the target repo root — workspace manifests (`package.json` `workspaces`, `pnpm-workspace.yaml`, `Cargo.toml` `[workspace]`) and `.gitmodules` — then a top-down directory scan for `repo_info/` layers that stops descending into any directory identified as a layer and skips `.git/`, `node_modules/`, build outputs, and git-ignored paths. Scan `vendor/`-style directories only one level deep for an explicit `repo_info/` layer: a hand-vendored repo there is a valid layer; package-manager-populated contents are not.
2. **Discover layers upward (adjacent repos).** If the target repo root sits inside an enclosing repo — nearest ancestor containing `.git/` or an installed pack root — include that enclosing layer and its immediate sub-repos (the target's siblings) when they carry their own `repo_info/`. Stop at that first enclosing boundary: never walk higher, and never scan outside it; if no enclosing repo exists, there are no upward layers.
3. **Read only the two overviews per discovered non-target layer:** that layer's `codebase_overview.md` and `scripts_overview.md` (skip its other repo_info files). These count as part of [key md files] for the request and flow to subagents per §Context Passing; on platforms where subagents read files directly, list each discovered layer's overview paths explicitly in the subagent prompt's context files.
4. **Label per layer, additive.** Keep every cross-layer fact attributed to its layer (e.g. `[layer: <relative path>]`); on conflict, the target repo's own repo_info wins.
5. **Bound the sweep, never silently.** If more than 5 layers are discovered, read the ones relevant to [inputs]/the files being changed and list the skipped layers explicitly in the digest/plan.
6. **Pack identity is unaffected.** Discovery never changes Pack Path Resolution or which pack's `workflow/`, `_lib/`, and `philosophy/` govern the request — per `_lib/absolutize_pack_paths.md`, a pack resolves from its own root, never from `git rev-parse --show-toplevel`.
7. **Writes.** Documentation steps write the target repo's own repo_info. If the workflow changed files inside a discovered layer that already has its own repo_info, update that layer's existing repo_info files too. Never create a `repo_info/` in another layer (and, in installed repos, never outside `.github/HarnessFlow/repo_info/`).

---

## Log Entry Timestamps

Every documentation entry template (update_logs.md, past_Q&A.md, past_Correctness_Check.md) carries a timestamp element immediately before its ID/number element, format `YYYY-MM-DD HH:MM` (24-hour, local time).

- Obtain it from the system clock at write time — `date '+%Y-%m-%d %H:%M'` (POSIX-portable) or your platform shell's equivalent. Never write a guessed time.
- If no shell/clock is available, use the environment-provided current date and write the date only (`YYYY-MM-DD`) — never invent the time of day. If no reliable current date is available either, omit the timestamp element entirely.
- The timestamp is never an ID. Determine the "last ID" per the workflow's own ID rule, reading prior entries' IDs at their labeled position (in banner-style Q&A / Correctness Check entries: the number after the em-dash, or after the colon in older entries without timestamps); ignore timestamp digits and positional numbers such as "PR 1/5". Entries written before this convention (no timestamp) remain valid.

---

## Context Passing for Subagents

The unified workflows (`workflow/general_workflow/` and `workflow/token_effective_workflow/`) are platform-adaptive; how repo context reaches subagents depends on the **active agent**, not the directory:

**Claude Code** — to reduce redundant file reads across subagents, follow this pattern:

1. The main agent reads [key md files] **once** at workflow start.
2. The main agent creates a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes from update_logs, and active known issues — plus, in multi-layer repos, a labeled per-layer summary of each discovered layer's overviews (§Key Context Files → Multi-Layer / Nested Repos).
3. When spawning subagents, include [repo context digest] inline in the subagent prompt.
4. Subagents use [repo context digest] for codebase context and only read additional **specific code files** directly relevant to their task. Subagents do **not** independently re-read the repo_info files.

**Codex and VS Code Copilot** — subagents read [key md files] directly, since their subagent mechanisms may not support inline context passing.

In the workflow files, the neutral phrase "the repo context (per §Context Passing)" refers to this rule: it resolves to [repo context digest] on Claude Code and to [key md files] on Codex / VS Code Copilot.
