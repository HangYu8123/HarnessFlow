# Skills Index

Search this index before using repository skills. Each skill is an official skill folder with a `SKILL.md` entrypoint.

> **External skills for the skill-based workflow family:** The
> `workflow/skill_workflow/` family replaces selected step instructions
> with popular community skills (verified ≥1000 GitHub stars). Those external skills
> are not vendored here — they are catalogued, with sources, verified star counts,
> exact paths, and per-step fallbacks, in `skills/skill_workflow_skills.md`.

## breakdown-pr

- Path: `skills/breakdown-pr/SKILL.md`
- Slash name: `/breakdown-pr`
- Purpose: Analyze a large feature branch diff and decompose it into small, reviewable, dependency-ordered stacked PRs.
- Trigger: Use when a branch or PR is too large, mixes unrelated concerns, or needs a stacked-PR plan before review.
- Keywords: PR breakdown, PR splitting, stacked PRs, stacked diffs, code review, gh-stack, Graphite, git range-diff, branch decomposition, PR too large.

## claude-native-skills-subagents

- Path: `skills/claude-native-skills-subagents/SKILL.md`
- Slash name: `/claude-native-skills-subagents`
- Purpose: Orchestrates Claude Code bundled native skills after implementation in code, debug, refactor, or fast workflows.
- Trigger: Use only after an implementation report exists, such as [implementation report], [bug fix implementation report], or a workflow-specific equivalent.
- Condition: Use only when the main agent is Claude Code or another Claude agent with Claude Code skills available.
- Keywords: Claude Code, Claude agent, native skills, bundled skills, simplify, batch, claude-api, debug, implementation review.

## create-readme

- Path: `skills/create-readme/SKILL.md`
- Slash name: `/create-readme`
- Purpose: Review the entire project/workspace and produce one comprehensive, polished, well-structured README.md grounded in the actual source files.
- Trigger: Use when the user asks to create / write / generate / draft a README (README.md) for a project and wants a comprehensive, human-readable result. This is the **default** README skill.
- Condition: When the request instead emphasizes a quick, manifest/dependency-driven scaffold for a standard single-ecosystem project, prefer `readme-generator`.
- Source: Adapted from `github/awesome-copilot` · `skills/create-readme/SKILL.md` (35,991★, MIT, verified 2026-06-30).
- Keywords: README, README.md, create readme, write readme, generate readme, draft readme, project documentation, comprehensive readme.

## readme-generator

- Path: `skills/readme-generator/SKILL.md`
- Slash name: `/readme-generator`
- Purpose: Generate a README.md by analyzing project structure, manifests, and dependencies (package.json / pyproject.toml / Cargo.toml / go.mod) across Python, Node.js, Rust, Go, and generic projects.
- Trigger: Use when the user wants a quick, structure/dependency-driven README scaffold for a standard project, or explicitly asks to build the README from project structure or dependencies.
- Condition: For a comprehensive, polished, whole-workspace README, prefer `create-readme` (the default README skill).
- Source: Adapted from `glincker/claude-code-marketplace` · `skills/documentation/readme-generator/SKILL.md` (32★, Apache-2.0, verified 2026-06-30).
- Keywords: README generator, generate readme, readme from dependencies, project structure readme, package.json readme, manifest-driven readme, scaffold readme.

## weekly-update-report

- Path: `skills/weekly-update-report/SKILL.md`
- Slash name: `/weekly-update-report`
- Purpose: Summarize the last 7 days of git commit history into a short, user-facing "what I shipped last week" update report.
- Trigger: Use ONLY when the user explicitly asks to generate their last week / weekly update report (e.g. "generate my last week update report", "make my weekly update", "what did I ship last week").
- Condition: Do NOT trigger for general changelogs, release notes, version notes, app-store notes, or any unscoped "create a changelog" request. If intent is ambiguous, ask once or default to not triggering.
- Source: Adapted (trigger scoped down) from `ComposioHQ/awesome-claude-skills` · `changelog-generator/SKILL.md`.
- Keywords: weekly update, last week report, what I shipped, weekly digest, git log summary, standup, work summary.
