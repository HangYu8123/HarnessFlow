---
paths: [".github/HarnessFlow/repo_info/**"]
---

# Repo Info Rules

Files in `repo_info/` (resolved via Pack Path Resolution: `.github/HarnessFlow/repo_info/` in installed repos, or `repo_info/` from repo root in the source repo) are persistent memory files shared across sessions and workflows.

- Always read these files at the start of any workflow
- Update relevant files at the end of code-modifying workflows
- Canonical files: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md, past_Correctness_Check.md, update_logs_auto_generated.md, known_issues_auto_generated.md
- Do not create alternate history filenames
