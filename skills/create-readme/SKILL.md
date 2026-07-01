---
name: create-readme
description: 'Create a comprehensive, well-structured README.md by reviewing the entire project and workspace and reading the actual source files. TRIGGER when the user asks to create / write / generate / draft a README (or README.md) for a project and wants a polished, human-readable result. This is the DEFAULT README skill. Defer to `readme-generator` only when the user specifically wants a quick, manifest/dependency-driven scaffold for a standard single-ecosystem project (Python/Node.js/Rust/Go).'
argument-hint: '[target_path=.]'
---

# Create README

Review the **entire project and workspace**, then produce one comprehensive,
well-structured `README.md` grounded in the actual source files — not a generic
template. This skill favors a polished, human-readable result.

> **Adapted from** `github/awesome-copilot` · `skills/create-readme/SKILL.md`
> (https://github.com/github/awesome-copilot). Source verified 2026-06-30:
> **35,991★**, **MIT License** (© GitHub, Inc.) — permissive; retain this
> attribution when redistributing. Trigger scoping and the workflow steps below
> are adapted to this pack's SKILL.md conventions; the style constraints are
> taken from the source skill.

## When to Use This Skill

Use when the user asks to create / write / generate / draft a `README.md` and
wants a comprehensive, polished result, e.g.:

- "Create a README for this project"
- "Write a README.md"
- "Generate project documentation / a README"

## When NOT to Use This Skill

- The user specifically wants a **quick, dependency/structure-driven scaffold**
  for a standard single-ecosystem project → use `readme-generator` instead.
- The request is to edit one section of an existing README, or to write
  CONTRIBUTING / CHANGELOG / LICENSE content (those live in separate files).

## Workflow

1. **Review the whole workspace.** Read the actual source: entry points,
   package manifests, configuration, scripts, and representative modules. Base
   every claim in the README on what the code actually does — do not invent
   features.
2. **Draft the README** in GitHub Flavored Markdown (GFM). Use GitHub admonition
   syntax (`> [!NOTE]`, `> [!WARNING]`) where it genuinely helps. If the project
   has a logo or icon, place it in the header.
3. **Apply the style constraints** (from the source skill):
   - Keep it concise and to the point.
   - Do **not** overuse emojis.
   - Do **not** include LICENSE / CONTRIBUTING / CHANGELOG sections — link to
     those separate files instead of inlining them.
4. **Write** the result to `README.md` at the target path.

Typical sections: title + one-line value proposition (with logo/badges if
present), overview, features, installation, usage / quickstart, configuration,
project structure, and links to the separate LICENSE / CONTRIBUTING files.

## Output

A single `README.md` at the target path, in GFM, grounded in the real source.

## Quality Gates

- Every feature/claim maps to something actually present in the code.
- Uses GFM; admonitions only where they add value; emojis are sparse.
- No LICENSE / CONTRIBUTING / CHANGELOG bodies inlined.
- Concise — no filler or a speculative roadmap the code does not support.
