# Changelog

All notable changes to **fablewise** are documented here. Format inspired by [Keep a Changelog](https://keepachangelog.com); versions follow [semver](https://semver.org). The plugin was developed iteratively on 2026-07-02/03 under its working name *plan-runner*, renamed *fablewise* for public release.

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
