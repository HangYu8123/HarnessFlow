# Skill-Workflow Skill Registry

This file is the single source of truth for the **external skills** used by the
`workflow/skill_workflow/` family — a single unified, platform-adaptive family
(one workflow for every model: Claude Code, Codex, and VS Code Copilot), mirroring
`workflow/token_effective_workflow/`. It is a clone of `workflow/token_effective_workflow/`
in which the **instructions for selected steps are replaced by a popular community
skill** instead of inline prose. The high-level steps, step order, subagents, approval
gate, and documentation steps are unchanged.

## Selection rule (what the user asked for)

A step's instructions are replaced **only** when a skill was found in a GitHub
repository with a **verified ≥ 1000 stars** *and* that skill's content was
confirmed to genuinely fit the step. Otherwise the step is left **unchanged**
(its original token-effective instructions are kept verbatim).

## Verification method

Star counts were read directly from the GitHub REST API
(`https://api.github.com/repos/<owner>/<repo>` → `stargazers_count`) and each
cited `SKILL.md` path was confirmed to return HTTP 200. **Verified on
2026-06-16.** Star counts grow over time; re-check before relying on the gate.

**Path notation:** in the workflow files, external skills are cited as
`owner/repo:path/within/repo` (e.g. `obra/superpowers:skills/writing-plans/SKILL.md`).
This is deliberately **not** pack-relative — do not resolve it via Pack Path
Resolution. Install the skill (see *Availability and fallback* below) or fetch
that path from the named GitHub repo; if neither is possible, take the step's
inline fallback.

| Repo | Stars (2026-06-16) | Gate (≥1000) |
|---|---:|:---:|
| `obra/superpowers` | 229,665 | ✅ |
| `davila7/claude-code-templates` | 28,103 | ✅ |
| `Jeffallan/claude-skills` | 9,938 | ✅ |

## Skills used

### `writing-plans` — planning
- **Source:** `obra/superpowers` (229,665★) · `skills/writing-plans/SKILL.md`
- **Trigger:** "Use when you have a spec or requirements for a multi-step task, before touching code."
- **What it does:** Turns a spec/requirements into bite-sized (2–5 min), dependency-ordered tasks with the exact files to touch and a verification step per task.
- **Backs:** Implementation/Refactor planning step.
- **Optional companion:** `skills/brainstorming/SKILL.md` (same repo) for clarifying intent and weighing 2–3 approaches when requirements are ambiguous. Note: `brainstorming` enforces its own user-approval hard-gate; defer that decision to HarnessFlow's opt-in approval gate (`_lib/approval_gate.md`) — do not block on it by default.

### `executing-plans` + `test-driven-development` — implementation
- **Source:** `obra/superpowers` (229,665★) · `skills/executing-plans/SKILL.md`, `skills/test-driven-development/SKILL.md`
- **Triggers:** executing-plans — "Use when you have a written implementation plan to execute … with review checkpoints." test-driven-development — "Use when implementing any feature or bugfix, before writing implementation code."
- **What they do:** `executing-plans` loads the finalized plan, reviews it critically, then executes each task step-by-step with verification. `test-driven-development` enforces the red→green→refactor loop while writing code.
- **Backs:** Implementation step.

### `systematic-debugging` — diagnosis & reproduction
- **Source:** `obra/superpowers` (229,665★) · `skills/systematic-debugging/SKILL.md`
- **Trigger:** "Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes."
- **What it does:** Forces reproduce → isolate → identify root cause (with evidence) before any fix; its first phase is establishing the cheapest reliable reproduction.
- **Backs:** Debug reproduction step (its reproduction phase) and Debug diagnosis step.

### `the-fool` — challenge / devil's advocate
- **Source:** `Jeffallan/claude-skills` (9,938★) · `skills/the-fool/SKILL.md`
- **Trigger:** "Use when challenging ideas, plans, decisions, or proposals using structured critical reasoning. Invoke to play devil's advocate, run a pre-mortem."
- **What it does:** Structured critical-reasoning / pre-mortem pass that surfaces flawed assumptions, overlooked risks, and failure modes.
- **Backs:** The Challenge subagent (replaces the Devil's Advocate task body) in every workflow, and the post-implementation "claim everything is wrong" challenge in the review step.

### `deep-research` — online research report
- **Source:** `davila7/claude-code-templates` (28,103★) · `cli-tool/components/skills/ai-research/deep-research/SKILL.md`
- **Trigger:** "Run autonomous research tasks that plan, search, read, and synthesize information into comprehensive reports."
- **What it does:** Plans a search, runs web searches, reads sources, and synthesizes a cited report — directly producing the `[online resource]` report.
- **Backs:** The Online Research subagent in every workflow.

### `code-reviewer` — correctness analysis
- **Source:** `Jeffallan/claude-skills` (9,938★) · `skills/code-reviewer/SKILL.md`
- **Trigger:** "Analyzes code diffs and files to identify bugs, security vulnerabilities, code smells, N+1 queries, naming issues, and architectural concerns."
- **What it does:** Structured correctness/quality review of files and diffs with severity-rated findings.
- **Backs:** The Correctness Analysis step in the correctness-check workflow.

## Better-skill review (alternatives considered)

A second adversarial pass compared each chosen skill against the strongest
higher-starred alternatives surfaced during discovery — notably
`EveryInc/compound-engineering-plugin` (21,541★, verified 2026-06-16), a
sophisticated multi-persona review/plan/debug suite. **Conclusion: no swaps.**
The chosen skills win on (a) being self-contained single-skill folders (the
EveryInc personas require installing the whole compound-engineering plugin and
its agent files), (b) direct purpose-match, and (c) for the obra/superpowers
set, a designed handoff chain (`writing-plans` → `executing-plans` →
`test-driven-development`) plus far higher adoption.

| Step | Chosen (★) | Strongest alternative (★) | Why the chosen skill was kept |
|---|---|---|---|
| planning | writing-plans (229,665) | ce-plan (21,541) | self-contained; pairs with executing-plans; emits a granular task list |
| implementation | executing-plans + TDD (229,665) | ce-work (21,541) | designed handoff from writing-plans; adds red→green→refactor |
| debug diagnosis | systematic-debugging (229,665) | ce-debug (21,541) | self-contained; most-adopted root-cause-before-fix skill |
| challenge | the-fool (9,938) | ce-doc-review / ce-adversarial-* (21,541) | self-contained; broader scope (challenges plans, diagnoses, answers, reports), not doc-only |
| online research | deep-research (28,103) | ce-web-researcher (21,541) | standalone `SKILL.md` that emits a cited report, not a plugin-bound agent persona |
| correctness audit | code-reviewer (9,938) | ce-code-review (21,541) | reviews whole files (not just large diffs); self-contained |

Repos that surfaced but are **not Agent Skills** (so ineligible to replace a
step's instructions): `github/spec-kit` (CLI toolkit), `LearningCircuit/local-deep-research`
(standalone app), `SuperClaude-Org/SuperClaude_Framework` (framework). If you
later adopt the compound-engineering plugin, `ce-code-review` and `ce-debug` are
strong higher-rigor upgrades for the correctness and debug steps.

## Availability and fallback

These skills are **not vendored** into HarnessFlow (each lives in its own repo
under its own license). To make a step's skill executable, install it once into
the pack's skills directory, e.g.:

```bash
# vendor a single skill folder into the installed pack
git clone --depth 1 https://github.com/obra/superpowers /tmp/superpowers
cp -r /tmp/superpowers/skills/writing-plans .github/HarnessFlow/skills/
```

…or install the source repo via its own documented mechanism (e.g.
`obra/superpowers` as a Claude Code plugin, or `npx claude-code-templates` for
`davila7/claude-code-templates` components).

**Fallback policy:** every replaced step in `skill_workflow/` keeps a
short **"If the skill is not installed, fall back to:"** line carrying the
original token-effective instruction. If a referenced skill cannot be found or
run, perform the fallback and continue — the workflow never blocks on a missing
external skill.

## Attribution

Skills are referenced by name, source repository, and path; their content is
owned by their respective authors under their repositories' licenses. Verify the
license before vendoring any skill into a target repo.
