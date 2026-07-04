# FableWise

> **Fable designs. Sonnet applies. Nothing runs until you launch it.**

Claude's frontier model understands requests better than anything else — so **fablewise** puts it in the driver's seat for *design*, grounded by cheap delegated exploration and web research, then hands execution to Sonnet with one iron rule: **apply the plan exactly; on any problem, stop, invent nothing, and write a blockage synthesis for Fable to arbitrate.**

## Install

```
/plugin marketplace add Liberateur/FableWise
/plugin install fablewise
```

Cowork (Claude desktop app): **Customize > Settings > Plugins** > **Add marketplace** > `Liberateur/FableWise` > install **fablewise**.

> ⚠️ **Design commands run from a Fable session** (`/plan`, `/plan-rework`, `/plan-prompt`) — **execution runs from a Sonnet session** (`/plan-run`), and **`/plan-debug` runs from an Opus session** (it absorbs investigation volume off Fable). Built-in guards enforce every direction.

```
/plan add rate-limiting to the public API
```

## How it works

**`/plan` — turn a request into a ready-to-run plan (nothing runs):**

1. **Fable** (your session) understands the request — need vs. assumed means.
2. **Sonnet** explores your project and returns a compressed synthesis — the Fable session never reads raw files or browses the web (cost + injection quarantine).
3. **Fable** challenges — only on a real comprehension doubt or structuring choice.
4. **Sonnet/Haiku** run capped, quarantined web research and extract verbatim evidence from the files the plan will cite.
5. **Fable writes the plan itself**, for Sonnet to apply without re-deciding: grouped tasks with chewed-through operating procedures, binary machine-checkable criteria (subjective sign-off batched into gate tasks), and tags — `[touche:]` scope, `[contexte: lourd]` heavy output, `[humain:]` person-only actions (from a capability probe) — plus an escalation budget, pre-decided Plan Bs, and a pre-mortem.
6. **Haiku** gate-checks every reference in one scripted pass — nothing hallucinated.
7. The plan lands **🟢 ready**, waiting for you to launch `/plan-run`.

**`/plan-run` — execute it (from a fresh Sonnet session):**

1. The session applies tasks to the letter (anchored edits, frozen tests), **dispatching parallel executors when `[touche:]` scopes don't overlap** and **always delegating `[contexte: lourd]` tasks** (capture-heavy audits, builds, verbose tests) so images and logs never saturate its context. Untagged heavy tasks are detected and tagged before execution. Say **"delegate everything"** at launch (or let the run switch at its first compaction) to push every remaining task into executors — maximum headroom on long plans, criteria still constated in-session.
2. Binary criteria are checked on evidence — commands run, diffs read, never on faith. Sub-agent artifacts are hash-checked in-session, live-system changes re-read independently. Sign-off lives only in **gate tasks**; `[humain:]` tasks are never attempted — they land in a decision-ready **"Attendu humain"** block while independent branches continue.
3. On failure: one retry → pre-decided Plan B → **the run stops** and writes a **blockage synthesis** (nature, attempts, evidence, options) into the plan, counted against the escalation budget. You take it to Fable, paste the directive back — which opens with a proof step when the cause is unproven — and relaunch; the run resumes exactly there. Budget exhausted → it recommends `/plan-rework`. And **null effect = suspect channel**: a change that applies but changes nothing observable triggers an observation-channel audit (rendered? visible? bound?), never a second blind tuning.
4. Progress, journals and costs live in the plan file — **resume anytime**. A run crosses context compaction (full re-read) and only ends on blockage, human-awaited stop, or completion. A `Run en cours` header line (session + timestamp, stale after 2 h) guards against two sessions on the same plan.

**Running to completion, unattended.** Since 0.22 a single run goes the distance (heavy tasks delegated, compaction crossed). What remains is session mortality — a session that dies is relaunched, and re-entrance makes every relaunch idempotent. Three carriers:

- **CLI (Claude Code)** — `scripts/fablewise-loop.sh <plan.md> [max_iter]` from the project root relaunches headless Sonnet sessions until a legitimate end: `✅` done (exit 0), `🔴` blockage → Fable (exit 2), `⏸` human action or no progress → see the plan's **Attendu humain** block (exit 3). It never crosses a blockage.
- **Cowork (desktop app)** — no headless relaunch, so use a **scheduled task**: e.g. hourly `/plan-run <plan> — autonomous, no questions` (name the plan explicitly). Must be a **Sonnet** session. On a terminal state it detects it in one read and offers to disable the schedule instead of re-working.
- **Stop hook (opt-in)** — `echo "<plan.md>" > .claude/fablewise-autorun` before launching: the `Stop` hook blocks any stop while the plan isn't `✅`/`🔴`/`⏸`, feeding back "re-read the plan and continue"; the run exits by writing the real state (deleting the flag is the safety net). Hook support in the desktop app is undocumented — the scheduled task covers the same need. The hook prevents stopping *early*; the loop/schedule cures sessions that *die*.

## Commands

| Command | Session | What it does |
|---|---|---|
| `/plan <request>` | **Fable** | Design a plan: delegated exploration & research, rechallenge, plan written by Fable |
| `/plan-run <plan file>` | **Sonnet** | Apply it task by task; parallel when scopes are disjoint; stop-and-synthesize on blockage (re-entrant) |
| `/plan-rework <plans or folder>` | **Fable** | Merge, re-challenge and rebuild aging plans (history condensed, sources deleted after your GO) |
| `/plan-prompt <request>` | **Fable** | One-shot: an optimal prompt + the right model, no plan file |
| `/plan-debug <plan file>` | **Opus** | Investigate a stuck/buggy plan (Opus holds the volume): a problem→cause digest + a model reco (Opus vs Fable) + a ready-to-paste debug prompt — read-only, runs nothing |

## Why this shape

A measured head-to-head (2026-07-03, same request, cold — see [benchmarks/](benchmarks/)) put the old multi-agent pipeline at **$7.13 / 25 min** vs **$0.77 / 91 s** for direct no-tools Fable — 9× the cost, 17× the time, equivalent design quality. But the naked run showed why grounding matters: a post-cutoff prior asserted as fact, a design colliding with the existing architecture, a scope decided without asking. v0.21 keeps the grounding, drops the coordination — projected **~$3.2 / ~10-13 min** for the same request (−55 % cost, −60/70 % time; to be replaced by the first real run). What earned its keep:

- **Delegation of volume** — exploration, research and inventories run in cheap sub-agents returning compressed syntheses; the Fable session pays context rent on judgment only.
- **Injection quarantine** — web researchers are read-only, capped, and return typed data; untrusted content never becomes instructions.
- **Grounding gates** — verbatim evidence before writing, a scripted anti-hallucination pass after; unverifiable references flagged `⚠`, never guessed.
- **Run-time discipline** — anchored edits, frozen tests (touch one = instant fail), scope-tag parallelism with exclusive-resource mutexes, root-cause discipline (null effect → audit the channel; unproven cause → prove before fixing), hash-checked artifacts, and stop-and-synthesize: reporting a blockage is a success, inventing a workaround a failure.
- **The plan file is the single source of truth** — re-entrant, updated after every task, re-read after compaction.

## Requirements & notes

- Claude Code or Cowork with per-subagent model override (`sonnet`, `haiku`, `opus`).
- `/plan`, `/plan-rework`, `/plan-prompt` require a **Fable** session; `/plan-run` requires **Sonnet** — guards block the wrong direction with zero side effects.
- Plans from fablewise ≤ 0.20 still run: `/plan-run` ignores legacy model tags and pre-0.21 escalation budgets (the `Escalades Fable` header line is authoritative; missing lines added on first touch).
- Optional per-project files: `.claude/fablewise-lessons.md` (compounding lessons, user-approved, factual and narrow; relevant ones injected into executors) · `.claude/fablewise-notify` (ntfy/webhook URL).
- Skill instructions are in French for now (outputs follow your project's language); English translation is the top roadmap item.

## Contributing

Issues and PRs welcome — see [CONTRIBUTING.md](CONTRIBUTING.md) and [DECISIONS.md](DECISIONS.md) (the *why* behind every mechanism, including the v0.21 inversion). Example plan: [examples/example-plan.md](examples/example-plan.md). Golden rule: any pipeline change propagates across all four layers (skills, agents, plan template, README).

## License

MIT
