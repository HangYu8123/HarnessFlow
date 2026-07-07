# Agent Registry

This file lists all custom agents defined in this pack. Workflow instruction files reference these agents by name when creating subagents.

## How Agents Are Invoked

Each platform uses its native mechanism to invoke agents by name:

- **VS Code Copilot**: Agents discovered from `.github/HarnessFlow/agents/` (configured via `chat.agentFilesLocations` in `setup.sh`). The routed main agent (the Master Orchestrator in `copilot-instructions.md`, following the matched workflow instruction file) invokes these worker agents by name.
- **Claude Code CLI**: Agent definitions in `agents/` directory referenced by role name. Sub-agents spawned via Claude Code's native `Task` tool with inline prompts. For parallel execution, Claude Code launches agent teams — multiple sub-agents working concurrently and coordinating through the main agent.
- **Codex CLI / Codex-in-VS Code**: Agents referenced by name; Codex agent workers handle parallel execution (concurrency controlled by `agents.max_threads`). Applies to both Codex CLI and Codex running in VS Code. Sequential fallback if worker spawning or the specified subagent model is unavailable.

## Worker Subagents

Worker agents are `user-invocable: false` — they are only accessible as subagents invoked by the routed main agent while it follows a workflow instruction file.

| Agent Name | Cognitive Mode / Role | Tools | Used In Workflows | File |
|---|---|---|---|---|
| **Focus Analyst** | Focus Mode (depth on key files) | read, search, listDir | code, debug, query, correctness_check, refactor, initialize, exec | `focus-analyst.agent.md` |
| **Broad Analyst** | Broad Mode (pipeline upstream→downstream) | read, search, listDir | code, debug, query, correctness_check, refactor, initialize | `broad-analyst.agent.md` |
| **Free Analyst** | Free Mode (own judgment) | read, search, listDir | code, debug, query, correctness_check, refactor, initialize, exec | `free-analyst.agent.md` |
| **Senior Engineer** | Senior Staff Engineer review | read, search, listDir | code, debug, refactor, exec | `senior-engineer.agent.md` |
| **Principal Engineer** | Principal Engineer review (refactor authority) | read, search, listDir | refactor (general only) | `principal-engineer.agent.md` |
| **Devils Advocate** | Critical challenger (finds risks) | read, search, listDir | code, debug, query, correctness_check, refactor, exec | `devils-advocate.agent.md` |
| **Online Researcher** | External resource lookup | read, search, listDir, web/fetch | code, debug, query, correctness_check, refactor, exec | `online-researcher.agent.md` |
| **Implementer** | Code implementation | read, search, listDir, edit, createFile, runInTerminal | code, debug, refactor | `implementer.agent.md` |
| **Executor** | Cmd/skill execution | read, search, execute | exec | `executor.agent.md` |
| **QA Engineer** | QA validation and script execution | read, search, listDir, runInTerminal | code, debug, correctness_check, refactor, exec | `qa-engineer.agent.md` |
| **Bug Reproducer** | Reproduces bug by running target scripts and capturing output | read, search, execute | debug | `bug-reproducer.agent.md` |
| **Architecture Analyst** | Architecture improvement analysis | read, search, listDir | refactor (general only) | `architecture-analyst.agent.md` |
| **Redundancy Analyst** | Redundancy reduction analysis | read, search, listDir | refactor (general only) | `redundancy-analyst.agent.md` |
| **Robustness Analyst** | Robustness improvement analysis | read, search, listDir | refactor (general only) | `robustness-analyst.agent.md` |
| **Complexity Analyst** | Complexity reduction analysis | read, search, listDir | refactor (general only) | `complexity-analyst.agent.md` |

## Orchestration

This pack has no separate coordinator agent files. The per-category workflow instruction files under `workflow/<family>/` act as the coordinators: the routed main agent reads the matched instruction file and spawns the worker agents above — in parallel where the workflow specifies — using its platform's native subagent mechanism. See `_lib/workflow_contract.md` §Subagent Invocation for the per-platform mechanics.
