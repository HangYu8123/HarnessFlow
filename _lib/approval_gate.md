# Approval Gate
**Rule:** The workflow **always stops after printing the plan** and waits for user approval before proceeding to implementation. The workflow continues to the implementation step only when the user explicitly approves (e.g., "implement", "proceed", "go ahead", "approve", "yes").

If the user requests no code changes (e.g., "plan only", "just show me the plan"), the workflow stops after printing the plan and does not prompt for approval.

This gate applies regardless of which CLI tool or IDE is being used.
