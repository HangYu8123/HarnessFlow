# Documentation Logging — Timestamps, IDs, and the update_logs Two-File Rule

Canonical rules for every documentation step that writes a `repo_info/` log entry
(`update_logs.md`, `past_Q&A.md`, `past_Correctness_Check.md`). The main agent reads this file
at the documentation step, not earlier (`_lib/workflow_contract.md` §Key Context Files points here).

## Log Entry Timestamps

Every documentation entry template (update_logs.md, past_Q&A.md, past_Correctness_Check.md) carries a timestamp element immediately before its ID/number element, format `YYYY-MM-DD HH:MM` (24-hour, local time).

- Obtain it from the system clock at write time — `date '+%Y-%m-%d %H:%M'` (POSIX-portable) or your platform shell's equivalent. Never write a guessed time.
- If no shell/clock is available, use the environment-provided current date and write the date only (`YYYY-MM-DD`) — never invent the time of day. If no reliable current date is available either, omit the timestamp element entirely.
- The timestamp is never an ID. Determine the "last ID" per the workflow's own ID rule, reading prior entries' IDs at their labeled position (in banner-style Q&A / Correctness Check entries: the number after the em-dash, or after the colon in older entries without timestamps); ignore timestamp digits and positional numbers such as "PR 1/5". Entries written before this convention (no timestamp) remain valid.

## update_logs — Two-File Rule

- `update_logs.md` (live, part of [key md files]) holds only the **10 most recent** entries.
- `repo_info/update_logs_all.md` holds the **complete history** — every entry ever written, **newest first**. It is **not** part of [key md files] and is **not** read by default: open it only when the task actually depends on history older than the live file — e.g. a debug or query whose subject is a change `update_logs.md` no longer records, or a refactor that needs the rationale of an older decision.
- **Writing a new entry (both files):** append it to `update_logs.md` (newest at the bottom, that file's order) **and** insert the same entry at the top of `update_logs_all.md`'s entry list. If `update_logs.md` then exceeds 10 entries, delete its oldest entries — they are already preserved in `update_logs_all.md`. No move step is needed.
- **IDs continue across both files.** Determine "last ID" from the live `update_logs.md`, which always holds the newest entry.
- **Migration (one-time, idempotent):** if `repo_info/update_logs_archive.md` still exists (installs predating the two-file rule), fold its entries into `update_logs_all.md` — create `update_logs_all.md` from the live file's entries plus the archive's, all newest-first — then delete the archive file. The archive's absence is the completion marker; never fold twice.
