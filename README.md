# fablewise

> **Cut your Fable 5 bill by up to ~70%\* — and keep its judgment.**

Claude's frontier model is brilliant and expensive. **fablewise** is a Claude Code / Cowork plugin that spends it only where nothing else will do — challenging your request, deciding the plan, arbitrating failures — while cheaper models do everything else, under systematic independent verification.

**Fable decides. Opus details. Sonnet & Haiku execute and verify. You stay in control at every gate.**

\* *Estimate vs. the same token volume run entirely on Fable; shown as an upper-bound cost table after every command.*

## Install

```
/plugin marketplace add Liberateur/FableWise
/plugin install fablewise
```

Or in **Cowork** (Claude desktop app): open **Customize > Settings > Plugins**, choose **Add marketplace**, enter `Liberateur/FableWise`, then install **fablewise** from the list.

Then, **from a Sonnet session**:

```
/plan add rate-limiting to the public API
```

## How it works

```
your request
   ├─ Sonnet explores the project           (cheap, read-only)
   ├─ FABLE challenges your request         (short, interactive — asks before assuming)
   ├─ Sonnet researches what's missing      (web + project, parallel, quarantined)
   ├─ FABLE decides the skeleton            (methods, model per task, Plan Bs, pre-mortem — dense, short)
   ├─ Opus expands into playbooks           (step-by-step, executable by a model that never improvises)
   ├─ Haiku gate-checks every reference     (anti-hallucination + skeleton fidelity)
   └─ YOU validate the plan                 (nothing runs without your go)

/plan-run  →  Sonnet/Haiku execute task-by-task
   ├─ scope-based parallelism ([touche:] tags, exclusive-resource mutexes)
   ├─ independent per-criterion verification (never self-graded)
   ├─ failure ladder: retry → pre-decided Plan B → Fable arbitration (budgeted)
   └─ progress, costs and journals written into the plan file (re-entrant)
```

## Commands

| Command | What it does |
|---|---|
| `/plan <request>` | Design a validated, ultra-prescriptive multi-model plan |
| `/plan-run <plan file>` | Execute it task-by-task with verification and escalation |
| `/plan-rework <plans or folder>` | Merge, re-challenge and rebuild aging plans (history condensed, never lost silently) |
| `/plan-prompt <request>` | One-shot: an optimal prompt + the recommended model, no plan file |

## Why it saves money

- The **orchestrating session runs on Sonnet** — the most expensive seat in any agent loop is the orchestrator, so it's the cheapest capable model.
- **Fable's output is capped at judgment**: skeletons, decisions, arbitrations. Never code, never long documents. A completeness loop lets it request missing info instead of writing plans on guesses.
- **Long output is billed at Opus rates**, mechanical work and verification at Haiku rates.
- Every command ends with a **cost table** — per-model tokens, estimated cost, and what the same volume would have cost all-Fable. Each plan file carries its **cumulative lifetime cost**.

## Why quality goes *up*, not down

- **Per-criterion binary verification** by an independent agent (rationale before verdict, `UNKNOWN` ≠ pass) — executors never grade themselves.
- **Frozen acceptance tests**: written first, committed, untouchable — modifying a test is an instant FAIL.
- **Anchored edits**: executors quote the exact lines before changing them; a missing anchor is a reported block, never a guess.
- **Pre-mortem & Plan B**: the architect writes the fictional incident report of the plan's failure and pre-decides fallbacks — course changes are designed by the strongest model *before* the run, not improvised mid-run by the weakest.
- **Prompt-injection quarantine**: web researchers are read-only and return typed summaries; file content is data, never instructions.
- Designed against the three failure modes Anthropic names: *agentic laziness* (copied checklists, no "I'll handle the rest"), *self-preferential bias* (verifier ≠ executor, pairwise verdicts), *goal drift* (the plan file on disk is the only memory that survives compaction).

## Requirements & notes

- Claude Code or Cowork with per-subagent model override (`fable`, `opus`, `sonnet`, `haiku`).
- Run all commands **from a Sonnet session** — a guard blocks premium-model orchestration by design.
- Optional per-project files: `.claude/fablewise-lessons.md` (compounding lessons, user-approved) and `.claude/fablewise-notify` (ntfy/webhook URL for gate & completion notifications).
- **Language note**: skill instructions are currently written in French (outputs follow your project's language). English translation is the top roadmap item — PRs welcome.

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) and [DECISIONS.md](DECISIONS.md) (the *why* behind every mechanism — read it before proposing changes). A complete example plan lives in [examples/example-plan.md](examples/example-plan.md). The golden rule: any pipeline change must propagate across all four layers (skills, agents, plan template, README).

## License

MIT
