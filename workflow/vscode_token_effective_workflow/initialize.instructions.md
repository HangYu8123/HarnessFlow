---
name: 'Fast Initialize Repo'
description: 'Streamlined repo initialization: single-pass overview generation with one parallel doc subagent step, main-agent issue/history detection, and entry-point refresh'
---
# Create Necessary Files for Agentic Coding Workflow

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/ (created by this workflow)
-->

**Safety: follow `_lib/safety_rules.md`.**

This workflow generates documentation; it does not modify source code, so there is no approval gate.

[inputs]:
- input 1: target repo (optional, default to current repo)
- input 2: important files or docs to preserve (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent passes repo context to each subagent; subagents do not re-read files already summarized by the main agent (repo_info overviews do not exist yet — this workflow creates them).

Subagent launch rule: Follow the Subagent Launch Contract in `#file:../../_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Scan and Setup
1. If `.vscode/settings.json` does not already contain `chat.agentFilesLocations` with `.github/HarnessFlow/agents` set to `true`, run `setup.sh` from the target repo root to configure VS Code workspace settings.
2. Scan the entire repo and keep the file listing in memory.
3. Ensure the repo_info folder exists.
4. Ensure these canonical [repo_info files] exist under repo_info, creating empty files when missing:
   - codebase_overview.md
   - scripts_overview.md
   - update_logs_auto_generated.md
   - known_issues_auto_generated.md
   - update_logs.md
   - known_issues.md
   - past_Q&A.md
   - past_Correctness_Check.md
5. Use `past_Q&A.md` for query history and `past_Correctness_Check.md` for correctness-check history; do not create alternate history filenames.

### Step 2 - File Structure
From the Step 1 scan, the main agent produces [file structure] (the directory/file tree) and validates it for completeness. No subagent is needed — the main agent already holds the listing.

### Step 3 - Documentation Generation
Generate each overview **once**. **[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]** This is the only step that spawns subagents.

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Codebase | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [inputs] + [file structure]. Decide the reading order (entry points → imports → pipeline position), read the files, and construct [codebase_overview draft]. |
| Scripts | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Folder mode | Read [inputs] + [file structure]. Go folder-by-folder and summarize each function/class in code files with their dependencies. Return [scripts overview draft]. |

### Step 4 - Synthesize and Write Codebase Overview
1. The main agent validates [codebase_overview draft] against the actual files, fixing inaccuracies.
2. Draft the [pipeline] diagram with associated scripts in each block and validate it against the code.
3. Write codebase_overview.md with the diagram and repo description.

### Step 5 - Synthesize and Write Scripts Overview
1. The main agent spot-checks [scripts overview draft] against actual files and fixes inconsistencies.
2. Write the final scripts_overview.md.

### Step 6 - Issue Scan and History
1. The main agent scans for issues directly: using scripts_overview.md and the pipeline, read the key scripts and identify architectural weaknesses, potential bugs, error-prone code, and anything preventing correct execution. Record [issues report].
2. The main agent gets the git commit history and writes update_logs_auto_generated.md.

### Step 7 - Finalize Issues
Write [issues report] to known_issues_auto_generated.md:
```md
{Problem Title}
{Problem description}
{Root causes}
{Consequences}
```

### Step 8 - Update Internal Path References (Idempotent)
After completing all steps above, check whether internal path references need updating for multi-root workspace compatibility.

1. Determine [repo folder name] - the name of the repo's root folder as it appears in the VS Code workspace.
2. Idempotency guard: before replacements, check if any `.md` file under `.github/HarnessFlow/` already contains a path with `[repo folder name]/.github/`. If so, this step already ran; skip all replacements and continue to Step 9.
3. Rename detection: if the idempotency guard did not trigger, scan `.md` files under `.github/HarnessFlow/` for any path matching `[some_prefix]/.github/HarnessFlow/` where `[some_prefix]` is not [repo folder name]. If found, replace `[old_prefix]/.github/HarnessFlow/` with `[repo folder name]/.github/HarnessFlow/`, then skip to verification.
4. Go through all `.md` files under `.github/HarnessFlow/` and replace every occurrence of `.github/HarnessFlow/` with `[repo folder name]/.github/HarnessFlow/` only in path references used by agents.
5. Verify that updated paths resolve by spot-checking key paths such as `[repo folder name]/.github/HarnessFlow/repo_info/codebase_overview.md`.

### Step 9 - Refresh Copilot Entry Point
Copy `.github/HarnessFlow/copilot-instructions.md` to `.github/copilot-instructions.md`.

In the destination copy, rewrite all `#file:` references by prepending `HarnessFlow/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:HarnessFlow/_lib/workflow_contract.md`. This is necessary because `#file:` paths resolve relative to `.github/copilot-instructions.md`.

Create `.github/copilot-instructions.md` if absent. Overwrite it only if it contains the standard marker text `"Master Orchestrator"`. If custom content is detected, warn and skip.
