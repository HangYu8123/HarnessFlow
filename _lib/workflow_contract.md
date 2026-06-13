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

**Rule:** No approval is needed unless the user explicitly requests it. After printing the plan, the workflow **proceeds directly to implementation by default**; it stops and waits for explicit approval only when the user's prompt activates the gate (e.g., `plan:`, `plan only`, `review first`, `no filechanges`, `no changes`). See `_lib/approval_gate.md` for the operative rule.

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

- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]
- A subagent means a separate spawned agent invocation with its own context. Main-agent roleplay, self-simulation, or inline execution must not be labeled as subagent output.
- Each subagent prompt must include: the role/mode, exact task, required inputs, context files to read, expected output label, this contract path, and `philosophy/philosophy.instructions.md`.
- For a parallel group, launch all listed subagents as separate invocations before waiting for results. If parallel launch is unavailable, launch the same subagent prompts one at a time; preserve the same output labels.
- If native subagent creation is unavailable, blocked, or cannot preserve model parity, do not hide the failure. Record a fallback result with the same output label and `status: fallback-single-agent` or `status: blocked`, then continue only where the workflow allows fallback.
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
| **VS Code + Copilot** | `agent` tool (built-in tool set) | Invoke by agent name (matches `name:` in `.agent.md` frontmatter). Ensure the coordinator's `tools:` includes `agent` and `agents:` lists the target agent names. |
| **Claude Code CLI** | `Task` tool | Pass a complete prompt including role, task, required context files, output label, and references to `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md`. |
| **Codex CLI** | Agent workers / sequential fallback | Pass same prompt structure. If parallel workers are unavailable, launch sequentially and preserve output labels. |

Before invoking a subagent in VS Code, ensure:
1. The coordinator agent's frontmatter declares `tools: ['agent', ...]` and lists the target agent in `agents: [...]`.
2. The target agent exists as a `.agent.md` file in the configured `chat.agentFilesLocations` directory (default: `.github/HarnessFlow/agents/`).
3. The target agent's `name:` field matches the name used in the `agents:` list exactly (case-sensitive).

If subagent invocation fails (e.g., tool is unavailable, agent not found), record a fallback result and continue as specified in the Subagent Launch Contract above.

---

## Implementer Model Verification Fallback

When creating an **Implementer** subagent, the main agent must verify model parity before the subagent begins any implementation work.

**Claude Code CLI:** Subagents inherit the session model automatically. Model verification is not required — skip the retry loop and proceed directly. If a subagent spawn fails for any reason, the main agent performs the implementation directly and records a `[fallback result]` with `status: fallback-single-agent`.

**Other platforms (VS Code Copilot, Codex CLI):**

1. After creating the **Implementer** subagent, the main agent must confirm the subagent's model matches [main agent model] before the subagent starts implementing.
2. If the subagent's model does not match [main agent model], stop that subagent immediately.
3. Re-create the **Implementer** subagent (retry up to 3 times total).
4. If after 3 retries the **Implementer** subagent still cannot use [main agent model], the main agent must abandon the subagent approach and perform the implementation directly itself, following the same plan and instructions that would have been given to the **Implementer** subagent. Record a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`.

This fallback applies to every workflow step that creates an **Implementer** or **Executor** subagent.

---

## Key Context Files (repo_info/)

When any workflow instruction tells you to read context files (`[key md files]`), look for them under `repo_info/` (resolved via Pack Path Resolution):

1. `codebase_overview.md`
2. `scripts_overview.md`
3. `update_logs.md`
4. `known_issues.md`

---

## Context Passing for Subagents (Claude Code)

To reduce redundant file reads across subagents, Claude Code workflows must follow this pattern:

1. The main agent reads [key md files] **once** at workflow start.
2. The main agent creates a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes from update_logs, and active known issues.
3. When spawning subagents, include [repo context digest] inline in the subagent prompt.
4. Subagents use [repo context digest] for codebase context and only read additional **specific code files** directly relevant to their task. Subagents do **not** independently re-read the repo_info files.

This applies to all `workflow/claudecode_workflow/` instructions. Other workflow families (VS Code, Codex) continue to have subagents read [key md files] directly, since their subagent mechanisms may not support inline context passing.
