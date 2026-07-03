# Benchmarks — same request, with and without fablewise

Measured, reproducible comparisons that feed the table at the top of the main README. One case = one frozen fixture project + one request + frozen acceptance tests. Each case is run twice: once by a **plain Fable session** (baseline), once through **fablewise** (`/plan` + `/plan-run` from a Sonnet session).

## Honesty rules (non-negotiable, they mirror D-10 and D-12)

- **Acceptance tests are written before any run, kept outside the fixture, and never shown to either variant.** Both variants receive the exact same `request.md`, verbatim. Once results are published, an acceptance script is frozen — changing it invalidates every published row for that case.
- **No cherry-picking.** Publish the first run of each variant, or publish all runs. A discarded run must be mentioned in the result's `notes`.
- **Both variants use the same accounting.** `session-cost.js` reads the real usage Claude Code logs in `~/.claude/projects/**/*.jsonl` (per-call tokens, model, cache write/read), filters entries whose `cwd` is the run folder, and prices them at API rates — cache discounts included. No estimates on either side. On a Pro/Max subscription the dollar figure is notional (usage is included in the plan), but priced at API rates it is exactly the right comparator. Fallbacks if transcripts aren't found: the CLI's `total_cost_usd` for the baseline, the plugin's upper-bound estimate (then manual entry) for fablewise — always flagged in the result's `notes`.
- **Wall time for fablewise includes human latency** at the validation gates — it is honest but unflattering; say so wherever the number is shown.

## Run a case

```
./run.sh <case> baseline     # headless: claude -p, model $BASELINE_MODEL (default: fable)
./run.sh <case> fablewise    # interactive: the script preps the folder and guides you
```

Cases live in `cases/<name>/` — currently `bugfix-pagination`, `feature-rate-limit`, `refactor-callbacks`.

**Baseline** runs fully unattended: the fixture is copied to `runs/<stamp>-<case>-baseline/`, the request is passed to `claude -p` with `--dangerously-skip-permissions` (the folder is disposable), then the frozen acceptance script grades the folder.

**fablewise** is semi-automatic by design — the user gates are an invariant of the plugin, so the harness preps the folder, tells you exactly what to type (`/plan`, approve, `/plan-run`), and waits. When you're done it grades the folder with the same frozen script.

In both cases, cost and Fable tokens come from the session transcripts (`session-cost.js`, see above); the per-model breakdown is kept in `<run dir>/session-cost.json`. The sessions must be launched **from inside the run folder** — that is how the harness finds them.

Results land in `results/<case>-<variant>.json`. Regenerate the README table from them:

```
node gen-table.js
```

## Add a case

1. `cases/<name>/fixture/` — a small, dependency-free project (must stay runnable offline).
2. `cases/<name>/request.md` — the request, functional symptoms only, plus the invariants acceptance relies on (start command, `PORT` env, no new deps).
3. `cases/<name>/acceptance.sh` — takes the run dir as `$1`, prints one `PASS`/`FAIL` line per criterion, ends with `RESULT <passed>/<total>`, exits non-zero unless all pass. Binary criteria only.
4. Verify the script **fails on the pristine fixture** (tests-first) before running any variant.

## Environment

- `BASELINE_MODEL` (default `fable`), `ORCH_MODEL` (default `sonnet`) — override if your CLI uses different model aliases.
- Requires `claude` CLI, `node` ≥ 18, `curl`.
- `runs/` is disposable and gitignored; `results/` is committed (it is the data behind the published table).
