# Multi-Layer / Nested Repos (cross-repo context)

Canonical rules for cross-layer `repo_info/` context. Read this file only when the target repo
may be multi-layer (`_lib/workflow_contract.md` §Key Context Files points here); single-layer
repos never need it.

A target repo may be multi-layer: it may contain sub-repos (workspace packages, git submodules, vendored repos), or itself be a sub-repo inside an enclosing repo beside adjacent sibling repos — several layers each carrying their own `repo_info/` (resolved per Pack Path Resolution from that layer's root: `<layer>/.github/HarnessFlow/repo_info/` or `<layer>/repo_info/`).

Whenever a workflow says to read [key md files], the main agent must also, **once at context-gathering time**:

1. **Discover layers downward.** Prefer explicit signals at the target repo root — workspace manifests (`package.json` `workspaces`, `pnpm-workspace.yaml`, `Cargo.toml` `[workspace]`) and `.gitmodules` — then a top-down directory scan for `repo_info/` layers that stops descending into any directory identified as a layer and skips `.git/`, `node_modules/`, build outputs, and git-ignored paths. Scan `vendor/`-style directories only one level deep for an explicit `repo_info/` layer: a hand-vendored repo there is a valid layer; package-manager-populated contents are not.
2. **Discover layers upward (adjacent repos).** If the target repo root sits inside an enclosing repo — nearest ancestor containing `.git/` or an installed pack root — include that enclosing layer and its immediate sub-repos (the target's siblings) when they carry their own `repo_info/`. Stop at that first enclosing boundary: never walk higher, and never scan outside it; if no enclosing repo exists, there are no upward layers.
3. **Read only the two overviews per discovered non-target layer:** that layer's `codebase_overview.md` and `scripts_overview.md` (skip its other repo_info files). These count as part of [key md files] for the request and reach subagents through [repo context digest] per §Context Passing, which carries a labeled summary per layer.
4. **Label per layer, additive.** Keep every cross-layer fact attributed to its layer (e.g. `[layer: <relative path>]`); on conflict, the target repo's own repo_info wins.
5. **Bound the sweep, never silently.** If more than 5 layers are discovered, read the ones relevant to [inputs]/the files being changed and list the skipped layers explicitly in the digest/plan.
6. **Pack identity is unaffected.** Discovery never changes Pack Path Resolution or which pack's `workflow/`, `_lib/`, and `philosophy/` govern the request — per `_lib/absolutize_pack_paths.md`, a pack resolves from its own root, never from `git rev-parse --show-toplevel`.
7. **Writes.** Documentation steps write the target repo's own repo_info. If the workflow changed files inside a discovered layer that already has its own repo_info, update that layer's existing repo_info files too. Never create a `repo_info/` in another layer (and, in installed repos, never outside `.github/HarnessFlow/repo_info/`).
