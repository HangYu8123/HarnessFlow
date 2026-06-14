# Approval Gate
**Rule:** The approval gate is **opt-in only**. By default, workflows proceed directly to implementation without stopping for approval.

**Activate the gate** only when the user's prompt explicitly contains one of:
- `plan:` or `plan only`
- `review first`
- `no file changes`
- `no changes`

When the gate is active, stop after printing the plan and wait for explicit approval (e.g., "implement", "proceed", "go ahead", "approve", "yes") before continuing.

When the gate is **not** active, skip the approval step entirely and proceed straight to implementation.

This gate applies regardless of which CLI tool or IDE is being used.
