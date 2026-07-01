# Workflow Contract

This document consolidates the shared rules, principles, and requirements that apply to all workflows, agents, and subagents in HarnessFlow.

---

## Universal Safety Rules (Always Apply)

These rules apply to **every** workflow, agent, and subagent — no exceptions.

1. **DO NOT TRY TO COMMIT CHANGES TO GITHUB**
2. **DO NOT WRITE SPAM FILES INTO THE REPO**
3. **DO NOT USE SUDO**

---

## Approval Gate (Code / Debug / Refactor / Exec / PR Workflows)

**Rule:** The gate has **two modes**, selected once at workflow start from the user's prompt (see `_lib/approval_gate.md` for the operative rule):

- **Mode 1 — Plan-Only / No-Changes (opt-in):** activated when the prompt explicitly asks for plan-only or no file changes (e.g., `plan:`, `plan only`, `no file changes`, `no changes`, `review first`, `dry run`). Run the read-only planning pipeline, print the plan, and **stop before any file change** — wait for explicit approval before implementing.
- **Mode 2 — Autonomous (default):** every other prompt. Proceed end-to-end without stopping. Make the best reasonable assumptions, state them in one line each in the plan, and **do not ask clarification questions** — the model decides ambiguous scope/design choices itself. Pause only for irreversible/destructive or outward-facing actions not already covered by the request and `_lib/safety_rules.md`.

This gate applies regardless of which CLI tool or IDE is being used.

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
- A subagent means a separate spawned agent invocation with its own context. Main-agent roleplay, self-simulation, or inline execution must not be labeled as subagent output.
- Each subagent prompt must include: the role/mode, exact task, required inputs, context files to read, expected output label, this contract path, and `philosophy/philosophy.instructions.md`.
- For a parallel group, launch all listed subagents as separate invocations before waiting for results. If parallel launch is unavailable, launch the same subagent prompts one at a time; preserve the same output labels.
- If native subagent creation is unavailable, blocked, or cannot use the [specified subagent model], do not hide the failure. Record a fallback result with the same output label and `status: fallback-single-agent` or `status: blocked`, then continue only where the workflow allows fallback.
- Maintain an in-memory activity log for every subagent group with: role, output label, launch mechanism, requested model, confirmed model when available, context files, start status, completion status, and fallback reason if any.
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

---

## Context Passing for Subagents

The unified workflows (`workflow/general_workflow/` and `workflow/token_effective_workflow/`) are platform-adaptive; how repo context reaches subagents depends on the **active agent**, not the directory:

**Claude Code** — to reduce redundant file reads across subagents, follow this pattern:

1. The main agent reads [key md files] **once** at workflow start.
2. The main agent creates a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes from update_logs, and active known issues.
3. When spawning subagents, include [repo context digest] inline in the subagent prompt.
4. Subagents use [repo context digest] for codebase context and only read additional **specific code files** directly relevant to their task. Subagents do **not** independently re-read the repo_info files.

**Codex and VS Code Copilot** — subagents read [key md files] directly, since their subagent mechanisms may not support inline context passing.

In the workflow files, the neutral phrase "the repo context (per §Context Passing)" refers to this rule: it resolves to [repo context digest] on Claude Code and to [key md files] on Codex / VS Code Copilot.
