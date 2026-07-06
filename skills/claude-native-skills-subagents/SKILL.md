---
name: claude-native-skills-subagents
description: Orchestrate Claude Code bundled skills after implementation. Use only when the main agent is Claude Code or another Claude agent with Claude Code skills available and an implementation report exists.
disable-model-invocation: true
---

# Claude Native Skills Subagents

Use this skill after a code, debug, refactor, or fast workflow implementation step produces an implementation report, such as [implementation report], [bug fix implementation report], or a workflow-specific equivalent.

## Instructions

1. Read and follow `_lib/workflow_contract.md` and `philosophy/philosophy.instructions.md`, resolved by the Pack Path Resolution rule.
2. Confirm the current main agent is Claude Code or another Claude agent with Claude Code skills available. If not, stop this skill and continue the parent workflow at the next validation step.
3. Identify all newly created or changed files from the implementation report.
4. Launch the applicable Claude Code bundled skill subagents, running `/simplify` first (it applies edits to the working tree) so the review-only skills that follow read the resulting diff; `/code-review` and any other applicable review-only skills may then run in parallel with each other. Each launch must follow the Subagent Launch Contract, be grounded to the prompt's `subagent_model` (the same model every other subagent in this workflow uses), and include this model directive verbatim — "**Use the resolved `subagent_model`: when it is a specific model id, run every native-skill subagent on that exact id (a deliberate override — honor it even if it is a smaller model); when it is `inherit` or unset, use the main agent model and do not downgrade.**" — and record a launch receipt or fallback result:
   - `/simplify`: Always run. Pass all newly created or changed files. Ask it to reduce complexity, remove redundancy, and clean up logic without changing behavior. Require a [simplify review].
   - `/code-review`: **Opt-in — run only when the request's `code_review` header is `true` AND the implementation changed code files; when `code_review` is `false`, absent, or unset (the default), skip `/code-review` entirely and leave [code-review report] unproduced (`/simplify` still runs regardless).** Pass the changed files (the current diff). Ask it to review the diff for correctness bugs and for reuse/simplification/efficiency cleanups. Run **review-only** — do NOT pass `--fix` or `--comment` without explicit user approval (`--comment` posts inline comments to a GitHub PR, an outward action governed by the no-commit safety rule). Require a [code-review report].
5. Review the [simplify review] and, **if it was produced, the [code-review report]** (it is absent whenever `code_review` is not `true`); apply valid simplifications and any clearly-correct, low-risk fixes surfaced by the code review (do not auto-apply uncertain or behavior-changing findings — surface those to the parent workflow instead).
6. Incorporate findings from any other native skill reports that were produced.
7. Return control to the parent workflow at the next validation step.
