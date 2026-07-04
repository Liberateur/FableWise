# Changelog

All notable changes to **fablewise** are documented here. Format inspired by [Keep a Changelog](https://keepachangelog.com); versions follow [semver](https://semver.org). The plugin was developed iteratively on 2026-07-02/03 under its working name *plan-runner*, renamed *fablewise* for public release.

## [0.28.1] — 2026-07-04

**Finish the 0.28 propagation.** Two run-semantics surfaces (the CLAUDE.md-flagged `scripts/` and the example plan) still told users to take a blockage to Fable; a self-inconsistent line in `/plan-debug` and a missing guard-test entry rounded it out. Prompts/docs only.

- **`scripts/fablewise-loop.sh`**: on `🔴` (exit 2) it now points to `/plan-debug` in an Opus session (message, notify text, header comment, exit-code doc) instead of "arbitrate with Fable".
- **`examples/example-plan.md`**: Contrat d'exécution aligned with the 0.28 template (blockage → Opus `/plan-debug`, Fable last resort).
- **`skills/plan-debug/SKILL.md`**: the read-only rationale no longer says "arbitration is Fable's" — the reprise decision is the investigation's own, Fable only as last resort.
- **`CLAUDE.md`** testing checklist: the model-guard case now also covers `/plan-debug` from a non-Opus session.

## [0.28.0] — 2026-07-04

**Blockage escalation reroutes to Opus (`/plan-debug`), off Fable.** In the ocean sessions, taking every `Synthèse de blocage` to a Fable session burned premium tokens on investigation volume (screenshots, test replays, full-plan reads). That volume now lands on Opus — cheaper, and it holds volume the way Fable must not — with Fable reached only when `/plan-debug` judges the frontier truly necessary. See D-29.

- **`/plan-run` stop-and-synthesize now points to `/plan-debug` (Opus)** instead of a Fable arbitration session: the reminder, the `Directive de reprise` contract, the guard note and the budget wording all route through `/plan-debug`; Fable stays the documented last resort (its call is `/plan-debug`'s to make).
- **Four-layer propagation**: `/plan`, `/plan-rework`, the plan template (Contrat d'exécution, `Escalades Fable` comment, Directive de reprise), `task-executor`, README, CLAUDE.md and the marketplace/plugin descriptions all updated in lockstep — "blockage → Fable arbitration" becomes "blockage → Opus investigation via `/plan-debug`, Fable last resort".
- **`/plan-debug` tie-in**: when a plan carries a `Synthèse de blocage`, the debug prompt it produces serves as the `Directive de reprise` to paste back before relaunching `/plan-run`.
- Unchanged: the `Escalades Fable` header budget line (name kept for legacy-plan compatibility; an investigation no more decrements it than an arbitration did), the Directive-de-reprise resume machinery, and the loop/hook contract (still stops at `🔴`, never crosses it).

## [0.27.0] — 2026-07-04

**`/plan-debug` — an Opus investigation layer for stuck plans.** Motivated by the ocean-plan sessions where a Fable session was burning premium tokens on screenshots, test replays and full-plan reads. Additive command; no change to the existing pipeline (skills, agents, plan template untouched).

- **New command `skills/plan-debug/SKILL.md`** (Opus session, Étape 0 guard blocks any non-Opus model). Opus deliberately **holds the volume** Fable must not — it re-reads the plan, replays tests, loads captures and dumps the live system in-session — then returns three things and nothing else: a compact **problem→cause digest** (`[prouvé]`/`[hypothèse]` + evidence), a **one-line model reco** (Opus enough vs Fable needed), and a long **self-contained debug prompt** for a fresh session.
- **Read-only**: never writes the plan or any project file, never runs the debug itself (strict separation like `/plan-prompt`). Reuses the run's root-cause discipline (finding-before-verdict, proven cause ≠ hypothesis, null effect = suspect channel, `⚠ à vérifier` for unproven references).
- **Guard rationale**: Opus is cheaper than Fable and absorbs the investigation mass; Fable is escalated only at the end, on a condensed digest, when frontier judgment is truly required — the seat assignment of D-21/D-25 unchanged (Fable never holds volume; runs stay Sonnet).

## [0.26.0] — 2026-07-04

**Root-cause discipline & human dependency first-class.** Driven by a full audit of the ocean-plan session cluster (runs 4-7: five runs lost on a `hidden in game` root cause, one identical-captures tool race, one migration/run collision, one ghost escalation budget), cross-checked against 2026 state-of-the-art posts on agent harnesses. See D-26, D-27, D-28.

- **Null effect = suspect channel** (`/plan-run`, `task-executor`, template contract): a change that applies cleanly but changes nothing observable triggers an observation-channel audit (rendered/visible/bound/ticking) with a crude discriminating test — never a second blind tuning.
- **Proof-bearing directives**: a `Directive de reprise` for an unproven cause starts with a discriminating experiment; the run constates the proof before applying the fix; a refuted cause returns to arbitration with the finding.
- **Hash-checked artifacts** (operationalizes D-07): executors report `shasum` + size per binary artifact in their CHECKPOINT; the run session re-checks them and independently re-reads modified live-system properties.
- **Lessons reach executors**: relevant `.claude/fablewise-lessons.md` lines are injected verbatim (filtered by the task's tools/files) into `task-executor` prompts; lessons are kept factual and narrow (anti-drift).
- **`[humain: <geste>]` tag** — set at design (a capability probe joins `/plan` exploration: what the harness cannot do) or learned in-run once a wall is established (tag written back into the plan). Never attempted; independent branches continue.
- **`⏸ en attente humaine` header status** + decision-ready **Attendu humain** block (gesture, where, machine criterion for the next run to constate). Loop (exit 3), scheduled-run detection and Stop hook all treat `⏸` as a legitimate end — writing the true state is the hook's exit key.
- **`Run en cours` header line** (session + ISO timestamp, refreshed per task, cleared at stop, stale after 2 h): interactive runs finding a fresh marker stop and ask; autonomous relaunches take over and note it; `/plan-rework` refuses fresh-marked sources.
- **`Escalades Fable : n/m` header budget made official** (the audited runs were honoring an undocumented ghost of it): +1 per synthesis written, arbitrations free, budget set by Fable at design (default 5); exhausted → recommend `/plan-rework`.
- **Recap**: when the real cost is unavailable (Cowork), the run cumulates sub-agent non-cache volumetry into the header (`runs ~{n}k tokens sous-agents`) instead of leaving "n/d".
- Legacy plans: missing header lines added on first touch; pre-0.21 escalation-policy lines still ignored (the new header line is authoritative).

## [0.25.0] — 2026-07-03

**The lock on the door.** Opt-in Stop hook against premature stops; Opus-for-runs re-examined against 2026 docs and re-rejected. See D-25.

- **`hooks/fablewise-stop.sh`** (+ `hooks/hooks.json`): active only when `.claude/fablewise-autorun` names a plan; blocks any session stop while the plan is neither `✅` nor `🔴`, with "re-read the plan and continue" as feedback. Legitimate non-terminal exits (gate, user awaited) = record in plan + delete the flag file (contract added to `/plan-run`). Native consecutive-block cap bounds worst cases. Hook support in the desktop app untested.
- **Docs**: Sonnet 5 and Opus 4.8 share the same 1M context window (official) — a premium run seat buys zero autonomy headroom; D-01's run guard stands.

## [0.24.0] — 2026-07-03

**Delegation, sharpened.** See D-24.

- **Heavy-task detection everywhere**: any UNTAGGED task (legacy plan or design-time omission) is assessed before execution; detected heavy → delegated AND tagged `[contexte: lourd]` in the plan file, so relaunches benefit.
- **Full-delegation mode (adaptive)**: on user request at launch ("délègue tout") or automatically at the run's first compaction, every remaining task runs in a `task-executor` — the session keeps only orchestration, on-evidence criteria constatation and plan upkeep. Not the default: inline stays the base economy (~30k harness tokens saved per sequential task, D-13/D-21).

## [0.23.0] — 2026-07-03

**Loop until done.** After 0.22, the residual cause of premature stops is session mortality; a session cannot relaunch itself, so the loop lives outside — and never crosses a blockage or a gate (those are decisions, not failures). See D-23.

- **`scripts/fablewise-loop.sh <plan> [max_iter]`** (CLI): relaunches headless Sonnet `/plan-run` sessions until `✅` (exit 0), `🔴` blockage (exit 2), or gate/no-progress detected by plan-file hash (exit 3); bounded iterations, opt-in `.claude/fablewise-notify` pings.
- **Claude desktop app (Cowork)**: documented scheduled-task pattern (e.g. hourly `/plan-run <plan>` on a Sonnet session — the model guard applies). `/plan-run` now handles being a scheduled firing: on an already-terminal plan (`✅`, `🔴` without directive, gate pending) it constates in one read, offers to disable the schedule, and re-works nothing.

## [0.22.0] — 2026-07-03

**Runs that go the distance.** A real 20-task autonomous run stopped after 3 tasks on context saturation (capture-heavy audits executed inline). Three mechanisms so a run only ever stops on blockage, gate, or completion — see D-22.

- **`[contexte: lourd]` tag** (new, set by Fable at design time): tasks with predictable heavy output — multi-capture visual audits, live-system capture sessions, builds, verbose test suites — are ALWAYS delegated by `/plan-run` to a `task-executor`, even solo; images and logs stay out of the run session. Untagged legacy plans: same rule by detection. The former soft "exception" wording did not survive contact with a real run.
- **Runs continue through compaction**: on saturation, finish the task, write state, keep going (mandatory full plan re-read after compaction, per D-09). "Propose a relaunch" is now only the fallback when the session itself dies — re-entrance unchanged.
- **User validation lives only in gate tasks**: `/plan` and `/plan-rework` no longer write "validation by the user" as a criterion on regular tasks (machine-checkable criteria + named evidence instead; subjective sign-off batched at explicit gates). `/plan-run` treats legacy mid-plan validation criteria as: constate the technical part, attach evidence, defer to the next gate. Stopping at a gate is a run's normal end, not a failure.

## [0.21.0] — 2026-07-03

**The inversion.** A measured head-to-head (same request, cold start) showed the multi-agent conception pipeline at $7.13 / 25m19 API vs $0.77 / 91s for direct Fable, with equivalent design quality — the dominant cost being the Sonnet orchestrator relay (56%). Design now runs IN a Fable session; execution stays Sonnet. See D-21 (and the superseded/adapted markers on D-01…D-20).

- **`/plan`, `/plan-rework`, `/plan-prompt` require a Fable session** (guard inverted; `/plan-run` keeps its Sonnet guard). The Fable session understands, challenges (GATE only when genuinely needed), and **writes the plan itself** — no more architect/developer round-trips.
- **Delegation of volume survives as hard rules**: the Fable session never reads project files, browses the web, calls MCP inspection tools or loads screenshots — exploration, research (4-fetch cap, injection quarantine), inventories and verbatim evidence packs run in Sonnet/Haiku sub-agents returning compressed syntheses.
- **Agents retired**: `plan-architect`, `plan-developer`, `task-verifier`, `fable-advisor`. Kept: `plan-explorer`, `task-executor` (now always Sonnet, for parallel dispatch).
- **`/plan-run` simplified**: the session applies tasks itself (inline — zero spawn cost) and dispatches parallel `task-executor`s only for disjoint `[touche:]` scopes; criteria constated on evidence by the session (finding before verdict, unverifiable ≠ validated, frozen-test diff check); retry → Plan B → **stop-and-synthesize**: the run stops, writes a `Synthèse de blocage` (with an empty `Directive de reprise`) into the plan, and the user has Fable arbitrate; pasting the directive and relaunching resumes exactly there.
- **Template**: per-task `[modèle:]` and `[vérif:]` tags, escalation policy/budget removed; new **Contrat d'exécution** section and blockage-synthesis format; `Conso cumulée` now prefers the transcript-measured real cost. **Legacy plans still run** (old tags and budget lines ignored).
- **Recap reworked**: transcript-based cache-inclusive real cost is the primary figure; sub-agent non-cache volumetry secondary; the "without the plugin" comparison retired (the session IS Fable).
- Anti-truncation kept without tranche files: Fable writes long plans in several Write/Edit passes (blocks of 3-4 tasks).
- **Benchmarks harness restored** (`benchmarks/` — protocol, `bench-report.sh`, versioned results; CONTRIBUTING had kept a dangling reference since 0.20 dropped it). Rates in the recap blocks validated against the measured sessions (per-model error ≤ +16 %).
- **Projected gains** (from measured components, method in `benchmarks/results/2026-07-03-conception.md`): /plan ~$7.13 → ~$3.2 (−55 %) and ~37 → ~10-13 min (−60/70 %); Fable line ~1.5× ($1.04 → ~$1.55) — the accepted D-21 trade. /plan-run: ~2 spawns avoided per sequential task (~30k harness tokens each), orchestration overhead roughly −40 %.

## [0.20.0] — 2026-07-03

Architect flexibility + small-model push, driven by field feedback (Fable understood Unreal requests far better than Opus — so Fable leads by default, and "Opus builds, Fable signs off" becomes a knob pair, not a doctrine change). See D-20.

- **`--architecte=opus` knob** (/plan, /plan-rework): same missions and contracts on a non-frontier architect for routine plans — zero conception Fable; the recap notes it.
- **`--validation-fable` knob**: after the gates, Fable validates a **digest** of the developed plan (statement + decisions + condensed task list + gate deviations — never the operating procedures) and answers `GO` or numbered `OBJECTIONS:`, routed like `INCOHÉRENCES:`. One pass, no loop. Recommended with `--architecte=opus`.
- **Evidence pack on haiku** (mechanical verbatim extraction — copy, never summarize).
- **Empirical model assignments**: run reports now record per-model rates (tasks, first-pass PASS, retries, Plan Bs, escalations); lessons propose rate-backed reassignments that flow into future architect briefs.
- **Skill slimming**: measurement evidence moved to `DECISIONS.md` (D-18 pointers); rules stay, proofs don't ride in every session's context.
- **Frictionless by default**: the upfront Fable phase is *understanding first, challenge second* — questions asked only when a real comprehension doubt or structuring choice exists (never for comfort); the final validation gate is removed — `/plan` and `/plan-rework` run end-to-end and write plans `🟢 validé` (the `🟡` status remains for explicitly requested reviews; the deletion gate in `/plan-rework` is untouched). The `/plan`↔`/plan-run` separation is the safety: nothing executes until the user launches the run.

## [0.19.0] — 2026-07-03

Fable-frugality pass: the steering metric becomes **absolute Fable tokens** (the quota-capped resource), after transcript measurement showed each Fable invocation carries ~30k harness tokens around a ≤1k-word brief (129k Fable context for 15.6k of judgment on one conception). See D-19 and amended D-02/D-12.

- **Single-pass contract**: the architect chains the skeleton into the rechallenge response when it raises no question and no gap — one Fable invocation instead of two on clean requests; the user GATE then validates both together.
- **Continuation, never relaunch**: post-GATE skeleton, completeness-loop answers and the advisor's INVESTIGUER answer are sent as deltas into the same Fable conversation; full relaunch only when the harness lacks continuation.
- **Invocation dedup**: skills no longer recopy mission texts that live in the agents' system prompts; the `general-purpose` fallback inlines `agents/plan-architect.md` itself.
- **Output discipline (hard)**: Fable agents never recopy or paraphrase the brief — reference, don't redefine.
- **Fable KPI**: every recap ends with `Fable : n appels · nk in · nk out` (even at 0); plan headers cumulate lifetime Fable tokens (`dont Fable`), header label fixed to "volumétrie hors cache".
- Projected on the measured conception: ~129k → ~55-70k Fable tokens, judgment unchanged. Orchestrator stays Sonnet by measurement (the seat processed 6.1M tokens — 47× Fable's).

## [0.18.0] — 2026-07-03

Performance pass driven by transcript-level measurement of a real conception run (cache-inclusive, API rates: $23.61 real vs $5.04 shown by the recap; baseline plain-Fable $8.77) — see D-12/D-16 amended and D-18 in `DECISIONS.md`.

- **Evidence pack (dossier de pièces)**: after the skeleton, a Sonnet agent extracts verbatim excerpts (signatures, blocks to modify) of every file the skeleton cites; `plan-developer` works from it, capped at **10 reads per tranche**, reporting `PIÈCE MANQUANTE` instead of hunting. *Measured without it: 87 Opus self-exploration calls, $8.95 — the command's largest cost.*
- **Tranche files, not chat tranches**: `plan-developer` gets Write (restricted to `<plan>.tranche-N.md`) and writes each tranche to disk with the end marker as last line; the orchestrator assembles with `cat` and never carries plan text in its context. Continuation ("SUITE : T4–T7") preferred over relaunch. *Measured: 218k orchestrator output tokens re-emitting the plan (48.5k for the final Write alone).*
- **Fail-fast tool probe**: agents that need MCP tools verify them in ONE call and return ÉCHEC OUTILS immediately if absent; the orchestrator doesn't relaunch and defers to a run-time T0. *Measured: 13 wandering calls, $1.18 for nothing.*
- **Web fetch cap**: `[web]` researchers are limited to 4 fetches/searches then synthesize. *Measured: 18 calls for one question.*
- **Batched gates**: the haiku verifier extracts all references first and checks them in one scripted pass. *Measured: 42 round-trips.*
- **Honest recap, measured cost**: the token table is now labeled non-cache volumetry (never "upper bound" — real traffic measured at 4-5× that figure); when the session transcript is reachable (Claude Code CLI + jq), the recap adds the real cache-inclusive cost per model. `benchmarks/bench-report.sh` prices runs at the same API rates.

## [0.17.0] — 2026-07-03

Fixes derived from the first two real post-release runs (a lighting /plan and a map-life /plan-rework) — see D-16/D-17 and the amended D-04/D-06/D-12 in `DECISIONS.md`.

- **Tranche-based Opus development** (anti-truncation): beyond 6 skeleton tasks, `plan-developer` is invoked in tranches of ≤4 tasks with an identical verbatim prefix (cache-friendly) and mandatory `FIN DE TRANCHE`/`FIN DU PLAN` end markers; a missing marker re-asks the same tranche, never hand-reassembly. *Observed: a 12-task rework truncated and double-billed Opus (46% of the command).*
- **Hard delegation interdictions**: the orchestrator never searches the web, probes a live system over MCP (dumps, screenshots), or runs the reference/fidelity gates itself — dedicated agents only; live-MCP inspection gets an explicit `general-purpose` sonnet route (plan-explorer has no MCP tools). *Observed: inline web research paid twice, quarantine bypassed, gate run in-session.*
- **Actionable Fable-share alert**: when the >35% alert fires, the recap details every Fable call (mission, tokens) and qualifies the cause — leaky brief vs. structurally small command. *Observed: two consecutive alerts (48%, 39%) impossible to diagnose.*
- **Text-only briefs**: user-attached images are described in the brief (the decision-relevant facts), never forwarded to Fable agents.
- **Inter-plan ordering**: optional `À exécuter après` plan-header line, enforced by `/plan-run` at load (STOP + explicit GO if the prerequisite plan isn't ✅); `/plan` and `/plan-rework` set it on scope/mutex overlap or logical dependency.
- Cumulative-cost recap line clarified as never-omitted, including for the `/plan` that just created the file.

## [0.16.0] — 2026-07-03 — Public release

- **Renamed** plan-runner → **fablewise**; per-project files renamed to `.claude/fablewise-lessons.md` and `.claude/fablewise-notify`.
- English marketing README (goal, pipeline diagram, install, cost & quality rationale), MIT `LICENSE`, `CONTRIBUTING.md` (four-layer rule, issue format, roadmap), `.claude-plugin/marketplace.json` (the repo is its own marketplace), `.gitignore`.

## [0.15.1] — 2026-07-03

- **Per-plan cumulative cost** without any extra file: the plan header carries `Conso cumulée` (design / runs / total), updated by every command touching the plan and echoed in the end-of-command recap.

## [0.15.0] — 2026-07-03

- **Indirect prompt-injection defense** (official Anthropic guidance): web researchers are read-only and return typed summaries; external content wrapped in random-suffix `untrusted` tags with "data, not instructions" + task restated after the block; no untrusted verbatim ever reaches the Fable/Opus agents; file content is data, never orders (explorer + executor).
- **Pairwise verdicts**: when both the main attempt and Plan B produced results, the verifier judges A vs B per criterion (comparative judging is more reliable than absolute scoring).
- **Opt-in notifications**: `.claude/fablewise-notify` (ntfy/webhook URL) → push on gates, escalations, blocked tasks, run end.
- **Anti-drift anchor**: full plan re-read required after any context compaction (negative constraints are the first casualties of summaries).

## [0.14.0] — 2026-07-03

- **Anchored edits** (anti-hallucination): executors quote the exact lines before modifying; missing anchor = reported block, never a guess; "reporting BLOCKED is a success, inventing a workaround is a failure".
- **Cache-friendly dispatching**: same-model executors back-to-back (~5 min subagent cache TTL, exact-prefix, per-model), shared boilerplate verbatim at prompt head, task section at tail.
- **Environment contract**: optional T0 task establishing THE smoke-test command; every playbook starts by running it.
- **Genericized exclusive resources**: `editor`/`db`/`device`/`dev-server` named mutexes replace the Unreal-specific wording — the plugin is now fully engine/stack-agnostic.

## [0.13.0] — 2026-07-03

- **Per-criterion binary rubric verification**: 1-4 specific criteria per task, judged one by one, rationale before verdict, `UNKNOWN` allowed (≠ pass), `VERDICT GLOBAL` last line.
- **Copied-checklist discipline** for executors + ban on "I'll handle the rest" summarizing.
- **Typed CHECKPOINT block** ending every task (status/files/commands/criteria/deviations/verification), copied into the plan Journal — free reasoning, typed artifact.
- **Test-first**: acceptance tests written to fail, committed, then frozen — any test modification is an instant FAIL.
- **Pre-mortem**: the architect writes the fictional past-tense incident report of the plan's failure; each cause becomes an extra criterion or a Plan B.

## [0.12.0] — 2026-07-03

- **Mechanical parallelism** on mandatory `[touche:]` scope tags (empty intersection = parallel), exclusive resources as global mutexes, **no worktrees ever** (live editor/engine/server on the working folder).
- **`[groupe:]` micro-task batching** into a single executor (spawn overhead economy), per-task reporting and verdicts preserved.
- **Verification/execution pipelining** restricted to scope-disjoint, non-dependent tasks.
- **Minimal dispatch** rule: executor prompts never contain run history.

## [0.11.0 / 0.11.1] — 2026-07-03

- Two full consistency audits across the four layers (skills / agents / template / README): 15 desynchronizations fixed, including the executor prompt missing the playbook, unspecified replacement-task numbering (`T<n>.1`), skeleton-fidelity gate added to the reference gate, `/plan-prompt` mission added to the architect, false-positive Fable-share alert exempted for `/plan-prompt`.

## [0.10.0] — 2026-07-03

- **Method per task** (chosen approach + rejected alternative) decided by Fable in the skeleton.
- **`[risque: haut]` + pre-decided Plan B**: the fallback is designed by the strongest model at planning time, applied after 2 failures without consuming an escalation.
- **Three-response advisor**: `DIRECTIVE:` / `INVESTIGUER:` (one Sonnet lookup then re-arbitration) / `REDÉCOUPER:` (replacement mini-skeleton, developed by Opus, traced in the plan) — formalized mid-run course changes.
- End-of-command reminder: "execute in a NEW Sonnet session" with paste-ready prompt.

## [0.9.0] — 2026-07-03

- **Skeleton-fidelity gate** (no task added/dropped, models/deps/decisions intact).
- Worktrees removed; **project lessons file** (`.claude/…-lessons.md`, user-approved writes) read at command start, fed by run reports and error investigations.
- **Cost recap as a chart-style table** with per-model cost estimates and "vs all-Fable" savings bar; >35% Fable share alert (leaky-brief signal).

## [0.8.0] — 2026-07-03

- **Skeleton (Fable) / development (Opus) split**: Fable outputs only judgment (decisions, task list, assignments); Opus expands each task into an ultra-prescriptive step-by-step playbook executable "without thinking"; premium output cost moves from Fable to Opus rates.

## [0.7.0] — 2026-07-03

- **Completeness loop** (Sonnet ↔ Fable ping-pong): the architect returns either the skeleton or a typed `MANQUES:` list (`[projet]`/`[web]`), researched by Sonnet and merged back; max 2 loops; residual gaps flagged `⚠`, never silently filled.

## [0.6.0] — 2026-07-03

- **Compressed briefs** mandatory before any Fable call (verbatim identifiers preserved, prose eliminated, ≤800 words).
- Architect and advisor stripped of all tools (curated context only); mandatory delegation of inventories (>2 files).
- **Anti-hallucination gate** (Haiku greps every cited path/class/asset) and **concurrency guard** before source deletion.

## [0.5.0 / 0.5.1 / 0.5.2] — 2026-07-02/03

- New command **`/plan-prompt`** (one-shot: optimal prompt + recommended model, no plan file).
- Consumption recap made mandatory at end of every command; cache honesty rules (raw upper-bound figures, no invented ratios).

## [0.4.0 / 0.4.1] — 2026-07-02

- `/plan-rework`: **error investigation by Fable** (root causes from journals, lessons applied to the rebuild); sources **deleted** after the heritage digest is written (Git keeps history); errors recorded in the plan only — no side files.
- **Visual-verification policy**: mechanical checks preferred; screenshots minimal/cropped/single; image analysis by Sonnet only (`[vérif: sonnet]`).

## [0.3.0] — 2026-07-02

- `/plan-rework` rebuilt as the heavy-lift command: merge old plans, re-challenge their original intents, full /plan pipeline from existing material, old→new mapping gate.

## [0.2.0] — 2026-07-02

- `run` renamed **`plan-run`**; `plan-rework` introduced.

## [0.1.0] — 2026-07-02

- Initial release: `/plan` (explore → Fable challenge → research → plan) and `/run` (execute/verify/escalate loop), 5 agents with pinned models, plan template, model guard (Sonnet-only orchestration), escalation budget.
