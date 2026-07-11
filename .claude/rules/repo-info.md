---
paths: [".github/HarnessFlow/repo_info/**"]
---

# Repo Info Rules

Files in `repo_info/` (resolved via Pack Path Resolution: `.github/HarnessFlow/repo_info/` in installed repos, or `repo_info/` from repo root in the source repo) are persistent memory files shared across sessions and workflows.

- Always read these files at the start of any template-triggered workflow
- Update relevant files at the end of code-modifying workflows
- Canonical files: codebase_overview.md, scripts_overview.md, update_logs.md, known_issues.md, past_Q&A.md, past_Correctness_Check.md, update_logs_auto_generated.md, known_issues_auto_generated.md
- Do not create alternate history filenames
- Multi-layer repos: sub-repos and enclosing/adjacent repos may carry their own `repo_info/` — read their `codebase_overview.md` + `scripts_overview.md` as labeled cross-layer context per `_lib/workflow_contract.md` §Key Context Files → Multi-Layer / Nested Repos (read-only unless that layer's files were changed; never create `repo_info/` in another layer)
