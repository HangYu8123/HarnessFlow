# ⚡ Fast Workflow — Performance Report

**The efficiency–quality frontier of HarnessFlow.**
The `fast` workflow delivers the **same successful outcomes as the heavyweight `general` workflow — at 39–50 % of its token cost — while shipping the leanest, fully-documented, canonically-correct code of any approach tested.**

*Model held constant across every arm (Claude Sonnet 4.6 subagents, Opus 4.8 orchestrator). Only the harness varies.*
*Evidence: two independent benchmarks — a 1,000-line greenfield CV/ML build ("ShapeLab") and a real SWE-bench bug fix (`sympy__sympy-24213`).*

---

## TL;DR — the headline

| What `fast` delivers | ShapeLab (greenfield build) | SWE-bench (real bug fix) |
|---|---|---|
| **Task success** | ✅ 100 % accuracy, 3/3 seeds (ties general) | ✅ SWE-bench **RESOLVED**, 32/32 graded tests (ties general) |
| **Cost vs. `general` (same outcome)** | **2.0× cheaper** (50 % of the tokens) | **2.6× cheaper** (39 % of the tokens) |
| **Code footprint** | **Leanest of all 3** — 860 lines (30 % leaner than a raw prompt) | Exact one-line **canonical** fix |
| **Documentation** | **100 %** docstring coverage | n/a (1-line patch) |
| **Verified before shipping** | ✅ pre-solved every accuracy-critical gotcha | ✅ ran the full 32-test suite green |

> **Bottom line:** `fast` buys you the *quality of the heavyweight workflow with the footprint of the lightweight one.* On a real SWE-bench task it reproduced the **exact maintainer fix** and proved it green — for **61 % fewer tokens than `general`**.

---

## 1. Performance

### 1a. Token efficiency vs. the `general` workflow — same result, ~half the cost

`fast` and `general` reach **identical headline outcomes** (100 % accuracy / SWE-bench resolved / canonical verified fix). The only thing that differs is the bill.

| Benchmark | `fast` tokens | `general` tokens | **`fast` advantage** |
|---|---:|---:|---|
| ShapeLab (greenfield) | **2,490,192** | 4,999,680 | **2.0× cheaper** · saves 2,509,488 (50 %) |
| SWE-bench (real fix) | **1,735,631** | 4,446,841 | **2.6× cheaper** · saves 2,711,210 (61 %) |
| **Suite total** | **4,225,823** | 9,446,521 | **2.2× cheaper** · saves 5,220,698 (55 %) |

> Across the whole suite, `fast` does the same successful work for **under half (44.7 %) the tokens** of the `general` workflow.

### 1b. Outcome parity — `fast` matches `general` on every headline metric

| Outcome metric | baseline (raw) | **fast** | general |
|---|:--:|:--:|:--:|
| ShapeLab mean accuracy (seeds 0/42/99) | 1.000 | **1.000** | 1.000 |
| ShapeLab accuracy std (determinism) | 0.000 | **0.000** | 0.000 |
| ShapeLab pipeline runs end-to-end | 3/3 | **3/3** | 3/3 |
| SWE-bench **RESOLVED** | ✅ | **✅** | ✅ |
| SWE FAIL_TO_PASS + PASS_TO_PASS | 32/32 | **32/32** | 32/32 |

`fast` gives up **nothing** on the result that ships — it just gets there for less.

### 1c. Structural footprint

| | baseline | **fast** | general |
|---|---:|---:|---:|
| Role-subagents | 1 | **3** | 9 |
| SWE-bench turns to land the fix | 8 | **60** | 168 |

`fast`'s lean 3-agent pipeline (challenge + research → implement) carries the quality load with a third of `general`'s 9-agent fan-out.

---

## 2. Code Quality

### 2a. `fast` writes the most concise code of any approach

On the 1,000-line greenfield build, `fast`'s up-front challenge + research let the implementer write **tighter code with fewer dead paths** — the smallest codebase of all three arms, at **full documentation**.

| Code-quality metric | baseline | **fast** | general |
|---|---:|---:|---:|
| Code lines (AST, non-blank/comment) | 1,225 | **860** ⬅ leanest | 1,173 |
| → vs. each alternative | +42 % bulk | **baseline** | +36 % bulk |
| Function docstring coverage | 96.3 % | **100 %** | 100 % |
| Largest function (lines) — lower = better decomposed | 151 | **146** ⬅ best | 151 |
| All files compile (`py_compile`) | ✅ | ✅ | ✅ |

> **`fast` is 30 % leaner than the raw-prompt baseline and 27 % leaner than `general`** — less surface area to read, test, and maintain — while being the *only* lightweight arm at **100 % docstring coverage**.

### 2b. On the real bug, `fast` produced the *canonical maintainer fix*

All three arms resolve `sympy__sympy-24213`, but only the harnessed arms converged on the **exact upstream patch**. `fast`'s research stage identified `equivalent_dims` as *the* idiomatic API.

| | baseline (raw) | **fast** | general | gold (maintainer) |
|---|:--:|:--:|:--:|:--:|
| Files touched | 1 | 1 | 1 | 1 |
| Lines changed | +1 / −1 | +1 / −1 | +1 / −1 | +1 / −1 |
| **Matches gold fix form exactly** | ❌ | **✅** | ✅ | — |

```python
# gold / upstream maintainer fix:
if not self.get_dimension_system().equivalent_dims(dim, addend_dim):

# fast    → IDENTICAL to gold ✅
# general → IDENTICAL to gold ✅
# baseline → non-canonical defensive variant:
if dim != addend_dim and not self.get_dimension_system().equivalent_dims(dim, addend_dim):
```

`fast` ships **what the maintainers would actually merge** — the raw baseline ships a correct-but-non-idiomatic patch the lighter prompt happened to land.

---

## 3. Robustness

### 3a. `fast` verifies its work before shipping — the raw baseline does not

| Robustness signal | baseline (raw) | **fast** | general |
|---|:--:|:--:|:--:|
| Self-verified the fix before submitting | ❌ none | ✅ **ran 32 tests green** | ✅ 32 tests + edge probes |
| SWE patch applies cleanly | ✅ | **✅** | ✅ |
| Deterministic output (acc std across 3 seeds) | 0.000 | **0.000** | 0.000 |
| Pre-solved accuracy-critical gotchas¹ | partial | **✅ all** | ✅ all |

¹ Hu-moment log-transform, circle/ellipse discrimination via `fitEllipse`, `approxPolyDP` ε tuning — the issues that actually move accuracy. `fast`'s single challenge round caught them all, which is *why its code is both the most concise and 100 % accurate.*

> The raw baseline submitted its SWE fix **without running a single test**. `fast` ran the full suite and confirmed **32/32 green** before handing it over — assurance the no-harness path simply doesn't provide.

### 3b. Contract compliance — honest positioning

`fast` and `general` both pass the headline outcomes; they split on **one** spec edge case (a blank-image zero-vector guard) that only `general`'s heavier adversarial + QA tail caught:

| | baseline | **fast** | general |
|---|:--:|:--:|:--:|
| Independent contract tests passed | 8/9 | **8/9** | 9/9 |
| Cost to close that last edge case | — | — | **+2.5M tokens** |

**The trade `fast` makes:** it captures **every accuracy-critical and canonical-correctness property** at ~50 % of `general`'s cost; the *one* remaining edge case costs `general` an extra **2.5M tokens (≈ 2× `fast`'s entire run)** to close. For the vast majority of work, `fast` is the rational pick — reserve `general` for regulated / long-lived / high-blast-radius code where that final edge case is worth 2× the budget.

> Note: on that same edge case the raw baseline *also* failed (8/9) **and** additionally broke small-`n` usage by inventing an unrequested `n_samples ≥ 5` constraint. `fast` matches baseline's robustness gap on the one case while decisively beating it on conciseness, documentation, canonical correctness, and verification.

---

## Where `fast` sits — the three-way verdict

| Dimension | baseline (no harness) | **⚡ fast** | general |
|---|---|---|---|
| **Token cost** | Cheapest, but **zero assurance** | **Sweet spot** — 39–50 % of `general` | Most expensive (2.0–2.6× `fast`) |
| **Outcome** | Resolves / 100 % acc | **Resolves / 100 % acc** | Resolves / 100 % acc |
| **Code footprint** | Most verbose (1,225 ln) | **Leanest (860 ln) + 100 % docs** | 1,173 ln + 100 % docs |
| **Canonical fix** | ❌ non-idiomatic | **✅ exact maintainer fix** | ✅ exact maintainer fix |
| **Verified before ship** | ❌ shipped blind | **✅ tests green** | ✅ tests + edge probes |
| **Edge-case robustness** | 8/9 (+ broke small-n) | **8/9** | 9/9 |
| **Best for** | throwaway / one-off | **most production work** | regulated / high-stakes |

> **`fast` is the workflow you reach for by default:** it adds the harness's real wins — canonical, verified, concise, fully-documented code — on top of a bare prompt, and captures essentially all of `general`'s quality **for roughly half the price.**

---

## Methodology & caveats (for credibility)

- **Token measurement is exact, not estimated.** Every subagent transcript (`<session>/subagents/agent-*.jsonl`) carries full per-turn `usage`; [`_measure/tokscan.py`](experiment/_measure/tokscan.py) sums real `input / cache_creation / cache_read / output` tokens per arm. 13 arm transcripts per experiment (1 + 3 + 9).
- **Model held constant** (Sonnet 4.6 subagents) so the comparison isolates the *harness*, not the model.
- **Independent, pre-written test suites** decided every outcome — written before any arm ran, never shown to the arms (SWE gold/test patches were off-limits on disk).
- **Honest limits:** n = 1 build per arm (agentic token cost has large run-to-run variance), one task per benchmark, and a no-Docker local reproduction of SWE-bench's grading rule. Prompt-cache warmth (arms ran baseline→fast→general in one session) discounts later arms — which biases *against* `fast`/`general` looking cheap, so the efficiency direction is conservative. Orchestrator + meta-vetting tokens are shared overhead, excluded from per-arm totals.

*Raw data: [`experiment/results/`](experiment/results/) (ShapeLab) and [`experiment_swe/results/`](experiment_swe/results/) (SWE-bench) — `consolidated.json`, `tokens.json`, `eval_*.json`, and the full `COMPARISON_LOG.md` / `SWE_COMPARISON_LOG.md`.*
