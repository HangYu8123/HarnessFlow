---
name: 'Fast Initialize Repo'
description: 'Unified token-effective (fast) repo-initialization workflow for Claude Code, Codex, and VS Code Copilot: single-pass overview generation with one parallel doc subagent step (Free Analyst + Focus Analyst), main-agent issue/history detection, path cleanup, and cross-tool entry-point refresh.'
---
# Create Necessary Files for Agentic Coding Workflow

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/subagent_contract.md
  - _lib/absolutize_pack_paths.md
  - _lib/reinitialize.md
  - repo_info/ (created by this workflow)
  - agents/free-analyst.agent.md
  - agents/focus-analyst.agent.md
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly. On a first run this workflow creates the `repo_info/` overviews, so subagents read the live repo files instead; on re-initialization the existing overviews are the baseline to validate and diff-update per [`_lib/reinitialize.md`](../../_lib/reinitialize.md).

This workflow generates documentation; it does not modify source code, so there is no approval gate.

[inputs]:
- input 1: target repo (optional, default to current repo)
- input 2: important files or docs to preserve (optional)

**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must instead read and follow [`_lib/subagent_contract.md`](../../_lib/subagent_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before performing task-specific work. The main agent passes repo context to subagents per §Context Passing; subagents do not re-read files already summarized by the main agent (on a first run the `repo_info/` overviews do not exist yet — this workflow creates them; on re-initialization the existing overviews are passed to subagents as validation baselines per `_lib/reinitialize.md`).

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md). **Every spawn carries two dials, not one:** model from the `subagent_model` header, effort from the `subagent_effort` header (and from `online_researcher_effort` for the Online Researcher). Unless the resolved effort is `inherit`, set the platform effort field where the spawn exposes one, otherwise put the line `effort: <level> — binding budget, not a hint` in the subagent prompt. After each subagent returns, the main agent must check that the result is complete, task-specific, grounded in the requested files, and uses the expected output label.

> **Subagent invocation:** See `_lib/workflow_contract.md` §Subagent Invocation.

---

## CREATE ONE TODO PER STEP

### Step 1 - Scan and Setup
First, verify that the repo has been set up for your tool, then scan the repo.
- **If the main agent is Claude Code:** check that `CLAUDE.md` exists at the repo root; if it is missing, recommend running `bash .github/HarnessFlow/cli_setup.sh` from the repo root to generate CLI entry-point files.
- **If the main agent is Codex:** check that `AGENTS.md` exists at the repo root; if it is missing, recommend running `bash .github/HarnessFlow/cli_setup.sh` from the repo root to generate CLI entry-point files. If using Codex in VS Code, use the same root `AGENTS.md` and installed pack files — do not require VS Code Copilot `chat.agentFilesLocations` settings for Codex workflows.
- **If the main agent is VS Code Copilot:** if `.vscode/settings.json` does not already contain `chat.agentFilesLocations` with `.github/HarnessFlow/agents` set to `true`, run `setup.sh` from the target repo root to configure VS Code workspace settings.

Then:
1. Scan the entire repo and keep the file listing in memory.
2. Ensure the repo_info folder exists.
3. Ensure these canonical [repo_info files] exist under repo_info, creating empty files when missing:
   - codebase_overview.md
   - scripts_overview.md
   - update_logs_auto_generated.md
   - known_issues_auto_generated.md
   - update_logs.md
   - known_issues.md
   - past_Q&A.md
   - past_Correctness_Check.md
4. Use `past_Q&A.md` for query history and `past_Correctness_Check.md` for correctness-check history; do not create alternate history filenames.
5. Determine [init mode] per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Mode Detection: an overview file that already has non-empty content is in **re-initialize** mode (validate + diff-update, never regenerate from scratch); a missing or empty one is **fresh**.

### Step 2 - File Structure
From the Step 1 scan, the main agent produces [file structure] (the directory/file tree) and validates it for completeness. No subagent is needed — the main agent already holds the listing.

### Step 3 - Documentation Generation
Generate each overview **once**. **[PARALLEL EXECUTION — launch all listed subagents in parallel; see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Parallel Execution & Fallback]** This is the only step that spawns subagents.

| Subagent | Agent | Role | Task |
|----------|-------|------|------|
| Codebase | **Free Analyst** (`agents/free-analyst.agent.md`) | Free mode | Read [inputs] + [file structure]. Decide the reading order (entry points → imports → pipeline position), read the files, and construct [codebase_overview draft]. |
| Scripts | **Focus Analyst** (`agents/focus-analyst.agent.md`) | Folder mode | Read [inputs] + [file structure]. Go folder-by-folder and summarize each function/class in code files with their dependencies. Return [scripts overview draft]. |

For an overview in re-initialize mode, additionally pass that analyst the overview's existing content (Free Analyst ← codebase_overview.md, Focus Analyst ← scripts_overview.md): the analyst validates it per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Validate Existing Claims, and its draft is the existing overview plus a [validation & diff report] rather than a from-scratch rewrite.

### Step 4 - Synthesize and Write Codebase Overview
1. The main agent validates [codebase_overview draft] against the actual files, fixing inaccuracies.
2. Draft the [pipeline] diagram with associated scripts in each block and validate it against the code.
3. Write codebase_overview.md with the diagram and repo description.

If codebase_overview.md is in re-initialize mode, apply the [validation & diff report] as targeted edits per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Update With Diff — preserve confirmed content, never blank-and-rewrite.

### Step 5 - Synthesize and Write Scripts Overview
1. The main agent spot-checks [scripts overview draft] against actual files and fixes inconsistencies.
2. Write the final scripts_overview.md.

If scripts_overview.md is in re-initialize mode, apply the [validation & diff report] as targeted edits per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Update With Diff — preserve confirmed content, never blank-and-rewrite.

### Step 6 - Issue Scan and History
On a re-initialization run, first run the repo-wide revalidation per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Repo-Wide Revalidation and fix any mismatch in the overviews before continuing.
1. The main agent scans for issues directly: using scripts_overview.md and the pipeline, read the key scripts and identify architectural weaknesses, potential bugs, error-prone code, and anything preventing correct execution. On re-initialization, the scan also validates each existing known_issues_auto_generated.md entry per `_lib/reinitialize.md` §Merge Known Issues. Record [issues report].
2. The main agent gets the git commit history and writes update_logs_auto_generated.md (faithful to the original commit logs, no interpretation).

### Step 7 - Finalize Issues
Write [issues report] to known_issues_auto_generated.md. On re-initialization, merge per [`_lib/reinitialize.md`](../../_lib/reinitialize.md) §Merge Known Issues — drop resolved entries, keep valid ones, append new findings — instead of overwriting:
```md
{Problem Title}
{Problem description}
{Root causes}
{Consequences}
```

### Step 8 - Path Reference Cleanup
After completing all steps above, check whether path references need cleanup. Handle per platform:
- **If the main agent is Claude Code:** Claude Code workflows use Pack Path Resolution (filesystem-relative paths), not VS Code `@/` workspace-relative paths or `#file:` prefixes. If any `@/` or VS Code-only `#file:` references have leaked into files under `workflow/general_workflow/`, `workflow/token_effective_workflow/`, or `workflow/skill_workflow/`, remove them and replace them with plain Pack Path Resolution-compatible paths; otherwise this is a no-op.
- **If the main agent is Codex:** Codex workflows use filesystem-relative or pack-relative paths, not VS Code `@/` prefixes. The `@/.github/` → `@/[repo folder name]/.github/` rewrite is a VS Code Copilot-only concern and does not apply to Codex workflow files, including Codex running in VS Code. If any `@/` or VS Code-only `#file:` references have leaked into files under `workflow/general_workflow/`, `workflow/token_effective_workflow/`, or `workflow/skill_workflow/`, remove them and replace them with relative paths; otherwise this is a no-op.
- **If the main agent is VS Code Copilot:** perform the full idempotent multi-root rewrite:
  1. Determine [repo folder name] — the name of the repo's root folder as it appears in the VS Code workspace.
  2. **Idempotency guard:** before any replacements, check if any `.md` file under `.github/HarnessFlow/` already contains a path with `[repo folder name]/.github/`. If so, this step already ran — skip all replacements and continue to Step 9 (Absolutize Claude Code & Codex Pack Paths).
  3. **Rename detection:** if the idempotency guard did not trigger, scan `.md` files under `.github/HarnessFlow/` for any path matching `[some_prefix]/.github/HarnessFlow/` where `[some_prefix]` is not [repo folder name]. If found, replace `[old_prefix]/.github/HarnessFlow/` with `[repo folder name]/.github/HarnessFlow/`, then skip to verification.
  4. Go through all `.md` files under `.github/HarnessFlow/` and replace every occurrence of `.github/HarnessFlow/` with `[repo folder name]/.github/HarnessFlow/` only in path references used by agents.
  5. Verify that updated paths resolve by spot-checking key paths such as `[repo folder name]/.github/HarnessFlow/repo_info/codebase_overview.md`.

### Step 9 - Absolutize Claude Code & Codex Pack Paths

After path cleanup (Step 8), follow the canonical procedure in [`_lib/absolutize_pack_paths.md`](../../_lib/absolutize_pack_paths.md): determine `[PACK_ROOT_ABS]`, record it in the git-ignored `.pack_root`, rewrite the in-scope Claude Code/Codex references, and regenerate the `harness_gui.html` template snapshots via `sync_gui_templates.py`.
If its idempotency guard triggers (this pack is already absolutized), skip to Step 10.

### Step 10 - Refresh Cross-Tool Entry Points
Copy the entry-point files from the pack to their standard discoverable locations so every supported tool can auto-discover its instructions after initialization. Handle per platform:

- **If the main agent is Claude Code or Codex:** copy all three entry points.
  1. Copy `.github/HarnessFlow/copilot-instructions.md` to `.github/copilot-instructions.md`.
     - In the destination copy, rewrite all `#file:` references by prepending `HarnessFlow/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:HarnessFlow/_lib/workflow_contract.md`. This is necessary because `#file:` paths resolve relative to `.github/copilot-instructions.md`.
  2. Copy `.github/HarnessFlow/CLAUDE.md` to repo root `CLAUDE.md`.
  3. Copy `.github/HarnessFlow/AGENTS.md` to repo root `AGENTS.md`.
  4. Copy the native worker definitions: `.github/HarnessFlow/.claude/agents/*.md` to repo root `.claude/agents/`, and `.github/HarnessFlow/.codex/agents/*.toml` to repo root `.codex/agents/`. These let workflows spawn workers by agent type instead of by inline prompt. They are generated from `agents/*.agent.md`; if any source `.agent.md` was changed during this initialization, first re-run `python3 sync_agent_definitions.py` from the pack root, then copy.

  For each destination file:
  - Create it if absent.
  - Overwrite it only if it appears to be a previously generated copy from this pack.
  - If custom content is detected, warn and skip.

- **If the main agent is VS Code Copilot:** copy only the Copilot entry point.
  1. Copy `.github/HarnessFlow/copilot-instructions.md` to `.github/copilot-instructions.md`.
     - In the destination copy, rewrite all `#file:` references by prepending `HarnessFlow/` to their paths. For example, `#file:_lib/workflow_contract.md` becomes `#file:HarnessFlow/_lib/workflow_contract.md`. This is necessary because `#file:` paths resolve relative to `.github/copilot-instructions.md`.
  - Create `.github/copilot-instructions.md` if absent. Overwrite it only if it contains the standard marker text `"Master Orchestrator"`. If custom content is detected, warn and skip.

### Step 11 - Record the Initialized Repo Name for the GUI
The Request Builder GUI (`harness_gui.py`) renders its header as `HarnessFlow · <repo name>`. Record the initialized repo's name explicitly so the GUI shows the repo that was **actually initialized** — not an ancestor/parent folder that `git rev-parse --show-toplevel` may resolve to when the initialized folder is not itself a git repository.

1. Determine `[initialized repo name]`:
   - If the initialize request supplied a non-empty `repo name:` value, use it verbatim.
   - Otherwise use the repo's root folder name — the folder that **contains** `.github/HarnessFlow/` in the installed layout, or the pack root's own folder in the source/pack-root layout (the same `[repo folder name]` referenced in Step 8). This is the repo being initialized, never its parent folder.
2. Write `[initialized repo name]` as a single line (no quotes, no extra content) to `.repo_name` at the pack root — the same folder as `harness_gui.py` and `.pack_root` (`.github/HarnessFlow/.repo_name` when installed). Create or overwrite it so a later rename stays correct.
3. Ensure `.repo_name` is git-ignored (like `.pack_root`): add a `.repo_name` line to the enclosing repo's `.gitignore` if it is not already there. Do not commit `.repo_name`; it is machine-local state. `harness_gui.py` reads it first when building the header, so after initialization the GUI shows the initialized repo's name.
