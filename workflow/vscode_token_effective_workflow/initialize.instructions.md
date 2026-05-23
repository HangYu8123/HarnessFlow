---
name: 'Fast Initialize Repo'
description: 'Streamlined instructions for creating repo documentation files with maximum parallelization'
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
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must read _lib/workflow_contract.md and philosophy/philosophy.instructions.md once. The main agent passes repo context to each subagent; subagents do not re-read files already summarized by the main agent.

Subagent launch rule: Follow the Subagent Launch Contract in `#file:../../_lib/workflow_contract.md`. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Scan and Setup
1. If `.vscode/settings.json` does not already contain `chat.agentFilesLocations` with `.github/harness_coding_instructions/agents` set to `true`, run `setup.sh` from the target repo root to configure VS Code workspace settings.
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
Create **Focus Analyst** subagent (`agents/focus-analyst.agent.md`). Pass [inputs] and the repo file listing. The subagent reads the repo structure and returns [file structure]. The main agent validates [file structure] for completeness.

### Step 3 - Parallel Documentation Generation
**[PARALLEL EXECUTION - launch ALL six subagents in parallel via VS Code Copilot `agent` tool]**

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
**[PARALLEL EXECUTION - launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

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

### Step 8 - Update Internal Path References (Idempotent)
After completing all steps above, check whether internal path references need updating for multi-root workspace compatibility.

1. Determine [repo folder name] - the name of the repo's root folder as it appears in the VS Code workspace.
2. Idempotency guard: before replacements, check if any `.md` file under `.github/harness_coding_instructions/` already contains a path with `[repo folder name]/.github/`. If so, this step already ran; skip all replacements and continue to Step 9.
3. Rename detection: if the idempotency guard did not trigger, scan `.md` files under `.github/harness_coding_instructions/` for any path matching `[some_prefix]/.github/harness_coding_instructions/` where `[some_prefix]` is not [repo folder name]. If found, replace `[old_prefix]/.github/harness_coding_instructions/` with `[repo folder name]/.github/harness_coding_instructions/`, then skip to verification.
4. Go through all `.md` files under `.github/harness_coding_instructions/` and replace every occurrence of `.github/harness_coding_instructions/` with `[repo folder name]/.github/harness_coding_instructions/` only in path references used by agents.
5. Verify that updated paths resolve by spot-checking key paths such as `[repo folder name]/.github/harness_coding_instructions/repo_info/codebase_overview.md`.

### Step 9 - Refresh Copilot Entry Point
Copy `.github/harness_coding_instructions/copilot-instructions.md` to `.github/copilot-instructions.md`.

In the destination copy, rewrite all `#file:` references by prepending `harness_coding_instructions/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:harness_coding_instructions/_lib/workflow_contract.md`. This is necessary because `#file:` paths resolve relative to `.github/copilot-instructions.md`.

Create `.github/copilot-instructions.md` if absent. Overwrite it only if it contains the standard marker text `"Master Orchestrator"`. If custom content is detected, warn and skip.
