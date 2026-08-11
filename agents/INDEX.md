# Agent Registry

This file lists all custom agents defined in this pack. Workflow instruction files reference these agents by name when creating subagents.

`agents/*.agent.md` is the **single source of truth** for every role. `sync_agent_definitions.py` projects each one into the two native definition formats, and `cli_setup.sh` installs them into the target repo:

| Source | Generated | Consumed by |
|---|---|---|
| `agents/<slug>.agent.md` | — | VS Code Copilot (`chat.agentFilesLocations`) |
| ↳ | `.claude/agents/<slug>.md` | Claude Code (agent type `<slug>`) |
| ↳ | `.codex/agents/<slug>.toml` | Codex (named worker `<slug>`) |

**After editing any `agents/*.agent.md`, re-run `python3 sync_agent_definitions.py` from the pack root.** The generated files carry a do-not-edit marker and are rewritten whole on every sync.

## How Agents Are Invoked

Each platform uses its native mechanism. Spawning by the installed definition is always preferred: the role text becomes the subagent's **system prompt** rather than spawn-prompt tokens, so it is neither re-sent per spawn nor read in-band, and the role's tool/sandbox restriction applies automatically. See `_lib/workflow_contract.md` §Subagent Invocation for the full rule and the ad-hoc fallback.

- **VS Code Copilot**: Agents discovered from `.github/HarnessFlow/agents/` (configured via `chat.agentFilesLocations` in `setup.sh`). The routed main agent (the Master Orchestrator in `copilot-instructions.md`, following the matched workflow instruction file) invokes these worker agents by name.
- **Claude Code CLI**: Spawn via the `Task` tool with `subagent_type: <slug>`, resolved from `.claude/agents/`. The prompt carries only task-specific content — never the role text, behavioral contract, or output format, all of which are already the subagent's system prompt. For parallel execution, Claude Code launches agent teams — multiple sub-agents working concurrently and coordinating through the main agent.
- **Codex CLI / Codex-in-VS Code**: Spawn the named worker defined in `.codex/agents/<slug>.toml`; project definitions load only in a **trusted** project. Codex agent workers handle parallel execution (concurrency controlled by `agents.max_threads`). Applies to both Codex CLI and Codex running in VS Code. Sequential fallback if worker spawning or the specified subagent model is unavailable.

## Worker Subagents

Worker agents are `user-invocable: false` — they are only accessible as subagents invoked by the routed main agent while it follows a workflow instruction file. The **Agent Type** column is the name to spawn by; it is the source filename without `.agent.md`. Tools and sandbox below are what the generated definitions actually enforce.

| Agent Type | Cognitive Mode / Role | Tools (Claude Code) | Sandbox (Codex) | Used In Workflows |
|---|---|---|---|---|
| `focus-analyst` | **Focus Analyst** — Focus Mode (depth on key files) | Read, Grep, Glob | read-only | code, debug, query, correctness_check, refactor, initialize, exec |
| `broad-analyst` | **Broad Analyst** — Broad Mode (pipeline upstream→downstream) | Read, Grep, Glob | read-only | code, debug, query, correctness_check, refactor, initialize |
| `free-analyst` | **Free Analyst** — Free Mode (own judgment) | Read, Grep, Glob | read-only | code, debug, query, correctness_check, refactor, initialize, exec |
| `senior-engineer` | **Senior Engineer** — Senior Staff Engineer review | Read, Grep, Glob | read-only | code, debug, refactor, exec |
| `principal-engineer` | **Principal Engineer** — Principal Engineer review (refactor authority) | Read, Grep, Glob | read-only | refactor (general only) |
| `devils-advocate` | **Devils Advocate** — Critical challenger (finds risks; at draft stage also grills the main agent, grill-me style) | Read, Grep, Glob | read-only | code, debug, query, correctness_check, refactor, exec |
| `diversifier` | **Diversifier** — Alternative-plan generation (3–5 constraint-fenced diverse plans + calibrated `P(better)` + `graftable:` components) | Read, Grep, Glob | read-only | code, debug, refactor, exec, pr, correctness_check |
| `online-researcher` | **Online Researcher** — External resource lookup | Read, Grep, Glob, WebSearch, WebFetch | read-only | code, debug, query, correctness_check, refactor, exec |
| `implementer` | **Implementer** — Code implementation | Read, Grep, Glob, Edit, Write, Bash | workspace-write | code, debug, refactor |
| `executor` | **Executor** — Cmd/skill execution | Read, Grep, Glob, Bash | workspace-write | exec |
| `qa-engineer` | **QA Engineer** — QA validation and script execution | Read, Grep, Glob, Bash | workspace-write | code, debug, correctness_check, refactor, exec |
| `bug-reproducer` | **Bug Reproducer** — Reproduces bug by running target scripts and capturing output | Read, Grep, Glob, Bash | workspace-write | debug |
| `architecture-analyst` | **Architecture Analyst** — Architecture improvement analysis | Read, Grep, Glob | read-only | refactor (general only) |
| `redundancy-analyst` | **Redundancy Analyst** — Redundancy reduction analysis | Read, Grep, Glob | read-only | refactor (general only) |
| `robustness-analyst` | **Robustness Analyst** — Robustness improvement analysis | Read, Grep, Glob | read-only | refactor (general only) |
| `complexity-analyst` | **Complexity Analyst** — Complexity reduction analysis | Read, Grep, Glob | read-only | refactor (general only) |

## Orchestration

This pack has no separate coordinator agent files. The per-category workflow instruction files under `workflow/<family>/` act as the coordinators: the routed main agent reads the matched instruction file and spawns the worker agents above — in parallel where the workflow specifies — using its platform's native subagent mechanism. See `_lib/workflow_contract.md` §Subagent Invocation for the per-platform mechanics.
