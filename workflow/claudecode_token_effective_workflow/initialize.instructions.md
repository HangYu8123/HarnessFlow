---
name: 'Fast Initialize Repo (Claude Code)'
description: 'Fast repo initialization for Claude Code: single-pass overview generation, issue/history detection, and cross-tool entry-point refresh'
---
# Create Necessary Files for Agentic Coding Workflow

This workflow generates documentation; it does not modify source code, so there is no approval gate.

[inputs]:
- input 1: target repo (optional, default to current repo)
- input 2: important files or docs to preserve (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
The main agent passes repo context to each subagent; subagents do not re-read files already summarized by the main agent (repo_info overviews do not exist yet — this workflow creates them).

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

## CREATE ONE TODO PER STEP

### Step 1 - Scan and Setup
1. Verify that the repo has been set up for Claude Code. Check whether `CLAUDE.md` exists at the repo root. If it is missing, recommend running `bash .github/HarnessFlow/cli_setup.sh` from the repo root to generate CLI entry points.
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
Generate each overview **once**. **Spawn 2 subagents in parallel.** This is the only step that spawns subagents.

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

### Step 8 - Verify Claude Code Path References
After completing all steps above, check whether path references need cleanup for Claude Code compatibility.

1. Claude Code workflows use Pack Path Resolution (filesystem-relative paths resolved per CLAUDE.md rules), not VS Code `#file:` path prefixes or `@/` workspace-relative paths.
2. The `@/.github/` path prefix and VS Code-only `#file:` references do not apply to Claude Code workflow files.
3. If any `@/` or VS Code-only `#file:` references have leaked into files under `workflow/claudecode_workflow/` or `workflow/claudecode_token_effective_workflow/`, remove them and replace them with plain Pack Path Resolution-compatible paths.

### Step 9 - Refresh Cross-Tool Entry Points
Copy the entry-point files from the pack to their standard discoverable locations so every supported tool can find its instructions after initialization.

1. Copy `.github/HarnessFlow/copilot-instructions.md` to `.github/copilot-instructions.md`.
   - In the destination copy, rewrite all `#file:` references by prepending `HarnessFlow/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:HarnessFlow/_lib/workflow_contract.md`. This is necessary because `#file:` paths resolve relative to `.github/copilot-instructions.md`.
2. Copy `.github/HarnessFlow/CLAUDE.md` to repo root `CLAUDE.md`.
3. Copy `.github/HarnessFlow/AGENTS.md` to repo root `AGENTS.md`.

For each destination file:
- Create it if absent.
- Overwrite it only if it appears to be a previously generated copy from this pack.
- If custom content is detected, warn and skip.
