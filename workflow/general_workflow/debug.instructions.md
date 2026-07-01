---
name: 'Debug Workflow'
description: 'Instructions for debugging and fixing bugs'
---
# debug instructions

<!-- Required Context Files (CLI-resolvable paths):
  - philosophy/philosophy.instructions.md
  - _lib/safety_rules.md
  - _lib/workflow_contract.md
  - _lib/approval_gate.md
  - repo_info/codebase_overview.md
  - repo_info/scripts_overview.md
  - repo_info/update_logs.md
  - repo_info/known_issues.md
-->

**Safety: follow `_lib/safety_rules.md`.**

> **Unified workflow (platform-adaptive).** This single file serves Claude Code, Codex, and VS Code Copilot. Resolve all paths via Pack Path Resolution (`.github/HarnessFlow/<path>` when installed, or `<path>` from the repo root). Launch subagents using your platform's mechanism per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation. Handle repo-context handoff per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code** the main agent builds a condensed **[repo context digest]** and passes it inline to subagents; on **Codex** and **VS Code Copilot**, subagents read **[key md files]** directly.

[inputs]:
input 1: target bug
input 2: suspected reasons (optional)
input 3: important scripts (optional)


**read through this entire file and follow the instructions carefully**.
Before doing any workflow-specific work, the main agent must read and follow [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) and [`philosophy/philosophy.instructions.md`](../../philosophy/philosophy.instructions.md) before proceeding.
Every subagent created by this workflow must also read and follow those two files before reading [key md files] or performing task-specific work.

Subagent launch rule: Follow the Subagent Launch Contract in [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md).

> **Subagent invocation:** See [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation.

When asked to debug, always first read the following files from `repo_info/` (REFER AS [key md files]):
1. codebase_overview.md
2. scripts_overview.md
3. update_logs.md
4. known_issues.md
Understand the structure of the repo, functions inside each script, previous update, and previous bug fix attempts. **KEEP THESE IN THE MEMORY**.

Understand them. Then, per [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Context Passing for Subagents: on **Claude Code**, create a condensed **[repo context digest]** — a concise bullet-point summary covering: codebase structure/pipeline, key scripts and their roles, recent changes, and active known issues — and pass it inline to every subagent; on **Codex** and **VS Code Copilot**, keep [key md files] for subagents to read directly.


**Local Skill Discovery (before any plan drafting):** Perform Local Skill Discovery per `_lib/local_skill_discovery.md` — scan `skills/index.md` for any local skill whose trigger fits [inputs]/the task; on a confirmed match, read its `SKILL.md`. Keep the result as [local skills], fold it into the repo context (per §Context Passing) so every planning subagent receives it, and integrate it when the main agent drafts its final plan. If nothing matches, record [local skills]: none relevant.

#CREATE ONE TODO FOR EACH OF THE FOLLOWING STEPS
Then, the main agent must, **CREATE ONE TODO FOR EACH STEP**:

**(Optional) Bug Reproduction** *(this step is **skipped by default**; only run it if `reproduce: true` is set in the debug request)*: Before starting any analysis, the main agent spawns a **Bug Reproducer** subagent (`agents/bug-reproducer.agent.md`). The subagent must: (1) read [key md files] and [inputs] to identify the target scripts and entry points associated with the bug; (2) run those scripts in the correct order per `scripts_overview.md` to exercise the bug path; (3) capture all output (stdout, stderr, exit codes, error messages, tracebacks); (4) summarize whether the bug was reproduced, what output was observed, and any relevant runtime state; (5) return the summary to the main agent as **[reproduction report]**. The main agent stores [reproduction report] and passes it to all subsequent analysis subagents.

0. the main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`), pass [inputs] and the repo context (per §Context Passing) to the subagent. The subagent checks if the bug has previously been addressed or fixed based on the repo context (per §Context Passing). If a previous attempt exists, the subagent follows the codebase diagram from codebase_overview.md and goes through all scripts associated with the previous fix attempts. Then, combining the current bug information, the subagent infers why the bug is not fixed, and reports back to the main agent.

1. the main agent creates three subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** (**Focus Analyst** via `agents/focus-analyst.agent.md`; **Broad Analyst** via `agents/broad-analyst.agent.md`; **Free Analyst** via `agents/free-analyst.agent.md`), pass [inputs] and the repo context (per §Context Passing) to the three subagents. Then:
a. the **Focus Analyst** focuses on the important scripts and suspected reasons, reads through those scripts, checks the potential reasons for the bug from the perspective of those scripts and suspected reasons, and reports back to the main agent as [bug reason 1].
b. the **Broad Analyst** follows the pipeline diagram from [key md files], reads through all scripts from upstream of the diagram to downstream of the diagram, checks the potential reasons for the bug from a broader perspective, and reports back to the main agent as [bug reason 2].
c. the **Free Analyst** decides what files to read and what scripts to check, following its own logic, checks the potential reasons for the bug from a completely free perspective, and reports back to the main agent as [bug reason 3].

1.5. **Diagnosis (platform-conditional):**
- **If the main agent is Claude Code:** create a **Diagnosis subagent** (`agents/focus-analyst.agent.md`, diagnosis mode): pass the bug description, suspected reasons, and the repo context (per §Context Passing) to this subagent. The subagent re-runs the suspected code path with verbose/debug flags where possible and reads the actual stdout/stderr/tracebacks (and any existing log output) to identify exactly what went wrong, producing concrete evidence to supplement the analysis from step 1. (Do not rely on a `/debug` skill — it is not a standard Claude Code skill.) Report back a [debug log analysis] to the main agent.
- **Otherwise (Codex or VS Code Copilot):** the main agent reviews the relevant error output, stack traces, and any existing logs manually to reach the same diagnosis, and documents the root causes as [debug log analysis].

2. the main agent must read through all three reports ([bug reason 1], [bug reason 2], and [bug reason 3]) from step 1, [debug log analysis] from step 1.5, and [reproduction report] if it exists. Read necessary files, understand each report, examine all pointed-out potential reasons, combine the insights of each report, reject the redundant or incorrect parts of each report, and draft a precise and verified correct report to address the potential reasons for the bug as [bug info].

3. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, pass [bug info], the original bug description, and the repo context (per §Context Passing) to the subagents.

a. The **Devils Advocate** receives the repo context (per §Context Passing) from the main agent, then critically challenges [bug info] — looking for overlooked root causes, misattributed blame, or incorrect assumptions. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** receives the repo context (per §Context Passing) from the main agent and [bug info], then identifies extra needs for skills, tools, packages, logs, error messages, or external references. The subagent MUST actually call its platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs it fetched as proof — see `agents/online-researcher.agent.md`. The subagent reports the findings from online back to the main agent as [online resource].

3.5. The main agent incorporates [valid criticisms] and [online resource], and updates [bug info] accordingly.

4. the main agent creates a **Focus Analyst** subagent (`agents/focus-analyst.agent.md`) in plan mode, pass [inputs], [bug info], and the repo context (per §Context Passing) to the subagent. Then based on the bug information and the repo structure from the repo context (per §Context Passing), read all scripts that could be associated with the bug. Then, the subagent must draft a plan that can fix the bug while maintaining the entire codebase behavior, while maintaining stability, and NO repeat of any known issues/bugs in known_issues.md. then the subagent feeds the plan back to the main agent as [bug fix plan].

5. the main agent creates a **Senior Engineer** subagent (`agents/senior-engineer.agent.md`), pass [bug fix plan], [bug info], and the repo context (per §Context Passing) to this subagent. The subagent reads associated scripts in this repo. If the plan involves any repo outside this repo, go to that repo, if there are codebase_overview.md and scripts_overview.md, read through them too. Then the subagent reviews the plan from a senior staff engineer perspective, assesses the plan's correctness and feasibility, and makes sure that the plan can effectively fix the bug without breaking the current codebase. feed the review back to the main agent as [bug fix plan review].

6. the main agent reviews [bug fix plan] and [bug fix plan review] from step 4 and step 5. If the plan or the review involves any other repos, go to those repos, read their codebase_overview.md and scripts_overview.md if they exist, and keep those in the memory. Finally, combine all that information and draft a final plan that is feasible, stable, and verified against existing tests and behavior as [final bug fix plan].

6.5. the main agent creates two subagents: **Devils Advocate** (`agents/devils-advocate.agent.md`) and **Online Researcher** (`agents/online-researcher.agent.md`) **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]**, pass [final bug fix plan], [bug info], and the repo context (per §Context Passing) to the subagents.

a. The **Devils Advocate** receives the repo context (per §Context Passing) from the main agent and reads all relevant scripts, then critically challenges [final bug fix plan] — looking for overlooked side effects, integration risks, incorrect assumptions about the codebase, or potential regressions. The subagent reports any flaws back to the main agent as [valid criticisms].

b. The **Online Researcher** receives the repo context (per §Context Passing) from the main agent and [final bug fix plan], then identifies extra needs for skills, tools, and packages. The subagent MUST actually call its platform's live web search/fetch tool(s) to search the live internet (never answer from prior knowledge) and MUST return the source URLs it fetched as proof — see `agents/online-researcher.agent.md`. The subagent reports the findings from online back to the main agent as [online resource].

6.75. The main agent incorporates [valid criticisms] and [online resource], and updates [final bug fix plan] accordingly.

7. Then, the main agent must print the updated [final bug fix plan], so the user can review it. **Approval gate:** See `_lib/approval_gate.md`.

8. the main agent creates an **Implementer** subagent (`agents/implementer.agent.md`), pass [final bug fix plan], [bug info], and the repo context (per §Context Passing) to the subagent. **Implementer Model Verification:** See [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Implementer Model Verification Fallback (on Claude Code the main agent launches the Implementer on the specified `subagent_model` — a specific id even if smaller, else the inherited session model; no retry loop). The subagent (or the main agent, if falling back) receives the repo context (per §Context Passing) from the main agent. Then based on [bug info], [final bug fix plan], and the repo structure from the repo context (per §Context Passing), read all scripts that could be associated with the bug and the plan. Then implement [final bug fix plan] and fix the bug accordingly. feed an implementation report (just what has been changed, no explanation why it would fix bug) to the main agent as [bug fix implementation report].

8.5. **Post-implementation review (platform-conditional):**
- **If the main agent is Claude Code (or another Claude agent with Claude Code skills available):** search `skills/index.md` for `claude-native-skills-subagents`, then use the skill at [`skills/claude-native-skills-subagents/SKILL.md`](../../skills/claude-native-skills-subagents/SKILL.md) after step 8. (That skill runs `/simplify` automatically — do not invoke it separately.)
- **Otherwise (Codex, or VS Code Copilot without Claude Code skills):** skip the skill; instead, the main agent performs a manual complexity review of all changed files before proceeding.

9. the main agent creates two subagents and **[PARALLEL EXECUTION — launch the listed subagents in parallel using your platform's subagent mechanism (see [`_lib/workflow_contract.md`](../../_lib/workflow_contract.md) §Subagent Invocation); if parallel launch is unavailable, run them sequentially — sequential execution produces equivalent results]** (**Senior Engineer** via `agents/senior-engineer.agent.md`; **QA Engineer** via `agents/qa-engineer.agent.md`). Then:
a. the main agent must pass [final bug fix plan], [bug fix implementation report], [bug info], [inputs], and the repo context (per §Context Passing) to the **Senior Engineer** subagent. The subagent receives the repo context (per §Context Passing) from the main agent and checks all the code changes in the repo. Then the subagent reviews the code changes and the implementations for bug fixing from a senior staff engineer perspective, assess the bug fix correctness, challenge the implementation, question the effectiveness of the implementation, and make sure that the bug fix implementations achieve the intended fix without breaking the current codebase. Then the subagent must generate an [implementation code review report] and then feed the review back to the main agent as [implementation code review report].

b. the main agent must pass [final bug fix plan], [bug fix implementation report], [bug info], [inputs], and the repo context (per §Context Passing) to the **QA Engineer** subagent. The subagent receives the repo context (per §Context Passing) from the main agent and checks all the code changes in the repo. Then the subagent reads through the entire repo pipeline, validate the bug fix from a QA engineer perspective. Based on the validation, the subagent must generate an [implemented bug fix code QA report]. If the user has requested to actually **run the scripts**, the subagent must run through the entire codebase pipeline based on codebase_overview.md and scripts_overview.md from upstream to downstream, and validate if the entire repo still performs correctly and if the newly implemented bug fixes perform as expected without errors. Then, the subagent must update [implemented bug fix code QA report] based on the running results, and then report [implemented bug fix code QA report] back to the main agent as [implemented bug fix code QA report].


10. the main agent must read through [final bug fix plan], [bug fix implementation report], [implementation code review report], [implemented bug fix code QA report], and [inputs], then understand the bug fixes, the implementation, and the changes to the codebase. Then, the main agent must accordingly update codebase_overview.md and scripts_overview.md based on the newly implemented bug fixes and the actual code changes (including the failures based on [implementation code review report] and [implemented bug fix code QA report]).

11. the main agent must summarize the bug fix in the following format:
{=============================BUG FIX===============================}
{BUG Name (very high level description of the bug) and Bug Id (assign a number in order, i.e., plus 1 to the last bug id)}
{Bug description (one or two sentences of description of what the bug is)}
{Repo involved (what local repos are involved)}
{Implementation ( what has been changed to fix the bug)}
{Fixed (whether the bug has been fixed, if not fixed, what is the gap)}

12. write the summary to update_logs.md. do not add additional contents, just the bug fix report from previous step. If the bug is a recurring issue that has been attempted and failed to fix multiple times, also write to known_issues.md in the following format:
{Problem Title}
a. What was not fixed: (a brief explanation of what remains broken)
b. Last attempt summary: (a brief summary of the last fix attempt)
c. Why the last fix failed: (a brief analysis of why the previous fix failed, including what mistakes the coding agent made)
d. Current fix: (a brief description of the current fix being applied)

13. In addition, the main agent must summarize [final bug fix plan], the [bug fix implementation report], the [implementation code review report], and [implemented bug fix code QA report] in bullet points and write them to the chat.
