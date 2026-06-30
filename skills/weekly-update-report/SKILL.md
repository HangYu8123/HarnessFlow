---
name: weekly-update-report
description: 'Generate MY "last week update report": summarize the past 7 days of git commit history into a short, user-facing weekly update. TRIGGER ONLY when the user explicitly asks to generate their last week / weekly update report (e.g. "generate my last week update report", "make my weekly update", "what did I ship last week"). Do NOT trigger for general changelogs, release notes, version notes, or any unscoped "create a changelog" request.'
argument-hint: '[since=7d] [repo_path=.] [author=me]'
---

# Weekly Update Report

Summarize the **last week of work** (the past 7 days of git commits) into a short,
readable "what I shipped last week" update. This is a deliberately narrowed clone
of a general changelog generator: it does **one** job — produce *my* weekly update
report on request — and nothing else.

> **Adapted from** `ComposioHQ/awesome-claude-skills` · `changelog-generator/SKILL.md`
> (https://github.com/ComposioHQ/awesome-claude-skills). The source repo had no
> LICENSE file at vendoring time (verified 2026-06-30); verify terms before
> redistributing. The trigger has been intentionally scoped down from the original
> (which fired on changelogs, release notes, app-store notes, and version docs).

## When to Use This Skill

Use this skill **only** when the user explicitly asks for *their* last-week / weekly
update report. Matching requests look like:

- "Generate my last week update report"
- "Make my weekly update"
- "Summarize what I shipped last week"
- "What did I get done this past week?" (in a code repo, asking for a write-up)

## When NOT to Use This Skill

Do **not** trigger this skill for any of these — leave them to a general changelog
tool or handle them inline:

- "Create a changelog" / "generate release notes" (no weekly-report intent)
- Release notes for a specific version or tag (e.g. "release notes for v2.5.0")
- App store "What's New" copy, version documentation, or a public changelog page
- Arbitrary date ranges that are not "the last week" (unless the user explicitly
  reframes it as their weekly update for that window)
- Any request that does not clearly ask for the user's own weekly update report

If the intent is ambiguous between a general changelog and a weekly update report,
ask one clarifying question before running, or default to **not** triggering.

## Inputs

| Input | Required | Default | Description |
|---|---|---|---|
| `since` | No | `7d` | Window for "last week". Override only if the user restates their weekly report for a different window. |
| `repo_path` | No | `.` | Repository to read commits from. Run from the repo root. |
| `author` | No | `me` | Whose commits to summarize. `me` = the current git user; omit/`all` to cover the whole team if the user asks. |

## Workflow

### 1. Scope the window and author

1. Confirm a git repository is present (`git rev-parse --is-inside-work-tree`).
2. Resolve the author. For "my" report, get the current user:

   ```bash
   git config user.name
   git config user.email
   ```

3. Pull the last week's commits (default 7 days; respect an explicit `since`):

   ```bash
   git log --since="7 days ago" --author="$(git config user.email)" \
     --no-merges --date=short \
     --pretty=format:'%h%x09%ad%x09%s'
   ```

   If `author=all` was requested, drop the `--author` filter.

### 2. Categorize the commits

Group commits into a small set of user-facing buckets. Skip internal noise
(pure refactors, test-only changes, formatting, dependency bumps) unless the user
asks for a complete account.

| Bucket | Use For |
|---|---|
| ✨ New | New features and capabilities |
| 🔧 Improved | Enhancements, performance, UX polish |
| 🐛 Fixed | Bug fixes and corrections |
| 🧱 Behind the scenes | (Optional) infra/refactors, only if asked |

### 3. Translate technical → readable

Convert commit subjects into plain-language outcomes. Lead with what changed for
the reader, not the implementation detail. Merge related commits into one bullet.

### 4. Emit the report

Produce a compact Markdown report. Keep it to what actually shipped in the window;
do not pad. If there are no qualifying commits, say so plainly rather than inventing
entries.

## Output Format

```markdown
# My Update — Week of <Mon DD, YYYY> (last 7 days)

_<N> commits · <repo name> · <author>_

## ✨ New
- <user-facing outcome> (<short-hash>)

## 🔧 Improved
- <user-facing outcome> (<short-hash>)

## 🐛 Fixed
- <user-facing outcome> (<short-hash>)
```

## Quality Gates

- The skill ran **only** because the user asked for their last-week / weekly update
  report — not for a generic changelog or release-notes request.
- Every bullet maps to a real commit in the window; no invented work.
- The window is the last 7 days unless the user explicitly restated it.
- Internal-only commits are excluded unless the user asked for a full account.
- An empty week is reported honestly as "no qualifying commits this week."

## Gotchas

- "Last week" means a rolling 7-day window by default, not the previous calendar
  week. Confirm if the user means the calendar week (Mon–Sun).
- `--author` matches on the configured email; a contributor using multiple emails
  may be undercounted. Fall back to `git shortlog -sne --since="7 days ago"` to
  check identities if a report looks empty.
- Squash-merge workflows collapse many changes into one commit; read the commit
  body (`%b`) when subjects are terse.
