---
name: 'Initialize Repo (Codex)'
description: 'Instructions for creating repo_info memory files — Codex CLI native'
---
# create necessary files for guiding the entire agentic coding workflow

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - repo_info/ (created by this workflow)
-->

**DO NOT TRY TO COMMIT CHANGES TO GITHUB**
**DO NOT WRITE SPAM FILES INTO THE REPO**
**DO NOT USE SUDO**

Before doing any workflow-specific work, the main agent must read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md`, resolved by the Pack Path Resolution rule, before proceeding.
Every subagent created by this workflow must also read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md` before reading the repo or performing task-specific work.

Subagent launch rule:
- All subagent creation must follow the Subagent Launch Contract in `_lib/workflow_contract.md`.
- Before creating any subagent, ask the main agent to answer what model it is using, refer the model as [main agent model]
- when creating any subagent, explicitly instruct the main agent to: "**Create subagent with the exact [main agent model] — do not downgrade.**"
- Subagents must use the [main agent model]

## Subagent Definitions
All subagent roles referenced in this workflow are defined as custom agents under `agents/` (see `agents/INDEX.md` for the full registry). When creating subagents, invoke them by their agent name. Codex CLI discovers agent definitions from `agents/` directory. For parallel execution, use Codex agent workers with concurrency controlled by `agents.max_threads` in the Codex configuration. If parallel agent workers are not available, launch subagents sequentially — the results are equivalent.

## Procedure 1: Run CLI Setup & Scan Repo
First, verify that the repo has been set up for CLI tools. Check if `AGENTS.md` exists at the repo root. If it is missing, recommend running `bash .github/harness_coding_instructions/cli_setup.sh` from the repo root to generate entry-point files.
Then go through the entire repo, keep what files exist in this repo in the memory.

## Procedure 2: Verify repo_info Files
The `repo_info/` folder must be at the same level as `request_template/` and `workflow/` (i.e., all are siblings under the pack root `.github/harness_coding_instructions/`).
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


## Procedure 3: Create File Structure
Create a subagent, read through all the files in the repo, understand them, and create a [file structure] of the repo. The subagent must feed [file structure] back to the main agent. The main agent validates [file structure] and makes sure [file structure] includes all files and folders in the repo.


## Procedure 4: Create/Update Files
create/update the files in Procedure 2 with the **following specifications**.
under the repo_info folder.

**[PARALLEL EXECUTION via Codex agent workers — launch §4.1 (codebase_overview.md) and §4.2 (scripts_overview.md) in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]**

### 4.1 codebase_overview.md:
If the file does not exist, create an empty file.
If the file exists, the main agent must read through the file and keep it inside the memory, and set [pipeline] to be the diagram pipeline in the file.
Then:
1. **[PARALLEL EXECUTION via Codex agent workers — launch the following three subagents in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]**:
a. create a subagent (code agent, order mode), follow [file structure] in order, go through all files by folders, understand what each file is, how they work in the repo, and what they do. Then based on the results of reading and understanding all the files, construct [codebase_overview 1] and return [codebase_overview 1] to the main agent.
b. create a subagent (code agent, expand mode), follow [file structure], based on file name, decide what file to go first (usually main.py or any main scripts of the repo), and start reading and understanding the script. then go through the imported files one by one, for each imported file, read through the file and understand it, then go through the imports of the imported file, and so on. every time, when it finishes reading a file, add that file into [read files]. Once the subagent finishes reading, validate if there are any files that have not been read by comparing [read files] with [file structure]. If there are files that have not been read, repeat the previous steps and read those files until all files have been read. Then based on the results of reading and understanding all the files, construct [codebase_overview 2] and return [codebase_overview 2] to the main agent.
c. create a subagent (code agent, free mode), follow [file structure], the agent must decide what order to use for all files and how to understand what each file is, how they work in the repo, and what their positions are in [pipeline]. Then based on the results of reading and understanding all the files, construct [codebase_overview 3] and return [codebase_overview 3] to the main agent.
2. based on [codebase_overview 1], [codebase_overview 2], and [codebase_overview 3], the main agent must combine the advantages of three codebase_overviews, reject the redundant or incorrect parts of each codebase_overview, and draft final [codebase_overview]. The main agent must also check the consistency of final [codebase_overview] with the pipeline diagram in the original codebase_overview.md (if it exists); if there are inconsistencies, update the pipeline diagram accordingly.
3. the main agent must update [pipeline] based on the final decision from a senior staff engineer perspective, making sure [pipeline] is correct, stable, and can guide the entire codebase to perform correctly.
4. the main agent must convert [pipeline] into a code diagram. In each block in the diagram, the associated scripts must also be mentioned.
5. Then, create a subagent, pass the pipeline diagram to the subagent, the subagent goes through the generated diagram and associated scripts step by step and makes sure the correctness and consistency. Then feed the review back to the main agent.
6. Then based on the diagram and the review, the main agent checks correctness by itself and updates the diagram accordingly.
7. Finally, write the diagram into the codebase_overview.md, along with a description of the repo.


### 4.2 scripts_overview.md
If the file does not exist, create an empty file.
Then:
1. **[PARALLEL EXECUTION via Codex agent workers — launch the following three subagents in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]**:
a. create a subagent (code agent, folder mode), pass [file structure] to the subagent. the subagent must go through all files in the repo from folder to folder, and read through files in folders one by one. for each file, if it is a code script, summarize each module (function, method, class, code blocks) with two sentences: one sentence of function name, parameters, and outputs, and one short sentence that describes the functionality. organize the summarization by files: give each file a high-level summarization, and give out a list of dependencies of that file. then report [scripts overview 1] to the main agent.
b. create a subagent (code agent, guided mode), ask the agent to read through scripts_overview.md. then the subagent must read through codebase_overview.md, understand [pipeline] and the codebase structure, then based on that, read through files according to [pipeline] (from upstream to downstream). for each file, if it is a code script, summarize each module (function, method, class, code blocks) with two sentences: one sentence of function name, parameters, and outputs, and one short sentence that describes the functionality. organize the summarization by files: give each file a high-level summarization, and give out a list of dependencies of that file. then report [scripts overview 2] to the main agent.
c. create a subagent (code agent, file mode), the subagent must go through all files in the repo, then read through files one by one. for each file, if it is a code script, summarize each module (function, method, class, code blocks) with two sentences: one sentence of function name, parameters, and outputs, and one short sentence that describes the functionality. organize the summarization by files: give each file a high-level summarization, and give out a list of dependencies of that file. then report [scripts overview 3] to the main agent.
2. the main agent reads the reports from step 1 ([scripts overview 1], [scripts overview 2], and [scripts overview 3]) and scripts_overview.md, understands each of them, combines the advantages of three reports, rejects the redundant or incorrect parts of each report, drafts final [scripts overview], and writes final [scripts overview] into scripts_overview.md.
3. create a subagent (review agent), the subagent first reads scripts_overview.md, follows scripts_overview.md to go through all scripts and files one by one, first reads the original code/text, then validates the summarization of scripts_overview.md. Report inconsistency back to the main agent.
4. update the scripts_overview.md


### 4.3 known_issues_auto_generated.md:
if the file exists, do nothing.
if the file does not exist, create an empty file.
then:

**IMPORTANT: §4.3 depends on §4.1 and §4.2 being complete. Do NOT start §4.3 until codebase_overview.md and scripts_overview.md have been written to disk.**

For a full-depth correctness check, see `workflow/codex_workflow/correctness_check.instructions.md`. This section performs only a lightweight assessment.

**[PARALLEL EXECUTION via Codex agent workers — launch steps 1 and 2 in parallel; if parallel subagents are not supported in your CLI environment, run them sequentially — sequential execution produces equivalent results]**
1. create a subagent (plan agent), go through codebase_overview.md and scripts_overview.md, point out the weaknesses of the code architecture and all possible issues. report back to the main agent.
2. create a subagent (code agent), go through codebase_overview.md and scripts_overview.md, and then go through all scripts one by one, find any potential issues or code that could lead to problems, errors, and bugs. find anything that could affect the code being 100% correct. find anything that prevents code from running 100% correctly or functioning as expected. report back to main agent.
3. the main agent uses the information from steps 1 and 2 to perform a lightweight correctness assessment of the repo — identifying potential problems, issues, and weaknesses of the codebase. Do NOT invoke the full correctness_check workflow here, as repo_info files may not all be finalized yet. Instead, use the subagent reports from steps 1 and 2, combined with the main agent's own reading of the codebase, to produce the assessment.
4. the main agent summarizes the reviews from step 1, step 2, and step 3, based on the information it has, and uses its best ability to combine the reviews with only correct and fair parts.
5. write the contents to known_issues_auto_generated.md in the format of:
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

CLI workflows use relative paths (not `@/` prefixed paths). The `@/.github/` → `@/[repo folder name]/.github/` rewrite is a VS Code-only concern and does **not** apply to CLI workflow files. If any `@/` paths have leaked into files under `workflow/claudecode_workflow/`, `workflow/codex_workflow/`, or `workflow/codex_token_effective_workflow/`, remove them and replace with relative paths. Otherwise, this step is a no-op for CLI environments.


## Procedure 6: Copy Entry-Point Files for Cross-Tool Compatibility
Copy the entry-point files from the pack to their standard discoverable locations. This ensures each tool can auto-discover its instructions without additional configuration, regardless of which tool was used to initialize.

1. Copy `.github/harness_coding_instructions/copilot-instructions.md` → `.github/copilot-instructions.md` (standard GitHub Copilot discovery path).
   - **Important**: In the destination copy, rewrite all `#file:` references by prepending `harness_coding_instructions/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:harness_coding_instructions/_lib/workflow_contract.md`, and `#file:workflow/vscode_workflow/code.instructions.md` becomes `#file:harness_coding_instructions/workflow/vscode_workflow/code.instructions.md`. This is necessary because `#file:` paths resolve relative to the file's directory — when the file moves from `.github/harness_coding_instructions/` to `.github/`, the paths must be adjusted accordingly.
2. Copy `.github/harness_coding_instructions/CLAUDE.md` → repo root `CLAUDE.md` (Claude Code CLI auto-discovers this at the repo root).
3. Copy `.github/harness_coding_instructions/AGENTS.md` → repo root `AGENTS.md` (Codex CLI auto-discovers this at the repo root).

For each file:
- If the destination file does **not** exist, copy it.
- If the destination file **already exists** and appears to be a previously generated copy (contains the same header/marker text as the source, e.g., `"Master Orchestrator — Instruction Router"` for copilot-instructions.md), overwrite it with the updated version.
- If the destination file **already exists** and contains custom user content that differs from the pack version, **do not overwrite** — warn the user that manual reconciliation is needed.

This step ensures the repo works with all supported tools (VS Code Copilot, Copilot CLI, Claude Code CLI, Codex CLI) after any single initialization workflow runs.
