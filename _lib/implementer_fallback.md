# Implementer Model Verification Fallback

Read this file only when a workflow step creates an **Implementer** or **Executor** subagent
(the stub under `_lib/workflow_contract.md` §Implementer Model Verification Fallback points here).
It applies to every such step.

When creating an **Implementer** subagent, the main agent must ensure the subagent runs on the [specified subagent model] (per `_lib/workflow_contract.md` §Subagent Launch Contract) before the subagent begins any implementation work.

**Claude Code CLI:** The main agent launches the Implementer on the [specified subagent model] by setting the subagent's model explicitly when spawning it — when `subagent_model` is a specific id, spawn on that exact id (honor it even if smaller); when it is `inherit` or unset, the subagent inherits the session model ([main agent model]) and must not be downgraded. No retry loop is needed. If a subagent spawn fails for any reason, the main agent performs the implementation directly and records a `[fallback result]` with `status: fallback-single-agent`.

**Other platforms (VS Code Copilot, Codex CLI):**

1. After creating the **Implementer** subagent, the main agent must confirm the subagent's model matches the [specified subagent model] before the subagent starts implementing.
2. If the subagent's model does not match the [specified subagent model], stop that subagent immediately.
3. Re-create the **Implementer** subagent (retry up to 3 times total).
4. If after 3 retries the **Implementer** subagent still cannot use the [specified subagent model], the main agent must abandon the subagent approach and perform the implementation directly itself, following the same plan and instructions that would have been given to the **Implementer** subagent. Record a `[fallback result]` with `status: fallback-single-agent` and `reason: implementer-model-mismatch`.
