---
name: write-readme
description: 'Generate a structured, pipeline-and-component-oriented README.md for a repository, grounded in its actual source and repo_info context rather than a generic template. Produces, in order: a short goal paragraph, an entry-point-to-outcome pipeline overview covering every component at a high level, a per-component and per-file/script breakdown (functionality, input/output, key parameters), example run commands with important CLI parameters, a few code usage examples, and a Notes section (key advantages, known issues, future improvements, references). TRIGGER whenever the user asks to write, create, generate, draft, or update a README or README.md, to "document this project/repo", or to "generate documentation" for a codebase. This is the pack''s sole, default README-generation skill.'
argument-hint: '[target_path=.]'
allowed-tools: ['Read', 'Glob', 'Grep', 'Write']
---

# Write README

Produce one comprehensive, well-structured `README.md` for a repository by reading
its `repo_info/` context and its **actual source**, then writing the file in a fixed,
component-and-pipeline oriented layout. Every claim must trace to real code — never
invent features, parameters, or commands.

> **Original to this pack.** This skill is not adapted from an external skill; the
> workflow and README layout below are this pack's own convention. No third-party
> attribution or license notice applies.

## When to Use This Skill

Use when the user asks to write, create, generate, draft, or update a project
`README.md`, or to "document this project / repo", e.g.:

- "Write a README for this repo"
- "Generate documentation / a README.md for this project"
- "Draft a README that explains the pipeline and each component"

This is the **only** README-generation skill in the pack — there is no sibling to
defer to.

## When NOT to Use This Skill

- Editing a single existing section of a README, or a small copy tweak — do that
  inline without the full pipeline.
- Writing `CONTRIBUTING`, `CHANGELOG`, or `LICENSE` bodies — those belong in their
  own files; link to them from the README instead of inlining them.
- Producing a weekly/update changelog — use `weekly-update-report` instead.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `target_path` | No | `.` | Repository root to document and to write `README.md` into. |

The skill reads the repo's `repo_info/` folder (resolved via Pack Path Resolution:
`.github/HarnessFlow/repo_info/` when installed, else `repo_info/` from the repo
root) plus source files it selects; it takes no other configured inputs.

## Workflow

Follow these eight steps in order. They map 1:1 to the required README sections.

### 1. Read the `repo_info/` folder

Read whichever of the canonical context files exist — `codebase_overview.md`,
`scripts_overview.md`, `update_logs.md`, `known_issues.md` (and any other `*.md`
present) — under `repo_info/` (Pack Path Resolution). Some or all may be absent;
skip missing files silently and rely on source reading (Step 2) to fill gaps. Do
not create these files or fail if they are missing.

### 2. Strategically read additional source files for detail

Depth over breadth. Locate and read the files that actually define behavior:
entry points (`main.*`, `__main__.py`, `cli.*`, `index.*`, `app.*`), package
manifests (`package.json`, `pyproject.toml`/`setup.py`, `Cargo.toml`, `go.mod`),
config, and the key modules/scripts each component hangs off. Use Glob/Grep to
find them and follow imports/calls from the entry point outward. Read enough to
describe each component truthfully — the truth is in the code, not in prose.

### 3. Draft the goal paragraph

Write **one short paragraph** (2–4 sentences) stating the repo's key goal and core
functionality: what problem it solves and what it produces. Lead with the shortest
possible "what/why" before any detail.

### 4. Draw the pipeline overview

Draw the repo as a **pipeline from entry point to final outcome**, listing every
component at a high level in execution order (input → processing stages → output).
Use a compact diagram (a fenced `text` flow such as `A -> B -> C`) and/or a short
ordered list. This is the high-level map; per-file detail comes next.

### 5. Introduce each component

For **each component** in the pipeline, write a subsection containing:

- **One-sentence summary** of the component's role.
- **Input → Output** at a high level (only if the component has meaningful I/O).
- A **table of the files/scripts** in the component. For each file/script give:
  - one sentence on its **key functionality**,
  - one sentence on its **key input and output**,
  - one sentence on its **key parameters** (flags, config keys, args).

Keep each cell to a single sentence. Ground every entry in the file you actually
read; omit a column for a file only when it genuinely has nothing to report.

### 6. Show example run commands

Provide a few **example commands** for running the code, each including the
**important CLI parameters** (flags, required args, sensible defaults). Derive
these from real entry points and argument definitions — do not guess flags. Use
fenced code blocks and note what each command does.

### 7. Show code usage examples

Provide a few short **code examples** for importing or using the code as a
library/module (e.g. importing the main entry function and calling it with typical
arguments). Keep them minimal, runnable, and grounded in the real public API.

### 8. Write the Notes section

Close with a **Notes** section containing four parts:

- **Key advantages** — what the project does well / why to use it.
- **Known issues** — draw from `known_issues.md` if present, plus caveats visible
  in the code; state honestly, do not invent.
- **Future improvements** — realistic next steps, marked as aspirational.
- **References** — links to related docs, source, external resources, and the
  separate `LICENSE`/`CONTRIBUTING` files (link, do not inline).

Then write the assembled document to `README.md` at `target_path`.

## Output Format

A single `README.md` at `target_path`, in GitHub Flavored Markdown, following this
skeleton:

````markdown
# <Project Name>

<Step 3: one short paragraph — the key goal and core functionality.>

## Overview / Pipeline

<Step 4: entry-point-to-outcome pipeline, all components at a high level.>

```text
<entry point> -> <component A> -> <component B> -> <final outcome>
```

## Components

### <Component 1>

<One-sentence summary.> **Input:** <...> **Output:** <...>

| File / Script | Key functionality | Key input / output | Key parameters |
|---|---|---|---|
| `path/to/file` | <one sentence> | <one sentence> | <one sentence> |

### <Component 2>
...

## Usage

### Example commands

```bash
<command> --important-flag <value>   # what it does
```

### Code examples

```python
from package.module import main
main(input_path="...", option=True)
```

## Notes

- **Key advantages:** <...>
- **Known issues:** <...>
- **Future improvements:** <...>
- **References:** <links, LICENSE, CONTRIBUTING>
````

## Quality Gates

- Every feature, file, command, and parameter in the README maps to something
  actually present in the source — no invented behavior.
- The document contains all eight parts in order: goal paragraph, pipeline
  overview, per-component + per-file breakdown, example commands, code examples,
  and a Notes section with all four sub-parts.
- Each per-file table cell is a single sentence; each example command shows its
  important CLI parameters.
- Missing `repo_info/` files were handled gracefully (skipped, not fabricated).
- If a `README.md` already existed, its overwrite was surfaced (see Gotchas), not
  done silently.

## Gotchas

- **Do not silently overwrite a hand-maintained README.** If `README.md` already
  exists at `target_path`, note that it will be replaced and, per the pack's
  approval gate (`_lib/approval_gate.md`), prefer showing a diff or confirming
  before overwriting a substantial existing file.
- **`repo_info/` is often partial.** On many repos only `update_logs.md` (or
  nothing) exists. Treat those files as a bonus context source, not a
  prerequisite — the source code is the source of truth.
- **Don't re-explain code in prose.** Point to the real files and keep per-file
  descriptions to the required one-sentence-per-column form; link to code rather
  than paraphrasing it at length.
- **Derive commands and API from real entry points.** Fabricated flags or import
  paths are worse than omitting the example — verify against the actual argument
  parser / exported symbols before writing them.

## References

- Anthropic Agent Skills — best practices: `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices`
- Anthropic `skill-creator` reference skill: `https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md`
- Documenting pipelines by pointing to code: `https://mikulskibartosz.name/documenting-data-pipelines`
