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
4. Launch the applicable Claude Code bundled skill subagents in parallel. Each launch must follow the Subagent Launch Contract, include "**Use the exact same model as the main agent — do not downgrade.**", and record a launch receipt or fallback result:
   - `/simplify`: Always run. Pass all newly created or changed files. Ask it to reduce complexity, remove redundancy, and clean up logic without changing behavior. Require a [simplify review].
   - `/code-review`: Run when the implementation changed code files. Pass the changed files (the current diff). Ask it to review the diff for correctness bugs and for reuse/simplification/efficiency cleanups. Run **review-only** — do NOT pass `--fix` or `--comment` without explicit user approval (`--comment` posts inline comments to a GitHub PR, an outward action governed by the no-commit safety rule). Require a [code-review report].
   - `/batch` *(only if available in this environment)*: when the implementation requires structurally similar changes across more than 5 files. Require a [batch execution report]. If `/batch` is unavailable, skip it.
   - `/claude-api`: Run only when the target functionality integrates Claude, Anthropic APIs, or another AI/LLM service. Require an [api integration review].
   - **Diagnosis** (when scripts or tests fail after the implementation step): spawn a Focus Analyst diagnosis subagent (`agents/focus-analyst.agent.md`) that re-runs the failing path with verbose output and reads stderr/tracebacks. Require a [debug diagnosis report]. (Do not invoke a `/debug` skill — it is not a standard Claude Code skill.)
5. Review the [simplify review] and [code-review report]; apply valid simplifications and any clearly-correct, low-risk fixes surfaced by the code review (do not auto-apply uncertain or behavior-changing findings — surface those to the parent workflow instead).
6. Incorporate findings from any other native skill reports that were produced.
7. Return control to the parent workflow at the next validation step.
