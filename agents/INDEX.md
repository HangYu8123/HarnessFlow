# Agent Registry

This file lists all custom agents defined in this pack. Workflow instruction files reference these agents by name when creating subagents.

## How Agents Are Invoked

Each platform uses its native mechanism to invoke agents by name:

- **VS Code Copilot**: Agents discovered from `.github/harness_coding_instructions/agents/` (configured via `chat.agentFilesLocations` in `setup.sh`). Coordinator agents use `tools: ['agent']` with `agents: [...]` to invoke subagents by name.
- **Claude Code CLI**: Agent definitions in `agents/` directory referenced by role name. Sub-agents spawned via Claude Code's native `Task` tool with inline prompts. For parallel execution, Claude Code launches agent teams — multiple sub-agents working concurrently and coordinating through the main agent.
- **Codex CLI / Codex-in-VS Code**: Agents referenced by name; Codex agent workers handle parallel execution (concurrency controlled by `agents.max_threads`). Applies to both Codex CLI and Codex running in VS Code. Sequential fallback if worker spawning or model parity is unavailable.

## Worker Subagents

Worker agents are `user-invocable: false` — they are only accessible as subagents invoked by coordinator agents or the main agent.

| Agent Name | Cognitive Mode / Role | Tools | Used In Workflows | File |
|---|---|---|---|---|
| **Focus Analyst** | Focus Mode (depth on key files) | read, search, listDir | code, debug, query, correctness_check, refactor, initialize, exec | `focus-analyst.agent.md` |
| **Broad Analyst** | Broad Mode (pipeline upstream→downstream) | read, search, listDir | code, debug, query, correctness_check, refactor, initialize | `broad-analyst.agent.md` |
| **Free Analyst** | Free Mode (own judgment) | read, search, listDir | code, debug, query, correctness_check, refactor, initialize, exec | `free-analyst.agent.md` |
| **Senior Engineer** | Senior Staff Engineer review | read, search, listDir | code, debug, refactor, exec | `senior-engineer.agent.md` |
| **Principal Engineer** | Principal Engineer review (refactor authority) | read, search, listDir | refactor | `principal-engineer.agent.md` |
| **Devils Advocate** | Critical challenger (finds risks) | read, search, listDir | code, debug, query, correctness_check, refactor, exec | `devils-advocate.agent.md` |
| **Online Researcher** | External resource lookup | read, search, listDir, web/fetch | code, debug, query, correctness_check, refactor, exec | `online-researcher.agent.md` |
| **Implementer** | Code implementation | read, search, listDir, edit, createFile, runInTerminal | code, debug, refactor | `implementer.agent.md` |
| **Executor** | Cmd/skill execution | read, search, execute | exec | `executor.agent.md` |
| **QA Engineer** | QA validation and script execution | read, search, listDir, runInTerminal | code, debug, correctness_check, refactor, exec | `qa-engineer.agent.md` |
| **Bug Reproducer** | Reproduces bug by running target scripts and capturing output | read, search, execute | debug | `bug-reproducer.agent.md` |
| **Architecture Analyst** | Architecture improvement analysis | read, search, listDir | refactor | `architecture-analyst.agent.md` |
| **Redundancy Analyst** | Redundancy reduction analysis | read, search, listDir | refactor | `redundancy-analyst.agent.md` |
| **Robustness Analyst** | Robustness improvement analysis | read, search, listDir | refactor | `robustness-analyst.agent.md` |
| **Complexity Analyst** | Complexity reduction analysis | read, search, listDir | refactor | `complexity-analyst.agent.md` |

## Coordinator Agents

Coordinator agents are `user-invocable: true` and orchestrate workflows by delegating to worker subagents. They declare `tools: ['agent']` and list their available subagents in `agents: [...]`.

| Agent Name | Orchestrates | Subagents | File |
|---|---|---|---|
| **Code Workflow** | Code Implementation workflow | Focus Analyst, Broad Analyst, Free Analyst, Senior Engineer, Devils Advocate, Online Researcher, Implementer, QA Engineer | `code-workflow.agent.md` |
| **Debug Workflow** | Debug workflow | Focus Analyst, Broad Analyst, Free Analyst, Senior Engineer, Devils Advocate, Online Researcher, Implementer, QA Engineer | `debug-workflow.agent.md` |
| **Refactor Workflow** | Refactor workflow | Focus Analyst, Broad Analyst, Free Analyst, Senior Engineer, Principal Engineer, Devils Advocate, Online Researcher, Implementer, QA Engineer, Architecture Analyst, Redundancy Analyst, Robustness Analyst, Complexity Analyst | `refactor-workflow.agent.md` |
| **Query Workflow** | Query/Q&A workflow | Focus Analyst, Broad Analyst, Free Analyst, Devils Advocate, Online Researcher | `query-workflow.agent.md` |
| **Correctness Workflow** | Correctness Check workflow | Focus Analyst, Broad Analyst, Free Analyst, QA Engineer, Devils Advocate, Online Researcher | `correctness-workflow.agent.md` |
