<div align="center">

<img src="harnessflow.png" alt="HarnessFlow" width="100%">

# HarnessFlow

**A portable AI-coding workflow pack for Claude Code CLI, Codex CLI, and VS Code + Copilot.**

Drop it into any repository and your AI coding assistant stops one-shotting changes. Instead it classifies your request, routes it to a real workflow, fans out parallel analysis agents, challenges its own plan, validates the result with QA, and records what it learned to persistent repo memory.

[What it does](#what-it-does) · [Install](#install) · [Get started](#get-started) · [Platforms](#platforms) · [Architecture](#architecture)

**English** | **简体中文**

</div>

## What It Does

HarnessFlow is a **Markdown instruction pack** — there is no runtime, no `npm install`, and no build step. You copy the files into a repository and any compatible AI coding assistant gains a structured, multi-agent workflow for every request:

- **Classifies** your prompt into one of 8 request types and loads the matching workflow file.
- **Analyzes in parallel** — Focus, Broad, and Free analyst subagents read the codebase from different angles, then a Senior Engineer synthesizes one plan.
- **Challenges itself** — a Devil's Advocate pass stress-tests the plan for regressions and bad assumptions before any code is written.
- **Validates** — a QA Engineer checks the implementation; an opt-in approval gate lets you sign off on the plan first.
- **Remembers** — results are written to `repo_info/` so later requests start with real context instead of re-deriving it.
- **Two speeds** — every workflow ships in a `general` (thorough) and a `fast` (token-efficient) variant.

### Works with your AI assistant

Every supported platform is a first-class citizen — pick the one you already use:

| Platform | Entry point (generated during setup) |
|---|---|
| Claude Code CLI | root `CLAUDE.md` |
| Codex CLI / Codex in VS Code | root `AGENTS.md` |
| VS Code + GitHub Copilot | `.github/copilot-instructions.md` |
| Aider / other LLMs | follow any workflow file manually (no subagent orchestration) |

### What you can ask for

| Category | What it handles |
|---|---|
| **Code** | Implement, add, or build new functionality |
| **Refactor** | Restructure, reduce redundancy, improve architecture |
| **Debug** | Diagnose and fix errors, crashes, and failing tests |
| **Query** | Explain, document, or answer questions about the codebase |
| **Correctness Check** | Test, verify, validate, or audit existing behavior |
| **Exec** | Run a command or skill and capture the results |
| **PR** | Break a large branch into reviewable, stacked PRs |
| **Initialize** | Bootstrap repo memory for first-time setup |

Each category is backed by per-platform workflow files under `workflow/`, in both `general` and `fast` modes, and a matching fill-in prompt in `request_template/`.

## Install

> **Prerequisites:** `git` and `bash`. For the CLI platforms, install the `claude` and/or `codex` CLI first.

### 1. Get the pack into your repo

```bash
# Clone HarnessFlow wherever you like to keep tools
git clone https://github.com/HangYu8123/HarnessFlow.git

# From your target repo, copy the pack into .github/HarnessFlow/
cd /path/to/your-repo
mkdir -p .github/HarnessFlow
rsync -a --exclude .git /path/to/HarnessFlow/ .github/HarnessFlow/
```

Replace `/path/to/HarnessFlow/` with wherever you cloned it. No `rsync`? Use `cp -r /path/to/HarnessFlow/. .github/HarnessFlow/` and then delete the copied `.github/HarnessFlow/.git`. The pack must end up at **`.github/HarnessFlow/`** — both setup scripts validate this path.

### 2. Run the setup script for your platform

```bash
# Claude Code CLI / Codex CLI / Codex in VS Code
bash .github/HarnessFlow/cli_setup.sh

# VS Code + GitHub Copilot
bash .github/HarnessFlow/setup.sh
```

`cli_setup.sh` generates the root `CLAUDE.md` / `AGENTS.md` routers and ensures the `repo_info/` memory files exist. `setup.sh` writes `.vscode/settings.json` and `.github/copilot-instructions.md`. Existing custom files are never overwritten.

## Get Started

### Step 1 — Initialize repo memory (once per repo)

This populates `repo_info/` with an overview of your codebase that every later request reuses.

**Claude Code CLI** — from your repo root, run `claude`, then type:
```text
Initialize this repo.
```

**Codex CLI** — run `codex`, then type:
```text
Initialize this repo.
```

**VS Code + Copilot** — in the Copilot Chat panel:
```text
Following the instructions in @/.github/HarnessFlow/workflow/vscode_workflow/initialize.instructions.md, initialize this repo.
```

### Step 2 — Just ask

Once initialized, describe what you want in plain language — the router picks the workflow automatically:
```text
Add input validation to the user registration endpoint.
```
```text
Why does the nightly export job drop the last row? Debug it.
```

### Optional — force fast mode or use a template

Prepend `mode: fast` for the token-efficient path:
```text
mode: fast

Refactor the database layer to remove the duplicate query builders.
```

Or copy a ready-made prompt from `request_template/` (for example `code_request_template.md` or `pr_request_template.md`), fill in your task, and paste it in. Templates let you force a specific workflow and mode.

## Platforms

| Environment | Entry point | Workflow directory |
|---|---|---|
| Claude Code CLI | root `CLAUDE.md` | `workflow/claudecode_workflow/` |
| Claude Code CLI (fast) | `CLAUDE.md` + `mode: fast` | `workflow/claudecode_token_effective_workflow/` |
| Codex CLI / Codex in VS Code | root `AGENTS.md` | `workflow/codex_workflow/` |
| Codex CLI (fast) | `AGENTS.md` + `mode: fast` | `workflow/codex_token_effective_workflow/` |
| VS Code + Copilot | `.github/copilot-instructions.md` | `workflow/vscode_workflow/` |
| VS Code + Copilot (fast) | request templates + `mode: fast` | `workflow/vscode_token_effective_workflow/` |
| Aider / generic LLMs | manual file references | any workflow file |

## Architecture

The source repo stores the pack at the repo root. The installed layout expected by the scripts and CLI entry points is:

```text
<target-repo>/
|-- .github/
|   |-- copilot-instructions.md
|   `-- HarnessFlow/
|       |-- AGENTS.md
|       |-- CLAUDE.md
|       |-- copilot-instructions.md
|       |-- setup.sh
|       |-- cli_setup.sh
|       |-- _lib/
|       |-- philosophy/
|       |-- workflow/
|       |-- agents/
|       |-- request_template/
|       |-- skills/
|       `-- repo_info/
|-- AGENTS.md
|-- CLAUDE.md
`-- .claude/
    `-- rules/
```

`AGENTS.md` and `CLAUDE.md` at the target repo root are generated by `cli_setup.sh`. `.github/copilot-instructions.md` is generated by `setup.sh` or `cli_setup.sh`.

## What Is In This Repo

| Path | Purpose |
|---|---|
| `copilot-instructions.md` | VS Code Copilot router template. |
| `CLAUDE.md` | Claude Code CLI router template copied to the target repo root by `cli_setup.sh`. |
| `AGENTS.md` | Codex CLI router template copied to the target repo root by `cli_setup.sh`. |
| `_lib/` | Shared workflow contract, safety rules, and approval-gate rules. |
| `philosophy/` | Shared behavioral guidance used by workflows and subagents. |
| `workflow/` | Tool-specific workflow instruction families. |
| `agents/` | Custom agent definitions plus `agents/INDEX.md`. |
| `request_template/` | Fill-in request templates, including `mode: general` and `mode: fast` selection. |
| `skills/` | Skill definitions, including PR breakdown and Claude-native post-implementation skill orchestration. |
| `.claude/rules/` | Claude Code path-scoped rules copied to target repos by `cli_setup.sh`. |
| `setup.sh` | Configures VS Code workspace settings and generated Copilot instructions in a target repo. |
| `cli_setup.sh` | Generates CLI entry points and ensures target `repo_info/` files exist. |
| `repo_info/` | Local/generated repo memory files. This directory is ignored by git in this source repo. |

## Workflow Families

Each workflow family currently contains these instruction files:

```text
code.instructions.md
correctness_check.instructions.md
debug.instructions.md
exec.instructions.md
initialize.instructions.md
pr.instructions.md
query.instructions.md
refactor.instructions.md
```

The six workflow families are:

| Directory | Intended use |
|---|---|
| `workflow/vscode_workflow/` | Full VS Code Copilot workflows. |
| `workflow/vscode_token_effective_workflow/` | Streamlined VS Code workflows selected by request templates with `mode: fast`. |
| `workflow/claudecode_workflow/` | Claude Code CLI workflows. |
| `workflow/claudecode_token_effective_workflow/` | Streamlined Claude Code CLI workflows selected with `mode: fast`. |
| `workflow/codex_workflow/` | Codex CLI workflows. |
| `workflow/codex_token_effective_workflow/` | Streamlined Codex workflows selected by `mode: fast` under Codex CLI or Codex in VS Code. |

The root routers classify all eight categories: code implementation, refactor, debug, query, correctness check, exec, PR creation, and initialize. Each maps to a `*.instructions.md` file present in every workflow family, with a matching fill-in prompt in `request_template/`.

## Setup Scripts

### `setup.sh`

Run from the target repo root after copying the pack to `.github/HarnessFlow/`.

It validates that the pack is present, then writes or updates `.vscode/settings.json` with:

```json
{
  "chat.instructionsFilesLocations": {
    ".github/HarnessFlow": true,
    ".claude/rules": true
  },
  "chat.agentFilesLocations": {
    ".github/HarnessFlow/agents": true
  },
  "chat.includeReferencedInstructions": true
}
```

It also creates or refreshes `.github/copilot-instructions.md` when that file is generated by this pack. Existing custom Copilot instructions are left unchanged.

When merging an existing VS Code settings file, the script tries `python3`, then `node`, then `jq`. If none are available, it prints manual settings to add.

### `cli_setup.sh`

Run from the target repo root after copying the pack to `.github/HarnessFlow/`.

It:

- Detects whether `claude` or `codex` is on `PATH`.
- Creates or refreshes root `CLAUDE.md` and `AGENTS.md` when they are generated by this pack.
- Creates or refreshes `.github/copilot-instructions.md` when appropriate.
- Copies `.claude/rules/*.md` into the target repo.
- Ensures the eight canonical `repo_info/` files exist under the installed pack.

Existing custom files are not overwritten unless they contain this pack's generated markers.

## Request Templates

`request_template/` contains user-facing prompt templates:

```text
code_request_template.md
correctness_check_request_template.md
debug_request_template.md
exec_request_template.md
initialize_request_template.md
pr_request_template.md
query_request_template.md
refactor_request_template.md
```

Templates ship with the token-efficient fast mode prefilled:

```text
mode: fast
```

Switch to the full general pipeline with:

```text
mode: general
```

For VS Code Copilot, `general` selects `workflow/vscode_workflow/` and `fast` selects `workflow/vscode_token_effective_workflow/`.
For Codex CLI or Codex in VS Code, `general` selects `workflow/codex_workflow/` and `fast` selects `workflow/codex_token_effective_workflow/`. The templates use `@/.github/HarnessFlow/...` paths for VS Code Copilot and filesystem paths for Codex.

## Agents And Skills

`agents/` defines **5 coordinator agents** and **15 worker agents**. Coordinator agents include Code Workflow, Debug Workflow, Refactor Workflow, Query Workflow, and Correctness Workflow. Worker agents include Focus Analyst, Broad Analyst, Free Analyst, Senior Engineer, Principal Engineer, Devils Advocate, Online Researcher, Implementer, Executor, QA Engineer, Bug Reproducer, and the refactor specialists Architecture, Redundancy, Robustness, and Complexity Analyst.

See `agents/INDEX.md` for the complete registry.

`skills/` currently contains:

- `breakdown-pr`: analyzes a large branch or PR and proposes a stacked PR breakdown.
- `claude-native-skills-subagents`: Claude Code-only post-implementation orchestration for native skills such as `/simplify`, `/code-review`, `/batch`, and `/claude-api`.

## Repo Memory

Workflows use `repo_info/` as persistent repo memory. `cli_setup.sh` ensures these canonical files exist in the installed pack:

```text
codebase_overview.md
known_issues.md
known_issues_auto_generated.md
past_Correctness_Check.md
past_Q&A.md
scripts_overview.md
update_logs.md
update_logs_auto_generated.md
```

In this source repo, `repo_info/` is ignored by git. In a target repo, initialize or refresh it for that specific codebase before relying on later workflows.

## Path Rules

- In this source repo, paths are root-relative, for example `workflow/codex_workflow/code.instructions.md` or `workflow/codex_token_effective_workflow/code.instructions.md`.
- In an installed target repo, the pack lives under `.github/HarnessFlow/`.
- VS Code workflow prompts may use `@/.github/HarnessFlow/...`.
- CLI entry points use filesystem-relative paths such as `.github/HarnessFlow/workflow/codex_workflow/code.instructions.md` and `.github/HarnessFlow/workflow/codex_token_effective_workflow/code.instructions.md`.
- Do not add VS Code `@/` prefixes to CLI workflow files.

## Safety Rules

The shared workflow contract and safety rules require:

- Do not try to commit changes to GitHub.
- Do not write spam files into the repo.
- Do not use `sudo`.
- For code, debug, and refactor workflows, print the finalized plan before implementation. If the user requested no code changes, stop after the plan; otherwise continue.

Keep destructive auto-approval disabled for any command that can delete or overwrite user files.

## Limitations

- This repo is an instruction pack, not an application. There is no package manifest, runtime, build command, or formal test suite.
- The setup scripts are Bash scripts.
- CLI subagent behavior depends on the capabilities of the active CLI tool and model parity support.
- Claude-native skill steps only apply in Claude Code environments.
- The source repo ignores `.github/` and `repo_info/`, so generated target-repo files are not tracked here.
- Root `AGENTS.md` and `CLAUDE.md` in this source repo are templates for installed target repos; their `.github/HarnessFlow/...` paths are expected to resolve after installation.
