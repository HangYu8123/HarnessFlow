---
name: 'Fast Initialize Repo'
description: 'Streamlined instructions for creating repo documentation files with maximum parallelization'
---
# Create Necessary Files for Agentic Coding Workflow

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/ (created by this workflow)
-->

**DO NOT COMMIT TO GITHUB | DO NOT WRITE SPAM FILES | DO NOT USE SUDO**

**Read this file fully and follow each step.**
Before doing any workflow-specific work, the main agent must read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before proceeding.
Every subagent created by this workflow must also read and follow #file:../../_lib/workflow_contract.md and #file:../../philosophy/philosophy.instructions.md before reading the repo or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in #file:../../_lib/workflow_contract.md.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name using VS Code Copilot's native `agent` tool. Coordinator agents declare `tools: ['agent']` and `agents: [...]` to orchestrate subagent invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 — Scan & Setup
1. If `.vscode/settings.json` does not already contain `chat.agentFilesLocations` with `.github/harness_coding_instructions/agents` set to `true`, run `setup.sh` from the target repo root to configure VS Code workspace settings.
2. Scan entire repo, keep file listing in memory.
3. Ensure repo_info folder exists (create if not).
3. Ensure these canonical [repo_info files] exist under repo_info (create empty if missing):
   - codebase_overview.md
   - scripts_overview.md
   - update_logs_auto_generated.md
   - known_issues_auto_generated.md
   - update_logs.md
   - known_issues.md
   - past_Q&A.md
   - past_Correctness_Check.md
4. Use `past_Q&A.md` for query history and `past_Correctness_Check.md` for correctness-check history; do not create alternate history filenames.

### Step 2 — File Structure
Create subagent to read all repo files and produce [file structure]. Main agent validates [file structure] completeness.

### Step 3 — Parallel Documentation Generation
**[PARALLEL EXECUTION — launch ALL SIX subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Role | Task |
|----------|------|------|
| Codebase A | Order mode | Follow [file structure] folder-by-folder, read all files. Construct [codebase_overview 1]. |
| Codebase B | Expand mode | Start from main entry point, follow imports recursively. Construct [codebase_overview 2]. |
| Codebase C | Free mode | Decide own reading order. Understand each file's position in [pipeline]. Construct [codebase_overview 3]. |
| Scripts D | Folder mode | Go folder-by-folder. For each code file: summarize each function/class (name, params, outputs + one sentence functionality). List dependencies. Return [scripts overview 1]. |
| Scripts E | Guided mode | Follow [pipeline] upstream->downstream. For each code file: summarize each function/class (name, params, outputs + one sentence functionality). List dependencies. Return [scripts overview 2]. |
| Scripts F | File mode | Go file-by-file freely. For each code file: summarize each function/class (name, params, outputs + one sentence functionality). List dependencies. Return [scripts overview 3]. |

### Step 4 — Synthesize & Write Codebase Overview
1. Combine [codebase_overview 1-3]. Reject redundant/incorrect parts.
2. Draft [pipeline] diagram with associated scripts in each block.
3. Create subagent to validate diagram consistency against actual code.
4. Finalize and write to codebase_overview.md (diagram + repo description).

### Step 5 — Synthesize & Write Scripts Overview
1. Combine [scripts overview 1-3]. Reject redundant/incorrect parts.
2. Draft final scripts_overview.md.
3. Create subagent to validate: read scripts_overview.md, spot-check against actual files. Report inconsistencies.
4. Fix inconsistencies and write final version.

### Step 6 — Parallel Remaining Files
**[PARALLEL EXECUTION — launch BOTH subagents in parallel via VS Code Copilot `agent` tool]**

| Subagent | Role | Task |
|----------|------|------|
| Plan | Plan agent | Read codebase_overview.md + scripts_overview.md. Identify architectural weaknesses, potential bugs, error-prone code. Return [issues report]. |
| Code | Code agent | Read codebase_overview.md + scripts_overview.md, then read all scripts. Find anything preventing 100% correct execution. Return [code issues report]. |

Additionally (no subagent needed): get git commit history → write to update_logs_auto_generated.md.

### Step 7 — Finalize Issues
Combine [issues report] + [code issues report]. Write to known_issues_auto_generated.md:
```
{Problem Title}
{Problem description}
{Root causes}
{Consequences}
```

### Step 8 — Update Internal Path References (Idempotent)
After completing all steps above, check whether internal path references need updating for multi-root workspace compatibility.

1. Determine `[repo folder name]` — the name of the repo's root folder as it appears in the VS Code workspace (e.g., if the repo lives at `/workspace/my_project/`, then `[repo folder name]` is `my_project`).
2. **Idempotency guard**: Before performing any replacements, check if any `.md` file under `.github/harness_coding_instructions/` already contains a path with `[repo folder name]/.github/` (e.g., `my_project/.github/`). If so, this step has already been run — **skip all replacements and continue to Step 9**.
3. **Rename detection**: If the idempotency guard did NOT trigger, scan `.md` files under `.github/harness_coding_instructions/` for any path matching the pattern `[some_prefix]/.github/harness_coding_instructions/` where `[some_prefix]` is NOT `[repo folder name]`. If found, the repo was previously initialized under a different folder name. In this case, replace all occurrences of `[old_prefix]/.github/harness_coding_instructions/` with `[repo folder name]/.github/harness_coding_instructions/` (a rename-aware replacement), then **skip to step 5** (verification).
4. Go through **all `.md` files** under `.github/harness_coding_instructions/` and replace every occurrence of `.github/harness_coding_instructions/` with `[repo folder name]/.github/harness_coding_instructions/` **only in path references used by agents**.
5. Verify that all updated paths now correctly resolve to the right files in the workspace by spot-checking a few key paths (e.g., `[repo folder name]/.github/harness_coding_instructions/repo_info/codebase_overview.md`).

### Step 9 — Copy Entry-Point Files for Cross-Tool Compatibility
Copy entry-point files from the pack to their standard discoverable locations so the repo works with all supported tools after any single initialization.

1. Copy `.github/harness_coding_instructions/copilot-instructions.md` → `.github/copilot-instructions.md` (standard GitHub Copilot discovery path).
   - In the destination copy, rewrite all `#file:` references by prepending `harness_coding_instructions/` to their paths (e.g., `#file:_lib/workflow_contract.md` → `#file:harness_coding_instructions/_lib/workflow_contract.md`). This is necessary because `#file:` paths resolve relative to the file's directory.
2. Copy `.github/harness_coding_instructions/CLAUDE.md` → repo root `CLAUDE.md` (Claude Code CLI auto-discovers this at the repo root).
3. Copy `.github/harness_coding_instructions/AGENTS.md` → repo root `AGENTS.md` (Codex CLI auto-discovers this at the repo root).

For each file: create if absent; overwrite if it contains the same marker text (e.g., `"Master Orchestrator — Instruction Router"`); warn and skip if custom content is detected.
