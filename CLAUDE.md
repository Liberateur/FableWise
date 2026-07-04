# FableWise — project instructions

This repo IS the plugin: there is no build step, no compiled code. The "source" is prompt architecture — markdown skills, agent system prompts, a plan template. The repo doubles as its own marketplace (`.claude-plugin/marketplace.json`): pushing to `main` + tagging is shipping.

**Read `DECISIONS.md` before proposing or accepting any design change.** Every mechanism here exists for a documented reason, usually a failure observed in real runs — undoing one silently reintroduces the failure.

## The four-layer rule (most important)

Any pipeline change MUST propagate to every layer it touches, in the same commit:

1. `skills/*/SKILL.md` — the command workflows
2. `agents/*.md` — the agent system prompts
3. `skills/plan/references/plan-template.md` — the plan artifact format
4. `README.md` — the public contract

Nearly every historical bug in this project was a desynchronization between these layers (an agent keeping an outdated enumeration that its skill had moved past, a template missing a field a skill referenced). After any change, grep the changed concept across all four.

Since v0.23 two more surfaces exist and must be checked when a change touches run semantics: `scripts/` (external completion loop — parses the plan header status) and `hooks/` (Stop hook — same parsing, plus the `.claude/fablewise-autorun` exit contract in `/plan-run`).

## Non-negotiable invariants

Cost (v0.21 seat assignment — see D-21):
- Design commands (`/plan`, `/plan-rework`, `/plan-prompt`) run in a **Fable** session; `/plan-run` runs in a **Sonnet** session. The model guards (Étape 0 of every skill) block the wrong direction and must never be weakened.
- The Fable design session **never holds volume**: no project-file reads, no web, no MCP inspection, no screenshots in session — exploration, research, inventories and evidence packs are delegated to Sonnet/Haiku sub-agents returning compressed syntheses (web agents: 4-fetch cap, injection quarantine per D-11/D-18).
- Fable is never an executor model.

Quality (root-cause discipline since v0.26 — see D-26):
- Criteria are constated ON EVIDENCE by the run session (commands run, diffs read; a sub-agent report is a lead, not a proof), finding-before-verdict, unverifiable ≠ validated. Sub-agent binary artifacts are hash-checked in-session (executor CHECKPOINTs carry `shasum` + size, re-checked); modified live-system properties are re-read independently.
- Null effect = suspect channel: a change that applies cleanly but changes nothing observable triggers an observation-channel audit with a crude discriminating test — never a second blind tuning. A `Directive de reprise` for an unproven cause starts with a discriminating experiment, constated before the fix.
- On any uncovered problem the run **stops without inventing** — `Synthèse de blocage` written into the plan (+1 on the header's `Escalades Fable` budget; exhausted → recommend /plan-rework), user-mediated Fable arbitration via `Directive de reprise`. Reporting a blockage is a success; inventing a workaround is a failure.
- Frozen acceptance tests are untouchable; anchored edits (quote before modify). Execution is user-launched by construction (/plan never runs anything; /plan-run is a separate, deliberate command) and any deletion is user-gated; interactive questions happen only when comprehension genuinely requires them — commands otherwise run end-to-end without approval steps.
- The plan file on disk is the single source of truth: re-entrant, updated after every task, fully re-read after any context compaction. No side registries.

Autonomy (v0.22–0.26 — see D-22…D-28):
- A run stops ONLY on blockage, human-awaited state, or completion — never on context saturation (compaction is crossed; heavy `[contexte: lourd]` tasks are ALWAYS delegated, detection covers untagged ones and writes the tag back into the plan).
- User validation is never a criterion on a regular task — machine-checkable evidence + Journal; subjective sign-off lives in gate tasks. Human-only actions carry `[humain: <geste>]` (designed-in via the capability probe, or learned in-run once a wall is established): never attempted, listed in a decision-ready "Attendu humain" block, header status `⏸ en attente humaine` — a legitimate end for the run, the loop (exit 3) and the hook alike (that's a success).
- The external loop (`scripts/fablewise-loop.sh`, Cowork scheduled tasks) and the Stop hook (`.claude/fablewise-autorun`) relaunch/hold sessions but NEVER cross a blockage, a gate or a `⏸`. Writing the true header state is the hook's exit key; flag deletion is the safety net — that contract lives in `/plan-run` and must match the hook.
- The `Run en cours` header line is the inter-session mutex (fresh < 2 h: interactive runs ask, autonomous relaunches take over and note it; /plan-rework refuses fresh-marked sources). It lives in the plan header — never a lockfile (D-09).
- Runs stay on Sonnet: Sonnet 5 and Opus 4.8 share the same 1M context window (verified 2026-07-03) — a premium seat buys zero autonomy headroom (D-25).

## Release discipline

`plugin.json` version == git tag == `CHANGELOG.md` entry, in the same commit. Semver: prompts-only fixes = patch, new behavior = minor, breaking plan-format changes = major. No GitHub releases to maintain — users sync from the marketplace.

## Testing before commit (manual, minimum)

1. Model guards, both directions: `/plan` from a Sonnet session → must block with the exact alert, zero side effects; `/plan-run` from a Fable/Opus session → same.
2. `/plan` (Fable session) on a small real request → plan conforms to the template (tags `[touche:]`, per-task binary criteria, Méthode line, Contrat d'exécution, pre-mortem), no project file read in session (all delegated), and ends with the real-cost recap + "new Sonnet session" reminder.
3. Anti-hallucination gate: a planted fake path in a plan draft must be flagged `⚠ à vérifier`, not silently written.
4. Stop-and-synthesize: a task with an unfindable anchor must produce a `Synthèse de blocage` in the plan and stop the run — never an improvised edit.
5. Stop hook, four cases (pipe empty stdin to `hooks/fablewise-stop.sh` in a scratch dir): no `.claude/fablewise-autorun` → exit 0 silent; flag + plan `🔄` → valid JSON `{"decision":"block",…}`; flag + plan `✅`/`🔴` → exit 0 silent; flag + plan `⏸` → exit 0 silent.
6. Loop script: `bash -n scripts/fablewise-loop.sh` passes; a plan already `✅` exits 0 on the first iteration without spawning a session… (requires the CLI; at minimum check the status parsing against the template's Statut line).
Roadmap: automate these via skill-creator evals.

## Style

- Skills and agents are currently written in French (English translation is the top roadmap item); README/CONTRIBUTING/CHANGELOG/DECISIONS are English.
- Skill bodies are imperative instructions for Claude, lean, self-contained per file; agent prompts are dense system prompts with hard interdictions spelled out.
- Never put current tuning values in docs where a mechanism is meant to evolve — name the knob and where it lives (plan header, template) instead. Exception: structural constants (loop bounds, sub-agent budgets) and the documented pricing assumptions in the recap blocks.
