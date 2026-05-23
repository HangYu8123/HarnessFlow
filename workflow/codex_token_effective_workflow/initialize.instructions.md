---
name: 'Token-Effective Initialize Repo (Codex)'
description: 'Token-effective Codex instructions for creating repo documentation files with Codex agent workers, Codex-in-VS-Code compatibility, and sequential fallback'
---
# Create Necessary Files for Agentic Coding Workflow

<!-- Required Context Files:
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/ (created by this workflow)
-->

**Safety: follow `_lib/safety_rules.md`.**

[inputs]:
- input 1: target repo (optional, default to current repo)
- input 2: important files or docs to preserve (optional)

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow _lib/workflow_contract.md and philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent passes repo context to each subagent; subagents do not re-read files already summarized by the main agent.

Subagent launch rule: Follow the Subagent Launch Contract in `_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Scan and Setup
1. Verify that the repo has been set up for Codex. Check whether `AGENTS.md` exists at the repo root. If it is missing, recommend running `bash .github/harness_coding_instructions/cli_setup.sh` from the repo root to generate CLI entry points.
2. If using Codex in VS Code, use the same root `AGENTS.md` and installed pack files. Do not require VS Code Copilot `chat.agentFilesLocations` settings for Codex workflows.
3. Scan the entire repo and keep the file listing in memory.
4. Ensure the repo_info folder exists.
5. Ensure these canonical [repo_info files] exist under repo_info, creating empty files when missing:
   - codebase_overview.md
   - scripts_overview.md
   - update_logs_auto_generated.md
   - known_issues_auto_generated.md
   - update_logs.md
   - known_issues.md
   - past_Q&A.md
   - past_Correctness_Check.md
6. Use `past_Q&A.md` for query history and `past_Correctness_Check.md` for correctness-check history; do not create alternate history filenames.

### Step 2 - File Structure
Create **Focus Analyst** subagent (`agents/focus-analyst.agent.md`). Pass [inputs] and the repo file listing. The subagent reads the repo structure and returns [file structure]. The main agent validates [file structure] for completeness.

### Step 3 - Parallel Documentation Generation
**[PARALLEL EXECUTION - launch ALL six subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Codebase A | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Order mode | Read [inputs] + [file structure]. Follow folders in order, read files, and construct [codebase_overview 1]. |
| Codebase B | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Expand mode | Read [inputs] + [file structure]. Start from main entry points, follow imports recursively, and construct [codebase_overview 2]. |
| Codebase C | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [inputs] + [file structure]. Decide reading order, understand each file's pipeline position, and construct [codebase_overview 3]. |
| Scripts D | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Folder mode | Read [inputs] + [file structure]. Go folder-by-folder and summarize each function/class in code files with dependencies. Return [scripts overview 1]. |
| Scripts E | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Guided mode | Read [inputs] + [file structure]. Follow pipeline upstream->downstream and summarize each function/class with dependencies. Return [scripts overview 2]. |
| Scripts F | **Free Analyst** (`agents/free-analyst.agent.md`) | File mode | Read [inputs] + [file structure]. Go file-by-file freely and summarize each function/class with dependencies. Return [scripts overview 3]. |

### Step 4 - Synthesize and Write Codebase Overview
1. The main agent combines [codebase_overview 1], [codebase_overview 2], and [codebase_overview 3], rejecting redundant or incorrect parts.
2. Draft [pipeline] diagram with associated scripts in each block.
3. The main agent validates diagram consistency against actual code.
4. Finalize and write codebase_overview.md with the diagram and repo description.

### Step 5 - Synthesize and Write Scripts Overview
1. The main agent combines [scripts overview 1], [scripts overview 2], and [scripts overview 3], rejecting redundant or incorrect parts.
2. Draft scripts_overview.md.
3. The main agent spot-checks scripts_overview.md against actual files, fixes inconsistencies, and writes the final version.

### Step 6 - Parallel Remaining Files
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via Codex agent workers; if unavailable, run sequentially with the same output labels]**

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Plan | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Planning review | Read [inputs] + codebase_overview.md + scripts_overview.md. Identify architectural weaknesses, potential bugs, and error-prone code. Return [issues report]. |
| Code | **Broad Analyst** (`agents/broad-analyst.agent.md`) | Code scan | Read [inputs] + codebase_overview.md + scripts_overview.md, then read all scripts. Find anything preventing correct execution. Return [code issues report]. |

Additionally, the main agent gets git commit history and writes update_logs_auto_generated.md.

### Step 7 - Finalize Issues
The main agent combines [issues report] and [code issues report]. Write to known_issues_auto_generated.md:
```md
{Problem Title}
{Problem description}
{Root causes}
{Consequences}
```

### Step 8 - Verify Codex Path References
After completing all steps above, check whether CLI path references need cleanup.

1. Codex workflows use filesystem-relative or pack-relative paths, not VS Code `@/` path prefixes.
2. The `@/.github/` to `@/[repo folder name]/.github/` rewrite is a VS Code Copilot-only concern and does not apply to Codex workflow files, including Codex running in VS Code.
3. If any `@/` or VS Code-only `#file:` references have leaked into files under `workflow/codex_workflow/` or `workflow/codex_token_effective_workflow/`, remove them and replace them with relative paths.

### Step 9 - Refresh Cross-Tool Entry Points
Copy the entry-point files from the pack to their standard discoverable locations so every supported tool can find its instructions after initialization.

1. Copy `.github/harness_coding_instructions/copilot-instructions.md` to `.github/copilot-instructions.md`.
   - In the destination copy, rewrite all `#file:` references by prepending `harness_coding_instructions/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:harness_coding_instructions/_lib/workflow_contract.md`. This is necessary because `#file:` paths resolve relative to `.github/copilot-instructions.md`.
2. Copy `.github/harness_coding_instructions/CLAUDE.md` to repo root `CLAUDE.md`.
3. Copy `.github/harness_coding_instructions/AGENTS.md` to repo root `AGENTS.md`.

For each destination file:
- Create it if absent.
- Overwrite it only if it appears to be a previously generated copy from this pack.
- If custom content is detected, warn and skip.
