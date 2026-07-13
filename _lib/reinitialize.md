# Re-Initialization — Reuse Existing repo_info

Canonical rule for how the three initialize workflows behave when the target repo already
carries generated repo_info content. The initialize instruction files point here; this file is
the single source — they deliberately do not restate it.

Re-initialization never starts from scratch and never discards existing repo_info. Its shape is:
**validate the existing claims → update with a targeted diff → revalidate the repo as a whole.**

---

## Mode Detection (per overview file)

At the point the workflow ensures the [repo_info files] exist (fast/skill Step 1; general
Procedure 2), inspect the two overview files' **content** — not mere existence, since the
ensure-files step creates empty placeholders:

- An overview file (`codebase_overview.md` or `scripts_overview.md`) that already has non-empty,
  non-whitespace content is in **re-initialize** mode.
- A missing or empty overview is in **fresh** mode — generated exactly as today.

The run is a **re-initialization** when at least one overview is in re-initialize mode. Modes are
per-file: a prior run that stopped between the two overview writes leaves one file re-initialize
and the other fresh, and each file follows its own mode.

## Validate Existing Claims

For each overview in re-initialize mode, the overview-generating subagent(s) receive the existing
overview content (per `_lib/workflow_contract.md` §Context Passing — inline on Claude Code; read
directly on Codex / VS Code Copilot) and, instead of drafting from scratch:

1. Re-derive every claim against the current code — never judge a claim by plausibility or prior
   knowledge; open the file(s) the claim describes.
2. Validate cross-file claims at every end — a pipeline-diagram edge or dependency claim spanning
   two scripts is confirmed only when both files still support it (cross-file drift is the
   hardest to catch).
3. Use git history to prioritize files changed since the overview was last written, but still
   spot-check claims about unchanged files.
4. Return the existing overview as the baseline plus a **[validation & diff report]**: claims
   confirmed · claims stale or incorrect (with the correction) · new files/modules missing from
   the overview · obsolete entries whose files no longer exist.

## Update With Diff

The main agent turns [validation & diff report] into **targeted edits** to the existing overview:

- Preserve confirmed content and its wording, including any manual curation.
- Correct stale claims, append entries for new files/modules, and delete obsolete entries.
- Update the [pipeline] diagram only where the diff requires it.
- Re-read the file's current content immediately before writing, and rewrite only the sections
  that actually changed — never blank-and-rewrite the file.

## Merge Known Issues

On re-initialization, `known_issues_auto_generated.md` is merged, never blind-overwritten: the
issue scan also validates each existing entry against the current code — drop entries that are
resolved or whose root-cause code is gone, keep entries that still hold, and append the new
findings.

## Repo-Wide Revalidation

After both overviews are written (whichever mode each used) and before the issue scan, the main
agent runs one high-level pass over the repo as a whole:

1. The [pipeline] diagram matches the actual entry points and data/control flow.
2. codebase_overview.md and scripts_overview.md are consistent with each other — same scripts,
   same roles, no contradicting descriptions.
3. Every file in [file structure] is accounted for, and nothing described has ceased to exist.

Fix any mismatch in the overviews before continuing.

---

## Scope

This file defines re-initialization behavior **only** for `codebase_overview.md`,
`scripts_overview.md`, and `known_issues_auto_generated.md`. Every other initialize step is
mode-independent and unchanged: the history files (`update_logs.md`, `known_issues.md`,
`past_Q&A.md`, `past_Correctness_Check.md`) are never regenerated in either mode,
`update_logs_auto_generated.md` is always rebuilt faithfully from git history, and the idempotent
tail steps (path cleanup, absolutization, entry-point copies, `.repo_name`) run unchanged.
