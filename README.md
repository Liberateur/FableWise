# FableWise

> **Fable designs. Sonnet applies. Nothing runs until you launch it.**

Claude's frontier model understands requests better than anything else — so **fablewise** puts it in the driver's seat for *design*, grounded by cheap delegated exploration and web research, then hands execution to Sonnet with one iron rule: **apply the plan exactly; on any problem, stop, invent nothing, and write a blockage synthesis for Fable to arbitrate.**

## Install

```
/plugin marketplace add Liberateur/FableWise
/plugin install fablewise
```

Cowork (Claude desktop app): **Customize > Settings > Plugins** > **Add marketplace** > `Liberateur/FableWise` > install **fablewise**.

> ⚠️ **Design commands run from a Fable session** (`/plan`, `/plan-rework`, `/plan-prompt`) — **execution runs from a Sonnet session** (`/plan-run`). Built-in guards enforce both directions.

```
/plan add rate-limiting to the public API
```

## How it works

**`/plan` — turn a request into a ready-to-run plan (nothing is executed):**

1. **Fable** (your session) understands the request — need vs. assumed means.
2. **Sonnet** explores your project and returns a compressed synthesis — the Fable session never reads raw files or browses the web itself (cost + injection quarantine).
3. **Fable** challenges — asks only when there's a real comprehension doubt or structuring choice.
4. **Sonnet/Haiku** run delegated web research (capped, quarantined) and extract verbatim evidence from the files the plan will cite.
5. **Fable writes the plan itself**: grouped tasks with chewed-through operating procedures, machine-checkable binary criteria (user validation batched into gate tasks), scope tags, `[contexte: lourd]` tags on heavy-output tasks, pre-decided Plan Bs, a pre-mortem — written for Sonnet to apply without re-deciding.
6. **Haiku** gate-checks every reference in one scripted pass — nothing hallucinated.
7. The plan lands **🟢 ready** — it just waits for you to launch `/plan-run`.

**`/plan-run` — execute it (from a fresh Sonnet session):**

1. The session applies tasks itself, following operating procedures to the letter (anchored edits, frozen tests) — **dispatches parallel executors when task scopes (`[touche:]`) don't overlap**, and **always delegates `[contexte: lourd]` tasks** (capture-heavy audits, builds, verbose tests) so images and logs never saturate the run session's context. Untagged heavy tasks are detected before execution and tagged in the plan. Say **"delegate everything"** at launch (or let the run switch automatically at its first compaction) to run every remaining task in executors — maximum headroom on very long plans; criteria are still constated in-session, on evidence.
2. Every task's binary criteria are checked on evidence — commands run, diffs read, never taken on faith. User sign-off lives only in explicit **gate tasks**: an autonomous run crosses everything else and stops cleanly at the gate.
3. On failure: one retry → pre-decided Plan B → **the run stops**. No improvisation: a **blockage synthesis** (nature, attempts, evidence, options) is written into the plan; you take it to Fable, paste the directive back, and relaunch — the run resumes exactly there.
4. Progress, journals and costs live in the plan file — **resume anytime**. A run continues through context compaction (full plan re-read) and only ends on blockage, gate, or completion.

**Running to completion, unattended.** Since 0.22 a single run session goes the distance (heavy tasks delegated, compaction crossed). What remains is session mortality — a session that dies or ends is relaunched, and re-entrance makes every relaunch idempotent. Two carriers, one per environment:

- **CLI (Claude Code)** — `scripts/fablewise-loop.sh <plan.md> [max_iter]` from the project root: relaunches headless Sonnet sessions until the plan reaches one of its three legitimate ends — `✅` done (exit 0), `🔴` blockage → Fable arbitration (exit 2), gate / no progress → your eye is required (exit 3). It never crosses a blockage.
- **Claude desktop app (Cowork)** — no headless relaunch exists, so use a **scheduled task** in the project's workspace: e.g. hourly, prompt `/plan-run <plan> — autonomous, no questions`. The scheduled session must be **Sonnet** (the model guard blocks Fable/Opus). On a terminal state (`✅`, `🔴`, gate pending) the run detects it in one read and offers to disable the schedule instead of re-working.

## Commands

| Command | Session | What it does |
|---|---|---|
| `/plan <request>` | **Fable** | Design a plan: delegated exploration & research, rechallenge, plan written by Fable |
| `/plan-run <plan file>` | **Sonnet** | Apply it task by task; parallel when scopes are disjoint; stop-and-synthesize on blockage (re-entrant) |
| `/plan-rework <plans or folder>` | **Fable** | Merge, re-challenge and rebuild aging plans (history condensed, sources deleted after your GO) |
| `/plan-prompt <request>` | **Fable** | One-shot: an optimal prompt + the right model, no plan file |

## Why this shape

A measured head-to-head (2026-07-03, same request, cold — see [benchmarks/](benchmarks/)) showed the previous multi-agent pipeline at **$7.13 / 25 min API** vs **$0.77 / 91 s** for direct no-tools Fable — **9× the cost, 17× the time, equivalent design quality**. But the naked run also showed why grounding matters: a post-cutoff prior asserted as fact, a design colliding with the project's existing architecture, a scope decided without asking. v0.21 keeps the grounding and drops the coordination: projected **~$3.2 and ~10-13 min** for the same request (−55 % cost, −60/70 % time vs the pipeline — projection from measured components, to be replaced by the first real run). What earned its keep was kept:

- **Delegation of volume** — exploration, web research and inventories run in cheap sub-agents returning compressed syntheses; the Fable session pays context rent on judgment only.
- **Injection quarantine** — web researchers are read-only, capped, and return typed data; untrusted content never becomes instructions.
- **Grounding gates** — verbatim evidence before writing, a scripted anti-hallucination pass after; unverifiable references are flagged `⚠`, never guessed.
- **Discipline at run time** — anchored edits (quote before modify), frozen acceptance tests (touch a test = instant fail), scope-tag parallelism with named exclusive resources (`editor`, `db`…), and the stop-and-synthesize contract: reporting a blockage is a success, inventing a workaround is a failure.
- **The plan file is the single source of truth** — re-entrant, updated after every task, fully re-read after compaction.

## Requirements & notes

- Claude Code or Cowork with per-subagent model override (`sonnet`, `haiku`, `opus`).
- `/plan`, `/plan-rework`, `/plan-prompt` require a **Fable** session; `/plan-run` requires a **Sonnet** session — guards block the wrong direction with zero side effects.
- Plans produced by fablewise ≤ 0.20 still run: `/plan-run` ignores legacy per-task model tags and escalation budgets.
- Optional per-project files: `.claude/fablewise-lessons.md` (compounding lessons, user-approved) · `.claude/fablewise-notify` (ntfy/webhook URL for notifications).
- Skill instructions are currently in French (outputs follow your project's language); English translation is the top roadmap item — PRs welcome.

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) and [DECISIONS.md](DECISIONS.md) (the *why* behind every mechanism, including the v0.21 inversion). Example plan: [examples/example-plan.md](examples/example-plan.md). Golden rule: any pipeline change propagates across all four layers (skills, agents, plan template, README).

## License

MIT
