# Local Skill Discovery

**Rule:** Before the main agent drafts a plan (`[plan]`, `[final plan]`, `[bug fix plan]`, `[final bug fix plan]`, `[final pr plan]`, or any workflow equivalent), it must check whether a **local skill** can help the task and, if so, fold that skill into the plan. Record the outcome as **[local skills]**.

## Procedure

1. **Scan the index (cheap).** Read only `skills/index.md` (resolve via Pack Path Resolution). Match each entry's Purpose / Trigger / Keywords against the current task and `[inputs]`. Do not open any `SKILL.md` yet.
2. **Select by trigger, not by capability.** Choose a skill only when its trigger/condition genuinely fits the task. If nothing closely matches, stop and record `[local skills]: none relevant` — do **not** speculatively load a skill.
3. **Skip skills that do not apply at planning time** — e.g. post-implementation/review-only skills such as `claude-native-skills-subagents`, and any skill gated to a platform or condition that is not currently active.
4. **Read the matched skill (only on a confirmed match).** Open the selected `SKILL.md` and extract the methodology/steps relevant to planning. Prefer the single best-matching skill; add another only if it is clearly needed. Follow references inside a `SKILL.md` at most one level deep.
5. **Integrate and record.** Apply the matched skill's methodology to the relevant plan steps, referencing it by name. Record `[local skills]` = the skill(s) chosen and how each is used (or "none relevant"). In multi-subagent workflows, also carry `[local skills]` into the context passed to the planning subagents so their plans use it.

## Notes

- This is **read-only discovery** — it only reads `skills/index.md` and a matched `SKILL.md`, so it applies on every platform (Claude Code, Codex CLI, VS Code Copilot). It does **not** execute any skill; running a skill remains governed by the workflow's own execution/skill steps.
- Keep it lightweight: one small index read, and at most the body of the skill(s) actually matched.
