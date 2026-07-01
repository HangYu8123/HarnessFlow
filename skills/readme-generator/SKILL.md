---
name: readme-generator
description: 'Generate a README.md by analyzing project structure, manifests, and dependencies (package.json / pyproject.toml / Cargo.toml / go.mod) across Python, Node.js, Rust, Go, and generic projects. TRIGGER when the user wants a quick, structure/dependency-driven README scaffold for a standard project, or explicitly asks to build the README from project structure or dependencies. For a comprehensive, polished, whole-workspace README, prefer `create-readme` instead.'
argument-hint: '[target_path=.]'
allowed-tools: ['Read', 'Glob', 'Grep', 'Write']
---

# README Generator

Generate a `README.md` by analyzing a project's **structure, manifests, and
dependencies** through a deterministic discovery pipeline. Best for standard,
single-ecosystem projects that need a solid starting-point README fast.

> **Adapted from** `glincker/claude-code-marketplace` ·
> `skills/documentation/readme-generator/SKILL.md`
> (https://github.com/glincker/claude-code-marketplace). Source verified
> 2026-06-30: **32★**, **Apache License 2.0** (© GLINCKER Team) — retain this
> attribution and the Apache-2.0 notice when redistributing. The four-step
> pipeline and tool set (`Read`, `Glob`, `Grep`, `Write`) mirror the source
> skill; wording is adapted to this pack's SKILL.md conventions.

## When to Use This Skill

- The user wants a **quick, dependency/structure-driven** README scaffold.
- The project is a standard **Python / Node.js / Rust / Go** (or generic) repo
  with recognizable manifests.
- The request explicitly mentions building the README from project structure
  or dependencies.

## When NOT to Use This Skill

- The user wants a **comprehensive, polished, whole-workspace** README → use
  `create-readme` instead (that is the default README skill).
- The project has no standard manifest and needs semantic reading of the code
  to describe its features → `create-readme` is the better fit.

## Workflow

1. **Project Discovery** — use Glob to locate manifests and key files:
   `package.json`, `pyproject.toml` / `setup.py`, `Cargo.toml`, `go.mod`, plus
   entry points, scripts, and test configs.
2. **Content Analysis** — Read those manifests and Grep the codebase to
   determine project type, language, dependencies, scripts, and test setup.
3. **README Generation** — assemble the sections:
   - **Required:** title, features, installation, usage, license (link).
   - **Contextual (add only when evidence exists):** testing, development
     setup, API docs, configuration.
   Use ecosystem-appropriate install/run phrasing (e.g. `pip install` + virtual
   env for Python; `npm install` + scripts for Node.js; `cargo` for Rust;
   `go install` / `go build` for Go).
4. **Write** the formatted `README.md` to the target path.

## Output

A single `README.md` at the target path, driven by the detected manifests and
structure.

## Quality Gates

- Installation / usage commands match the detected ecosystem and real scripts.
- Only sections with supporting evidence are included (no empty API/testing
  sections).
- Dependencies and commands reflect the actual manifests, not assumptions.

## Limitations (from the source skill)

- Produces a **starting point** — the user should review and customize.
- Works best with **standard project structures**; unusual layouts may need
  manual help.
- Manifest/structure-driven — it does **not** deeply analyze code logic to
  infer features (use `create-readme` when semantic code reading is needed).
