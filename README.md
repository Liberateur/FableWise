# FableWise

> **Keep Fable's judgment. Cut its bill by up to ~70%.\***

Claude's frontier model is brilliant — and expensive. **fablewise** spends it only where nothing cheaper will do: challenging your request, deciding the plan, arbitrating failures. Everything else runs on small models, under independent verification.

**Fable decides · Opus details · Sonnet & Haiku execute and verify.**

\* *Token volumetry vs. the same work run all-Fable; every command also shows the real cache-inclusive cost when the session transcript is reachable — measured, not guessed.*

## Install

```
/plugin marketplace add Liberateur/FableWise
/plugin install fablewise
```

Cowork (Claude desktop app): **Customize > Settings > Plugins** > **Add marketplace** > `Liberateur/FableWise` > install **fablewise**.

> ⚠️ Run every command from a **Sonnet** session — a built-in guard blocks premium-model orchestration. Fable only ever runs inside sub-agents.

```
/plan add rate-limiting to the public API
```

## How it works

Two commands. **`/plan` designs, `/plan-run` executes** — and nothing runs until *you* launch it.

**`/plan` — turn a request into a ready-to-run plan (nothing is executed):**

1. **Sonnet** explores your project — cheap, read-only.
2. **Fable** makes sure it understands, then challenges — asks only when there's real doubt.
3. **Fable** decides the skeleton: tasks, model per task, dependencies, Plan Bs, pre-mortem.
4. **Opus** expands each task into a step-by-step playbook, written straight to disk.
5. **Haiku** gate-checks every reference — nothing hallucinated, skeleton respected.
6. The plan lands **🟢 ready** — no approval step, it just waits for you.

**`/plan-run` — execute it, task by task (from a fresh Sonnet session):**

1. Reads the plan and runs ready tasks — **in parallel when their scopes don't overlap**.
2. Every task is **verified by an independent agent**, criterion by criterion — never self-graded.
3. On failure: retry → pre-decided Plan B → **Fable arbitrates** the exact issue (budgeted).
4. Progress, costs and journals are written into the plan file — **resume anytime**.

**Fable shows up at exactly three moments:** understand & decide up front, optionally sign off on a digest, arbitrate blockers at run time. Nothing else.

## Commands

| Command | What it does |
|---|---|
| `/plan <request>` | Design a multi-model plan. Knobs: `--architecte=opus` (routine plans, no Fable design) · `--validation-fable` (Fable signs off on a digest) |
| `/plan-run <plan file>` | Execute it with verification and escalation (re-entrant) |
| `/plan-rework <plans or folder>` | Merge, re-challenge and rebuild aging plans |
| `/plan-prompt <request>` | One-shot: an optimal prompt + the right model, no plan file |

## Why it's cheaper *and* better

**Cheaper** — the orchestrator runs on Sonnet (the seat that pays context rent every turn), Fable's output is capped at judgment from compressed briefs (never code, never long documents), long writing is billed at Opus rates, mechanical work and verification at Haiku rates. Every command ends with a **cost recap**: per-model token volumetry plus the real cache-inclusive cost when the transcript allows — each plan file carrying its lifetime spend. Best fit: multi-task plans on real codebases; for one-file fixes the fixed costs dominate, so use `/plan-prompt`.

**Better** — **independent per-criterion verification** (verifier ≠ executor, `UNKNOWN` ≠ pass) and **frozen acceptance tests** (touch a test = instant FAIL); pre-mortem and Plan Bs designed by the strongest model *before* the run, not improvised by the weakest during it; **anchored edits** (quote before modify) and **prompt-injection quarantine** (web research is read-only data, never instructions). The plan file on disk is the single source of truth — it survives crashes and context compaction, and runs resume where they stopped.

## Requirements & notes

- Claude Code or Cowork with per-subagent model override (`fable`, `opus`, `sonnet`, `haiku`).
- Commands must run from a **Sonnet** session — the guard blocks Fable/Opus orchestration by design.
- Optional per-project files: `.claude/fablewise-lessons.md` (compounding lessons, user-approved) · `.claude/fablewise-notify` (ntfy/webhook URL for notifications).
- Skill instructions are currently in French (outputs follow your project's language); English translation is the top roadmap item — PRs welcome.

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) and [DECISIONS.md](DECISIONS.md) (the *why* behind every mechanism). Example plan: [examples/example-plan.md](examples/example-plan.md). Golden rule: any pipeline change propagates across all four layers (skills, agents, plan template, README).

## License

MIT
