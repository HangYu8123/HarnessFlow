# Workflow Contract

This document consolidates the shared rules, principles, and requirements that apply to all workflows, agents, and subagents in harness_coding_instructions.

---

## Universal Safety Rules (Always Apply)

These rules apply to **every** workflow, agent, and subagent — no exceptions.

1. **DO NOT TRY TO COMMIT CHANGES TO GITHUB**
2. **DO NOT WRITE SPAM FILES INTO THE REPO**
3. **DO NOT USE SUDO**

---

## Approval Gate (Code / Debug / Refactor Workflows Only)

**Rule:** If the user requests no code changes, the workflow **stops after printing the plan**. If the user has not specified or requires code changes, the workflow continues to the implementation step.

This gate applies regardless of which CLI tool or IDE is being used.

---

## Philosophy Reference (Mandatory)

Before doing any workflow-specific work, the main agent must read and follow `philosophy/philosophy.instructions.md`.

Every subagent created by any workflow must also read and follow this contract and `philosophy/philosophy.instructions.md` before reading context files or performing task-specific work.

---

## Pack Path Resolution

The installed pack root is `.github/harness_coding_instructions` from the target repo root.

When a workflow references a pack-relative path such as `workflow/...`, `repo_info/...`, `philosophy/...`, `_lib/...`, or `skills/...`, resolve it in this order:

1. `.github/harness_coding_instructions/<path>` from the target repo root.
2. `<path>` only when the current working directory is already the pack root.

Do not create `repo_info/` outside `.github/harness_coding_instructions/repo_info/`.

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
- Every real subagent result must begin with:

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
2. The target agent exists as a `.agent.md` file in the configured `chat.agentFilesLocations` directory (default: `.github/harness_coding_instructions/agents/`).
3. The target agent's `name:` field matches the name used in the `agents:` list exactly (case-sensitive).

If subagent invocation fails (e.g., tool is unavailable, agent not found), record a fallback result and continue as specified in the Subagent Launch Contract above.

---

## Implementer Model Verification Fallback

When creating an **Implementer** subagent, the main agent must verify model parity before the subagent begins any implementation work:

1. After creating the **Implementer** subagent, the main agent must confirm the subagent's model matches [main agent model] before the subagent starts implementing.
2. If the subagent's model does not match [main agent model], stop that subagent immediately.
3. Re-create the **Implementer** subagent (retry up to 3 times total).
4. If after 3 retries the **Implementer** subagent still cannot use [main agent model], the main agent must abandon the subagent approach and perform the implementation directly itself, following the same plan and instructions that would have been given to the **Implementer** subagent. Record a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`.

This fallback applies to every workflow step that creates an **Implementer** subagent.

---

## Key Context Files (repo_info/)

When any workflow instruction tells you to read context files (`[key md files]`), look for them under `.github/harness_coding_instructions/repo_info/`:

1. `codebase_overview.md`
2. `scripts_overview.md`
3. `update_logs.md`
4. `known_issues.md`
