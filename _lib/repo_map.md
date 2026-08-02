# Repo Overviews — Token Budgets and the Ranked Repo Map

Canonical for how `repo_info/codebase_overview.md` and `repo_info/scripts_overview.md` are sized,
and how the scripts overview is generated. Read by the initialize workflows and by any step that
updates either overview (`_lib/workflow_contract.md` §Key Context Files points here).

## Token Budgets

- `codebase_overview.md`: **≤ 4k tokens** (≈16k characters; estimate tokens as characters/4).
- `scripts_overview.md`: **≤ 4k tokens**; **≤ 8k** only when the repo is **super-large** (> 2,000 source files or > 1M LOC).
- These are HarnessFlow's own budgets, not an upstream citation (Aider's repo map defaults to 1k tokens; 4k/8k is a deliberately higher ceiling because these overviews carry prose summaries, not signatures alone).
- **At update time:** any step that updates an overview must keep it within budget — condense prose (codebase overview) or drop the lowest-ranked entries first (scripts overview). Never exceed the budget to preserve detail; full detail lives in the code itself.

## Scripts Overview — Ranked Repo Map (Aider-style)

Generate `scripts_overview.md` by symbol ranking with a budget fit, not by exhaustive folder-by-folder prose:

1. **Extract symbols.** For each source file, list its definitions (functions, classes, methods, exported constants) and the identifiers it references. Use the best extractor the environment already provides, in preference order: tree-sitter (def/ref tag queries) or universal-ctags when installed; otherwise language-aware grep and targeted reading. The map is a prioritization heuristic — approximate extraction is acceptable; never install new tooling just for this step.
2. **Rank by reference-graph centrality (PageRank-style, as in Aider's repo map).** Build a graph in which a file that references an identifier points to the file defining it; files and symbols referenced from many distinct files rank higher, and ranking is personalized toward files named in [inputs] when present. A plain distinct-referrer count is an acceptable approximation when graph computation is impractical.
3. **Render, highest rank first, grouped by file.** For each included file: one high-level summary line, its key definition signatures (compact snippet lines), and a one-line dependency note. This keeps the semantic value of prose summaries while the ranking decides *what* earns space.
4. **Fit the budget by bisection.** Binary-search the ranked list for the largest prefix whose rendered output fits the token budget (allow ~15% overshoot during the search, then step down under budget). Files below the cut get at most a terminal one-line index (path + role in 5–10 words) if space allows, else are omitted.
5. **Non-code / docs-heavy repos:** treat files as the symbols — rank them by how many other files reference them (links, pointers, includes) — and apply the same rendering and budget.
6. **Re-initialization:** re-rank against the current code and diff-update per `_lib/reinitialize.md` — preserve confirmed summaries for files still above the cut; never blank-and-rewrite.

The codebase overview keeps its existing form (pipeline diagram + architecture description), fitted under its own budget.
