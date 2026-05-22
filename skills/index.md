# Skills Index

Search this index before using repository skills. Each skill is an official skill folder with a `SKILL.md` entrypoint.

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
