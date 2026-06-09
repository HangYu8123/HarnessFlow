# Fast-Tier Execution Rules (Claude Code)

Shared rules for every `workflow/claudecode_token_effective_workflow/*.instructions.md` file. Resolve this path via Pack Path Resolution. These rules make the fast tier genuinely lean; each workflow file references them instead of restating them.

The fast tier optimizes for the **common case**: a reasonably scoped task on a known codebase. Spend subagents only where they change the outcome.

---

## 1. No Broad Analyst
The fast tier **never** spawns the Broad Analyst. Planning/analysis uses **at most 2 analysts** (Focus and/or Free). For narrowly-scoped `[inputs]` (≤ ~3 named files, or a single function/script), a **single analyst — or the main agent reading directly — is enough**; do not fan out. When full-pipeline coverage is genuinely required (whole-repo correctness check, repo initialization), use a **Free Analyst** (it may traverse upstream→downstream by its own judgment) or the main agent — not Broad.

## 2. No separate review / QA subagents
The fast tier does **not** spawn **Senior Engineer, Principal Engineer, or QA Engineer**. The **main agent** performs plan review, code review, validation, and any user-requested script/pipeline runs **directly**. Spawn the Implementer/Executor for the change itself (to keep the main context clean); the main agent reviews the result.

## 3. No redundant merge
With one analyst there is nothing to "combine across three drafts and reject redundant parts." The main agent reviews the single result, reads any gaps directly, and drafts the plan/answer. Only merge when more than one analyst actually ran.

## 4. Online Researcher — conditional
Spawn **only** when the task needs information that is not in the repo: a new external dependency / package / API, an unfamiliar error string, a version-compatibility question, or an explicit "research / best practice" request from the user. For routine internal work, **skip it** (it would return `status: blocked, reason: no external need`).

## 5. Devils Advocate — conditional, explicit triggers
Spawn **only** when ANY of these hold; otherwise the main agent does the adversarial pass inline as part of its review:
- the change touches more than ~5 files, or
- it modifies shared / upstream / public-interface code, or
- it is security-, data-loss-, or migration-sensitive, or
- the main agent's own review surfaced a real, open risk.

Per-workflow, the trigger is **default-on** where a wrong call is expensive: refactor (silent regressions), debug (wrong root cause), exec (destructive/irreversible commands), pr (broken/incomplete stack), whole-repo correctness (false positives).

## 6. `/simplify` native skill
Mandatory for code-modifying flows (**code, debug, refactor**) via `skills/claude-native-skills-subagents/SKILL.md`. **Conditional** for **exec** and **pr** — run it only if source files were actually edited (a pure command run or a PR re-org that authors no new logic has nothing to simplify).

## 7. Keep concrete
When a step says "spawn if risky / if unclear / if needed," resolve it against the concrete triggers above (file counts, change types, external-info needs) — not a vague vibe — so the fast tier neither always-spawns (no savings) nor never-spawns (quality loss).
