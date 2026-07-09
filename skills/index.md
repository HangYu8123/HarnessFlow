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
- Condition: Use only when the main agent is Claude Code or another Claude agent with Claude Code skills available, and the `simplify` / `code_review` header is `true` (the `local` value bypasses this wrapper — see `_lib/review_skills.md`).
- Keywords: Claude Code, Claude agent, native skills, bundled skills, simplify, batch, claude-api, debug, implementation review.

## code-simplification

- Path: `skills/code-simplification/SKILL.md`
- Slash name: `/code-simplification`
- Purpose: Reduce complexity in a diff while preserving exact behavior — guard clauses over deep nesting, focused functions over long ones, descriptive names, no dead code — and apply the edits to the working tree.
- Trigger: Use **only** from a workflow's post-implementation review step when the request header is `simplify: local` (see `_lib/review_skills.md`). This is the platform-independent alternative to Claude Code's native `/simplify`.
- Condition: Post-implementation / review-time only — **not** a planning-time skill, so Local Skill Discovery (`_lib/local_skill_discovery.md`) must skip it.
- Source: Vendored from `addyosmani/agent-skills` (75,536★, MIT) · `skills/code-simplification/SKILL.md`, plus a HarnessFlow precedence preamble (no-commit safety rule and the autonomous approval gate override the upstream text).
- Keywords: simplify, simplification, reduce complexity, readability, dead code, deep nesting, long function, redundancy, refactor for clarity.

## code-review-and-quality

- Path: `skills/code-review-and-quality/SKILL.md`
- Slash name: `/code-review-and-quality`
- Purpose: Review-only, multi-axis review of a diff — correctness, readability/simplicity, architecture, security, performance — returning severity-labelled findings (Critical / required / Optional / Nit / FYI).
- Trigger: Use **only** from a workflow's post-implementation review step when the request header is `code_review: local` (see `_lib/review_skills.md`). This is the platform-independent alternative to Claude Code's native `/code-review`.
- Condition: Post-implementation / review-time only, and strictly read-only — **not** a planning-time skill, so Local Skill Discovery (`_lib/local_skill_discovery.md`) must skip it.
- Source: Vendored from `addyosmani/agent-skills` (75,536★, MIT) · `skills/code-review-and-quality/SKILL.md`, plus a HarnessFlow precedence preamble (no-commit safety rule and the autonomous approval gate override the upstream text).
- Keywords: code review, quality gate, correctness, security review, performance review, architecture review, severity labels, dead code hygiene.

## weekly-update-report

- Path: `skills/weekly-update-report/SKILL.md`
- Slash name: `/weekly-update-report`
- Purpose: Summarize the last 7 days of git commit history into a short, user-facing "what I shipped last week" update report.
- Trigger: Use ONLY when the user explicitly asks to generate their last week / weekly update report (e.g. "generate my last week update report", "make my weekly update", "what did I ship last week").
- Condition: Do NOT trigger for general changelogs, release notes, version notes, app-store notes, or any unscoped "create a changelog" request. If intent is ambiguous, ask once or default to not triggering.
- Source: Adapted (trigger scoped down) from `ComposioHQ/awesome-claude-skills` · `changelog-generator/SKILL.md`.
- Keywords: weekly update, last week report, what I shipped, weekly digest, git log summary, standup, work summary.

## write-readme

- Path: `skills/write-readme/SKILL.md`
- Slash name: `/write-readme`
- Purpose: Generate a structured, pipeline-and-component-oriented `README.md` grounded in the repo's actual source and `repo_info/` context — goal paragraph, entry-point-to-outcome pipeline overview, per-component and per-file breakdown (functionality, input/output, key parameters), example commands with CLI parameters, code usage examples, and a Notes section.
- Trigger: Use when the user asks to write / create / generate / draft / update a README (or README.md), to "document this project/repo", or to "generate documentation" for a codebase. This is the pack's sole, default README-generation skill.
- Keywords: README, README.md, write readme, generate readme, project documentation, document this repo, pipeline overview, component breakdown, usage examples.
