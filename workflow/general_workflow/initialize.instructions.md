---
name: 'Initialize Repo'
description: 'Instructions for creating necessary repo_info memory files to guide the entire agentic coding workflow for a new or existing repo'
---
# create necessary files for guiding the entire agentic coding workflow

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/absolutize_pack_paths.md
  - _lib/reinitialize.md
  - repo_info/ (created by this workflow)
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Preamble — canonical in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).** Platform adaptation (this file serves Claude Code, Codex, and VS Code Copilot), Pack Path Resolution, subagent invocation, repo-context handoff (**[repo context digest]** / **[full repo context]**), and the two spawn dials (`subagent_model` + `subagent_effort` / `online_researcher_effort`) with the returned-result check are governed by its §Pack Path Resolution · §Subagent Invocation · §Context Passing for Subagents · §Subagent Launch Contract — this file deliberately does not restate them.

[parameters]:

Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before reading the repo or performing task-specific work.

## Procedure 1: Run Setup & Scan Repo
First, verify that the repo has been set up for your tool, then scan the repo.
- **If the main agent is Claude Code:** check that `CLAUDE.md` exists at the repo root; if it is missing, recommend running `bash .github/HarnessFlow/cli_setup.sh` from the repo root to generate entry-point files.
- **If the main agent is Codex:** check that `AGENTS.md` exists at the repo root; if it is missing, recommend running `bash .github/HarnessFlow/cli_setup.sh` from the repo root to generate entry-point files.
- **If the main agent is VS Code Copilot:** if `.vscode/settings.json` does not already contain `chat.agentFilesLocations` with `.github/HarnessFlow/agents` set to `true`, run `setup.sh` from the target repo root to configure VS Code workspace settings (agent discovery, instruction file locations, and `chat.includeReferencedInstructions`).

Then go through the entire repo, keep what files exist in this repo in the memory.

## Procedure 2: Verify repo_info Files
The `repo_info/` folder must be at the same level as `request_template/` and `workflow/` (i.e., all are siblings under the pack root `.github/HarnessFlow/`).
Then, check the existence of the following [repo_info files] under the repo_info folder:
1. codebase_overview.md
2. scripts_overview.md
3. update_logs_auto_generated.md
4. known_issues_auto_generated.md
5. update_logs.md
6. known_issues.md
7. past_Q&A.md
8. past_Correctness_Check.md
If the repo_info folder does not exist, create it. Then ensure [repo_info files] exist; create any missing ones as empty files.
These are the canonical repo memory files. Use `past_Q&A.md` for query history and `past_Correctness_Check.md` for correctness-check history; do not create alternate history filenames.
Then determine [init mode] per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Mode Detection: an overview file that already has non-empty content is in **re-initialize** mode (validate + diff-update, never regenerate from scratch); a missing or empty one is **fresh**.

## Procedure 3: Create File Structure
Create a subagent, read through all the files in the repo, understand them, and create a [file structure] of the repo. The subagent must feed [file structure] back to the main agent. The main agent validates [file structure] and makes sure [file structure] includes all files and folders in the repo.

## Procedure 4: Create/Update Files
create/update the files in Procedure 2 with the **following specifications**.
under the repo_info folder.

**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** — §4.1 (codebase_overview.md) and §4.2 (scripts_overview.md) are independent. Launch both section workflows in parallel.

**Re-initialization** (per [`_lib/reinitialize.md`](../../_lib/reinitialize.md)): when an overview is in re-initialize mode, its section (§4.1 / §4.2) runs as a validate-and-diff update of the existing file rather than from-scratch regeneration — each subagent launched in §4.1 step 1 and §4.2 step 1 additionally receives the existing overview content and validates it per §Validate Existing Claims, returning its overview draft plus a [validation & diff report]; the main agent applies §Update With Diff at each overview's write step (§4.1 step 7, §4.2 step 2) — preserve confirmed content, never blank-and-rewrite. After §4.1 and §4.2 are both written, run §Repo-Wide Revalidation before §4.3.

### 4.1 codebase_overview.md:
If the file does not exist, create an empty file.
If the file exists, the main agent must read through the file and keep it inside the memory, and set [pipeline] to be the diagram pipeline in the file.
Then:
1. **[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]**:
a. create a subagent (code agent, order mode), follow [file structure] in order, go through all files by folders, understand what each file is, how they work in the repo, what they do, and their relationships/dependencies to other scripts. For each file that has been read by the agent, append it into [read file list 1]. Then based on the results of reading and understanding all the files, construct [codebase_overview 1], and return [codebase_overview 1] and [read file list 1] to the main agent.
b. create a subagent (code agent, expand mode), follow [file structure], based on file name, decide what file to go first (usually main.py or any main scripts of the repo), and start reading and understanding the script. then go through the imported files one by one, for each imported file, read through the file and understand it, then go through the imports of the imported file, and so on, which is to understand script dependencies and codebase structures. every time, when it finishes reading a file, add that file into [read files]. Once the subagent finishes reading, validate if there are any files that have not been read by comparing [read files] with [file structure]. For each file that has been read by the agent, append it into [read file list 2]. If there are files that have not been read, repeat the previous steps and read those files until all files have been read. Then based on the results of reading and understanding all the files, construct [codebase_overview 2], and return [codebase_overview 2] and [read file list 2] to the main agent.
c. create a subagent (code agent, free mode), follow [file structure], the agent must decide what order to use for all files and how to understand what each file is, how they work in the repo, and what their positions are in [pipeline]. Then based on the results of reading and understanding all the files, construct [codebase_overview 3], for each file that has been read by the agent, append it into [read file list 3],  and return [codebase_overview 3] and [read file list 3]to the main agent.
1.5 if [read file list 1], [read file list 2], and [read file list 3] are not identical, the main agent check the additional files, read them, if they are not in [file structure], add them to [file structure] as well. 
2. based on [codebase_overview 1], [codebase_overview 2], and [codebase_overview 3], the main agent must combine the advantages of three codebase_overviews, reject the redundant or incorrect parts of each codebase_overview, and draft final [codebase_overview]. The main agent must also check the consistency of final [codebase_overview] with the pipeline diagram in the original codebase_overview.md (if it exists); if there are inconsistencies, update the pipeline diagram accordingly.
3. the main agent update [pipeline] accordingly.  
4. the main agent convert [pipeline] into a code diagram. In each block in the diagram, the associated scripts must also be mentioned.
5. Finally, the main agent create a codebase_overview.md based on the code diagram and [codebase_overview], keeping the file within its ≤4k-token budget per [`_lib/repo_map.md`](../../_lib/repo_map.md). So the codebase_overview.md will have: 
   a. a very brief repo overview; 
   b. a brief introduction of what the repo is and what is the purpose of the repo;
   c. Repository layout;
   d. Components of the repo, and components dependency map
6. On re-initialization, write per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Update With Diff — targeted edits preserving confirmed content, never blank-and-rewrite. In addition, read the update_log.md, based on update logs, re-infer and re-understand the purpose of the repo. 

### 4.2 scripts_overview.md
If the file does not exist, create an empty file.
Then:
Generate the file as a **ranked repo map** per [`_lib/repo_map.md`](../../_lib/repo_map.md) (budget ≤4k tokens; 8k for super-large repos):
1. **[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]**:
a. create a subagent (code agent, symbol mode), pass [file structure] and [`_lib/repo_map.md`](../../_lib/repo_map.md). the subagent extracts, per source file, its definitions (functions, classes, methods, exported constants) and the identifiers it references, using the best extractor the environment provides (tree-sitter or universal-ctags when installed, else language-aware grep/reading — approximate extraction is acceptable, never install new tooling). then report [symbol inventory] (per-file def/ref lists) to the main agent.
b. create a subagent (code agent, guided mode), pass [file structure] and ask the agent to read through scripts_overview.md and codebase_overview.md, understand [pipeline], then read files according to [pipeline] (from upstream to downstream). for each code file, write one high-level summary line, its key definition signatures (compact snippet lines), and a one-line dependency note. then report [scripts overview draft] to the main agent.
2. the main agent ranks the files/symbols in [symbol inventory] by reference-graph centrality per [`_lib/repo_map.md`](../../_lib/repo_map.md) (files referenced from many distinct files rank higher), merges [scripts overview draft]'s summaries onto the ranked order, binary-searches the ranked list for the largest prefix that fits the token budget (below-cut files get at most a one-line index entry), and writes the result into scripts_overview.md.
3. create a subagent (review agent), the subagent reads scripts_overview.md and codebase_overview.md, follows scripts_overview.md to go through all scripts and files one by one, first reads the original code/text, then validates the summarization of scripts_overview.md and codebase_overview.md. Report inconsistency back to the main agent.
4. update the scripts_overview.md and codebase_overview.md. 

### 4.3 known_issues_auto_generated.md:
if the file does not exist, create an empty file (Procedure 2 normally has already created it).
then:

**IMPORTANT: §4.3 depends on §4.1 and §4.2 being complete. Do NOT start §4.3 until codebase_overview.md and scripts_overview.md have been written to disk — and, on a re-initialization run, until the §Repo-Wide Revalidation pass ([`_lib/reinitialize.md`](../../_lib/reinitialize.md)) has completed.**

**[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** — launch steps 1 and 2 in parallel. The main agent may pass the contents of codebase_overview.md and scripts_overview.md inline to reduce redundant file reads. On re-initialization, also pass both subagents the existing known_issues_auto_generated.md entries; each subagent additionally validates each entry against the current code per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Merge Known Issues and reports which entries are resolved, still valid, or obsolete.
1. create a subagent (plan agent), go through codebase_overview.md and scripts_overview.md, point out the weaknesses of the code architecture and all possible issues. report back to the main agent.
2. create a subagent (code agent), go through codebase_overview.md and scripts_overview.md, and then go through all scripts one by one, find any potential issues or code that could lead to problems, errors, and bugs. find anything that could affect the code being fully correct. find anything that prevents code from running correctly or functioning as expected. report back to main agent.
3. the main agent uses the information from steps 1 and 2 to perform a lightweight correctness assessment of the repo — identifying potential problems, issues, and weaknesses of the codebase. Do NOT invoke the full correctness_check workflow (`workflow/general_workflow/correctness_check.instructions.md`) here, as repo_info files may not all be finalized yet. Instead, use the subagent reports from steps 1 and 2, combined with the main agent's own reading of the codebase, to produce the assessment.
4. the main agent summarizes the reviews from step 1, step 2, and step 3, based on the information it has, and uses its best ability to combine the reviews with only correct and fair parts.
5. write the contents to known_issues_auto_generated.md. On re-initialization, merge per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Merge Known Issues — drop resolved entries, keep valid ones, append new findings — instead of overwriting:
{Problem Title (very high level summarization)}
{Problem description ( a short description of the problem)}
{Root causes (for example, what code/function causes the problem)}
{Consequences (what issues can this problem lead to)}.

### 4.4 update_logs_auto_generated.md
Get the git commit history, and create a file with the git commit history logs. Do not add any interpretations; be faithful to the original contents.

### 4.5 known_issues.md:
if the file exists, do nothing.
if the file does not exist, create an empty file.

### 4.6 update_logs.md:
if the file exists, do nothing.
if the file does not exist, create an empty file.

### 4.7 past_Q&A.md:
if the file exists, do nothing.
if the file does not exist, create an empty file.

### 4.8 past_Correctness_Check.md:
if the file exists, do nothing.
if the file does not exist, create an empty file.

## Procedure 5: Update Internal Path References (Idempotent)
After completing all file creation in Procedure 4, check whether internal path references need updating for multi-root workspace compatibility.

**For CLI agents (Claude Code, Codex):** CLI workflows use Pack Path Resolution relative paths (no `@/` prefixes). The `@/.github/` → `@/[repo folder name]/.github/` rewrite is a VS Code-only concern. If any `@/` paths have leaked into files under `workflow/general_workflow/`, `workflow/token_effective_workflow/`, or `workflow/skill_workflow/`, remove them and replace with relative paths; otherwise this is a no-op.

**For VS Code Copilot (multi-root workspaces):** perform the full idempotent rewrite.
1. Determine `[repo folder name]` — the name of the repo's root folder as it appears in the VS Code workspace (e.g., if the repo lives at `/workspace/my_project/`, then `[repo folder name]` is `my_project`).
2. **Idempotency guard**: Before performing any replacements, check if any `.md` file under `.github/HarnessFlow/` already contains a path with `[repo folder name]/.github/` (e.g., `my_project/.github/`). If so, Procedure 5 has already been run — **skip all replacements and continue to Procedure 6**.
3. **Rename detection**: If the idempotency guard did NOT trigger, scan `.md` files under `.github/HarnessFlow/` for any path matching the pattern `[some_prefix]/.github/HarnessFlow/` where `[some_prefix]` is NOT `[repo folder name]`. If found, the repo was previously initialized under a different folder name. In this case, replace all occurrences of `[old_prefix]/.github/HarnessFlow/` with `[repo folder name]/.github/HarnessFlow/` (a rename-aware replacement), then **skip to step 5** (verification).
4. Go through **all `.md` files** under `.github/HarnessFlow/` (including subfolders: `workflow/general_workflow/`, `workflow/token_effective_workflow/`, `workflow/skill_workflow/`, `request_template/`, `repo_info/`, `_lib/`, and root level) and replace every occurrence of `.github/HarnessFlow/` with `[repo folder name]/.github/HarnessFlow/` **only in path references used by agents** (e.g., in `[key md files]` path descriptions, not in prose descriptions of the pack).
5. Verify that all updated paths now correctly resolve to the right files in the workspace by spot-checking a few key paths (e.g., `[repo folder name]/.github/HarnessFlow/repo_info/codebase_overview.md`).

## Procedure 6: Absolutize Claude Code & Codex Pack Paths (Idempotent)

After completing Procedure 5, follow the canonical procedure in [`_lib/absolutize_pack_paths.md`](../../_lib/absolutize_pack_paths.md): determine `[PACK_ROOT_ABS]`, record it in the git-ignored `.pack_root`, rewrite the in-scope Claude Code/Codex references, and regenerate the `harness_gui.html` template snapshots via `sync_gui_templates.py`.
If its idempotency guard triggers (this pack is already absolutized), skip to Procedure 7.

## Procedure 7: Copy Entry-Point Files for Cross-Tool Compatibility
Copy the entry-point files from the pack to their standard discoverable locations. This ensures each tool can auto-discover its instructions without additional configuration, regardless of which tool was used to initialize.

1. Copy `.github/HarnessFlow/copilot-instructions.md` → `.github/copilot-instructions.md` (standard GitHub Copilot discovery path).
   - **Important**: In the destination copy, rewrite all `#file:` references by prepending `HarnessFlow/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:HarnessFlow/_lib/workflow_contract.md`, and `#file:workflow/general_workflow/code.instructions.md` becomes `#file:HarnessFlow/workflow/general_workflow/code.instructions.md`. This is necessary because `#file:` paths resolve relative to the file's directory — when the file moves from `.github/HarnessFlow/` to `.github/`, the paths must be adjusted accordingly.
2. Copy `.github/HarnessFlow/CLAUDE.md` → repo root `CLAUDE.md` (Claude Code CLI auto-discovers this at the repo root).
3. Copy `.github/HarnessFlow/AGENTS.md` → repo root `AGENTS.md` (Codex CLI auto-discovers this at the repo root).
4. Copy the native worker definitions: `.github/HarnessFlow/.claude/agents/*.md` → repo root `.claude/agents/` (Claude Code), and `.github/HarnessFlow/.codex/agents/*.toml` → repo root `.codex/agents/` (Codex). These let workflows spawn workers by agent type instead of by inline prompt. They are generated from `agents/*.agent.md`; if any source `.agent.md` was changed during this initialization, first re-run `python3 sync_agent_definitions.py` from the pack root, then copy.

For each file:
- If the destination file does **not** exist, copy it.
- If the destination file **already exists** and appears to be a previously generated copy (contains the same header/marker text as the source, e.g., `"Master Orchestrator"` for copilot-instructions.md), overwrite it with the updated version.
- If the destination file **already exists** and contains custom user content that differs from the pack version, **do not overwrite** — warn the user that manual reconciliation is needed.

This step ensures the repo works with all supported tools (VS Code Copilot, Copilot CLI, Claude Code CLI, Codex CLI) after any single initialization workflow runs.

## Procedure 8: Record the Initialized Repo Name for the GUI (Idempotent, all tools)
The Request Builder GUI (`harness_gui.py`) renders its header as `HarnessFlow · <repo name>`. Record the initialized repo's name explicitly so the GUI shows the repo that was **actually initialized** — not an ancestor/parent folder that `git rev-parse --show-toplevel` may resolve to when the initialized folder is not itself a git repository.

1. Determine `[initialized repo name]`:
   - If the initialize request supplied a non-empty `repo name:` value, use it verbatim.
   - Otherwise use the repo's root folder name — the folder that **contains** `.github/HarnessFlow/` in the installed layout, or the pack root's own folder in the source/pack-root layout. This is the same `[repo folder name]` used in Procedure 5, and it is the repo being initialized (never its parent folder).
2. Write `[initialized repo name]` as a single line (no surrounding quotes, no extra content) to `.repo_name` at the pack root — the same folder as `harness_gui.py` (i.e., `.github/HarnessFlow/.repo_name` when installed). Create or overwrite it so a later rename stays correct.
3. Ensure `.repo_name` is git-ignored (like `.pack_root`): add a `.repo_name` line to the enclosing repo's `.gitignore` if it is not already there (create `.gitignore` if missing). Do not commit `.repo_name`; it is machine-local state. `harness_gui.py` reads it first when building the header, so after initialization the GUI shows the initialized repo's name.
