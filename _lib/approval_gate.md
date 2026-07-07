# Approval Gate

The gate runs in exactly **one of two modes**. Decide the mode **once, at the start of the workflow**, by inspecting the user's prompt — then enforce it at the plan step.

## Mode selection

**Mode 1 — Plan-Only / No-Changes (gate ACTIVE).** Choose this mode when the user's prompt explicitly contains any of (case-insensitive substring match):
- `plan:` · `plan only` · `planning only` · `only plan` · `just plan`
- `no file changes` · `no changes` · `without changes` · `do not make changes` · `don't change any files`
- `review first`
- `dry run` · `dry-run`

**Delimitation rule (deterministic):** a trigger phrase counts only when it is **clearly delimited** — it stands alone (e.g. a `plan:` header line), sits at a clause boundary (start/end of the prompt, a line, or a clause set off by punctuation), or closes its request (followed only by closers such as "first", "for now", "please", or "before implementing / before any changes"). A trigger does **not** count when it is embedded mid-clause with its own object while the same prompt goes on to request implementation, or when it appears only inside quoted/reported text. Examples that activate Mode 1: "Let's do a dry run first", "Can you review first before implementing?", a prompt starting with `plan:`. Examples that do not: "let's review first the auth module, then implement" (mid-clause, prompt continues to implementation); a bug description quoting the words "review first".

**Mode 2 — Autonomous (gate INACTIVE) — DEFAULT.** Any prompt that does not contain a clearly-delimited Mode 1 trigger runs in this mode.

When the signal is genuinely ambiguous, default to **Mode 2** — the gate is opt-in.

> **Hard enforcement (optional):** on every platform these instructions are guidance, not a deterministic guarantee. Teams that need Mode 1 to hold every time can add a platform-level guard — e.g. a Claude Code hook that blocks file-writing tools while the request carries a plan-only trigger (per the official hooks guide, hooks give deterministic control instead of relying on the model to comply).

## Mode 1 — Plan-Only / No-Changes

Run the full **read-only** planning pipeline (analysis and planning subagents do not modify files). Then **stop before any file change**:

1. Print the finalized plan.
2. Make **zero** modifications to any file — do **not** spawn the Implementer / Executor and do **not** run any file-writing, `/simplify`, or doc-update (`update_logs.md`, `codebase_overview.md`, …) step.
3. Wait for **explicit** approval ("implement", "proceed", "go ahead", "approve", "yes"). Only after approval, resume at the implementation step.

If something is unclear, surface the question together with the plan instead of guessing.

## Mode 2 — Autonomous (default)

Proceed end-to-end without stopping for approval. Critically:

- **Do not ask clarification questions.** Resolve ambiguity yourself by choosing the most reasonable interpretation — the model decides scope, design, and trade-off choices itself.
- **Record assumptions, don't block on them.** State each material assumption in one line in the printed plan, then keep going.
- Run the full workflow through implementation, review, and verification without pausing.
- **Only** pause for the user when proceeding would require an action that the request and `_lib/safety_rules.md` do not already cover — an irreversible/destructive or outward-facing action (e.g., committing/pushing to git, deleting user data, publishing to a network service). For everything else, decide and continue.

## Nested-skill approval language

Some workflows load a skill that carries its own approval wording — e.g. the `breakdown-pr` skill's "Execute Only After Approval", "the user explicitly approves the exact plan", "stop for approval", or "ask before execution". That language maps onto **this single two-mode gate**; it does **not** add a second, independent approval stop.

- **Mode 1 (Plan-Only):** the skill's stop-for-approval behavior coincides with the gate — print the plan and stop before any file change.
- **Mode 2 (Autonomous):** the gate is already satisfied. Run the skill's **reversible local** steps (e.g. creating local branches and commits) without a second approval, and resolve the skill's "ask if ambiguous" points (base branch, target branch, stack tool, inclusion of uncommitted changes, …) **yourself** by the most reasonable interpretation — record each as a one-line assumption (e.g. in the skill's `Assumptions:` output field) instead of asking. Pause **only** at the genuinely outward-facing/irreversible action the skill performs (git push / PR submission), per Mode 2 and `_lib/safety_rules.md`.

This gate applies regardless of which CLI tool or IDE is being used.
