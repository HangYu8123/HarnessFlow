---
name: claude-native-skills-subagents
description: Orchestrate Claude Code bundled skills after implementation. Use only when the main agent is Claude Code or another Claude agent with Claude Code skills available and an implementation report exists.
disable-model-invocation: true
---

# Claude Native Skills Subagents

Use this skill after a code, debug, refactor, or fast workflow implementation step produces an implementation report, such as [implementation report], [bug fix implementation report], or a workflow-specific equivalent.

**Scope:** this skill handles the **`true`** value of the `simplify` / `code_review` headers only — that is, Claude Code's *native bundled* skills. `false` skips, and `local` is served by the pack's own local skills without this wrapper. `_lib/review_skills.md` (resolved by the Pack Path Resolution rule) is the canonical source for all three values; read it first and let it decide whether this skill runs at all.

## Instructions

1. Read and follow `_lib/workflow_contract.md`, `_lib/review_skills.md`, and `philosophy/philosophy.instructions.md`, resolved by the Pack Path Resolution rule.
2. Confirm the current main agent is Claude Code or another Claude agent with Claude Code skills available. If not, stop this skill and continue the parent workflow at the next validation step.
3. Identify all newly created or changed files from the implementation report.
4. Launch the applicable Claude Code bundled skill subagents **all in parallel — including `/simplify`** (see `_lib/workflow_contract.md` §Parallel Execution & Fallback): issue every invocation before waiting on any result. This is a deliberate speed-for-accuracy trade — `/simplify` writes the working tree while the review-only skills read it, so reconcile their findings per `_lib/review_skills.md` §Parallel-review caveats in step 5. If parallel launch is unavailable, degrade to sequential with `/simplify` first. Each launch must follow the Subagent Launch Contract, be grounded to the prompt's `subagent_model` (the same model every other subagent in this workflow uses), and include this model directive verbatim — "**Use the resolved `subagent_model`: when it is a specific model id, run every native-skill subagent on that exact id (a deliberate override — honor it even if it is a smaller model); when it is `inherit` or unset, use the main agent model and do not downgrade.**" — and record a launch receipt or fallback result:
   - `/simplify`: **Run only when the request's `simplify` header is `true`** (per `_lib/review_skills.md`). Pass all newly created or changed files. Ask it to reduce complexity, remove redundancy, and clean up logic without changing behavior. Require a [simplify review].
   - `/code-review`: **Run only when the request's `code_review` header is `true` AND the implementation changed code files** (per `_lib/review_skills.md`). Pass the changed files (the current diff). Ask it to review the diff for correctness bugs and for reuse/simplification/efficiency cleanups. Run **review-only** — do NOT pass `--fix` or `--comment` without explicit user approval (`--comment` posts inline comments to a GitHub PR, an outward action governed by the no-commit safety rule). Require a [code-review report].
5. Review the [simplify review] **(if it was produced)** and, **if it was produced, the [code-review report]**. When both ran, first reconcile them per `_lib/review_skills.md` §Parallel-review caveats (re-anchor findings by file + symbol, re-check anything landing in a region `/simplify` edited, treat direct conflicts as unresolved). Then apply valid simplifications and any clearly-correct, low-risk fixes surfaced by the code review (do not auto-apply uncertain or behavior-changing findings — surface those to the parent workflow instead).
6. Incorporate findings from any other native skill reports that were produced.
7. Return control to the parent workflow at the next validation step.
