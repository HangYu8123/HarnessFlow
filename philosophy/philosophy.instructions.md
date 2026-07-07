Purpose of Subagent Creation: keep the information in the main agent clean and its context window sufficient for finishing the task. A subagent is an actual separate spawned agent invocation governed by `_lib/workflow_contract.md`; inline roleplay by the main agent is fallback work, not subagent output.
Purpose of the Main Agent: The main agent must have high-level information about the task, and a clear overview of the entire workflow. Thus, the main agent must:
1. have sufficient context window for knowing the overall workflow and the big picture of the task
2. have sufficient information for making decisions once the subagents report back
3. manage context window usage to last for the entire task

---

## Subagent Cognitive Modes

- **Focus Mode**: The agent reads only the files and scripts most directly relevant to the task, prioritizing depth over breadth on key files.
- **Broad Mode**: The agent reads through all files in the repo (typically following the pipeline diagram from upstream to downstream), ensuring full coverage.
- **Free Mode**: The agent uses its own judgment to decide which files to read, in what order, and how to process them — no prescribed traversal strategy.



## Parallel Subagent Fallback Protocol

The launch/validate/retry-3×/sequential-degrade/fallback-record protocol for every `[PARALLEL EXECUTION]` directive lives in `_lib/workflow_contract.md` §Parallel Execution & Fallback (canonical single source).
Follow it there — this section deliberately does not restate it.

---

## Approval Gate Principle

All code-modifying workflows (code, debug, refactor, exec, pr, loop) run a two-mode gate: **Plan-only / no-changes** (opt-in via a clearly-delimited trigger phrase — print the finalized plan, stop before any file change) or **Autonomous** (default — proceed end-to-end, no clarification questions).
The operative rule (trigger-phrase list, per-mode behavior) lives in `_lib/approval_gate.md` (canonical; read that file — this section deliberately does not restate it).


KEY PHILOSOPHIES:
---
name: karpathy-guidelines
description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, reviewing, or refactoring code to avoid overcomplication, make surgical changes, surface assumptions, and define verifiable success criteria.
license: MIT
---

# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing (reconciled with the Approval Gate Principle above — "ask" applies in plan-only mode; in autonomous mode, decide and record instead of asking):
- State your assumptions explicitly. If uncertain: in plan-only mode, surface the question with the plan; in autonomous mode (default), make the best reasonable assumption, state it, and proceed.
- If multiple interpretations exist, name them — in plan-only mode present them for the user to choose; in autonomous mode pick the most reasonable one explicitly rather than silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, name what's confusing. In plan-only mode, stop and ask; in autonomous mode, resolve it with the most reasonable assumption and note it.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line must trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
