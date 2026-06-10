# Fast-Tier Execution Rules (Claude Code)

Shared rules for every `workflow/claudecode_token_effective_workflow/*.instructions.md` file. Resolve this path via Pack Path Resolution. These rules make the fast tier genuinely lean; each workflow file references them instead of restating them.

The fast tier optimizes for the **common case**: a reasonably scoped task on a known codebase. Spend subagents only where they change the outcome.

---

## 1. No Broad Analyst
The fast tier **never** spawns the Broad Analyst. Planning/analysis uses **at most 2 analysts** (Focus and/or Free). For narrowly-scoped `[inputs]` (≤ ~3 named files, or a single function/script), a **single analyst — or the main agent reading directly — is enough**; do not fan out. When full-pipeline coverage is genuinely required (whole-repo correctness check, repo initialization), use a **Free Analyst** (it may traverse upstream→downstream by its own judgment) or the main agent — not Broad.

## 2. No separate review / QA subagents
The fast tier does **not** spawn **Senior Engineer, Principal Engineer, or QA Engineer**. The **main agent** performs plan review, validation, and any user-requested script/pipeline runs **directly**; code review runs via the native review skills (§6) — the fast tier eliminates review *subagents*, never the review itself.

Implementation: for **code/debug/refactor** changes of ≤ ~5 files and ≤ ~300 expected edited lines, the **main agent implements directly**. Above either threshold (intentionally the same "big change" bar as §5), or when the main context is already heavily consumed, spawn the **Implementer** (`agents/implementer.agent.md`; model verification per `_lib/workflow_contract.md` §Implementer Model Verification Fallback). **Exec** always uses the Executor (noisy command output is exactly the context risk subagents exist for) and **pr** always uses the Implementer (stack execution).

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

## 6. Native review skills (`/simplify` + `/code-review`)
**Mandatory** for code-modifying flows (**code, debug, refactor**) via `skills/claude-native-skills-subagents/SKILL.md`. **Conditional** for **exec** and **pr** — run only if source files were actually edited. Not run for query/correctness/initialize (no code diff). Review is **never silently skipped**.

Run as one sequential pass:
1. `/simplify` first — it applies its own behavior-preserving cleanups → [simplify review].
2. `/code-review` on the resulting diff, **review-only** (pass neither `--fix` nor `--comment`) at **medium effort** (fewer, high-confidence findings; the session default is high — never use `ultra`/`ultrareview` in the fast tier: it is a cloud run billed separately) → [code-review report].
3. The main agent applies the clearly-correct, low-risk findings in **one editing pass** and defers uncertain or behavior-changing findings to the final summary.

**Fallback chain when the native `/code-review` skill is unavailable:**
1. With explicit user approval, find and use a reputable community review skill from online — e.g. `requesting-code-review` from obra/superpowers (Anthropic plugin marketplace) or review the diff against the karpathy-guidelines skill criteria (github.com/forrestchang/andrej-karpathy-skills, MIT). Prefer a user-level install (`~/.claude/skills`); never write skill files into the repo. If approval cannot be obtained (e.g. headless run) or the search fails, fall through.
2. Embedded self-review — always available, no approval needed: the main agent reviews the full diff against the Karpathy Guidelines in `philosophy/philosophy.instructions.md` plus the checklist below.

Record which tier ran in [code-review report].

**§6 validation checklist** — applied by the main agent's final validation in **every** code-modifying run (not only the fallback): (1) new public functions/classes have docstrings; (2) file/path/user inputs are validated or guarded; (3) I/O and external calls handle failure; (4) empty/None/zero/boundary cases behave; (5) callers/callees still integrate (signatures, imports, return shapes); (6) no secrets, debug prints, or dead code introduced by this change.

## 7. Keep concrete
When a step says "spawn if risky / if unclear / if needed," resolve it against the concrete triggers above (file counts, change types, external-info needs) — not a vague vibe — so the fast tier neither always-spawns (no savings) nor never-spawns (quality loss).
