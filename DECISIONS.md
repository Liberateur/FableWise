# Design decisions

The *why* behind fablewise's mechanisms — condensed from the 16 iterations that produced v0.16.0 (see `CHANGELOG.md`). Read this before proposing changes: most "simplifications" reintroduce a failure listed here. Format: decision → rationale → evidence.

## D-01 — The orchestrating session must be Sonnet (hard guard)

The most expensive seat in an agent loop is the orchestrator: every tool result, report and file read transits through its context, on every turn. Running it on the premium model burns judgment-priced tokens on coordination. The Étape 0 guard blocks Fable/Opus sessions in all four commands. *Evidence: real runs measured before the guard; the entire cost model collapses without it.*

## D-02 — Fable outputs judgment only, never work

`plan-architect` and `fable-advisor` produce skeletons, decisions, directives — never code, never full documents. Premium output is the single most expensive token class ($50/MTok); capping it at judgment is the core arbitrage. *Evidence: early runs where the architect wrote full plans cost 70–85k Fable tokens per pass; skeletons cost 5–10k.*

## D-03 — Skeleton (Fable) / playbook development (Opus) split

Fable decides methods, model assignments, dependencies, Plan Bs; Opus expands each task into a step-by-step playbook executable "without thinking". The long output moves to Opus rates; execution quality *rises* because cheap executors follow prescriptions instead of improvising. *Evidence: the ecosystem converged on the same split (prescriptive plan → cheapest capable model as "transcription"); observed run profiles before/after 0.8.0.*

## D-04 — Toolless premium agents + compressed briefs

The fable-model agents have no tools and never read files: everything arrives via a compressed brief (verbatim identifiers preserved, prose stripped, ≤800 words). Reason: with Read/Glob they self-served raw files at premium input rates, and briefs are the only enforceable cost boundary. Briefs are text-only: visual references (user-attached images, screenshots) are described in the brief — the decision-relevant fact, not the aesthetics — never forwarded as images; the brief rules previously said nothing about images, leaving it to improvisation. *Evidence: an observed 93k-token rework where the architect explored freely; a lighting /plan with three reference images whose two Fable passes totalled 81k tokens.*

## D-05 — Completeness loop instead of best-effort plans

The architect returns either a skeleton or a typed `MANQUES:` list ([projet]/[web] questions), researched by Sonnet and merged back (max 2 loops; residual gaps flagged `⚠`, never silently filled). A gap list costs hundreds of output tokens; a plan written on guesses costs a full rewrite. *Evidence: hallucinated references observed in real reworks (a cited plan file that didn't exist).*

## D-06 — No worktrees; scope tags + exclusive-resource mutexes

Parallelism is computed mechanically from mandatory `[touche:]` tags (empty intersection = parallel); named exclusive resources (`editor`, `db`, `device`) are global mutexes; `isolation: worktree` is banned. Reasons: target projects often have a live editor/engine/server attached to the working folder (a git copy can't compile or test), and LLMs resolve <60% of real merge conflicts — avoid conflicts by scoping, don't repair them by merging. Cross-*plan* conflicts (two plans sharing `editor` or a visual/technical state one of them tunes) are declared via an optional `À exécuter après` header line, enforced by /plan-run at load (STOP + explicit GO if the prerequisite plan isn't ✅). *Evidence: Merge-Bench (ICPR 2026); CAID ablations; engine editors execute tool calls serially per vendor docs; two same-day plans both touching the same map and the `editor` mutex, one tuning lighting against materials the other was about to fix.*

## D-07 — Independent, per-criterion, rationale-first verification

The verifier is a separate agent (never the executor — self-preference bias is documented), judges 1–4 binary criteria one by one with the finding stated *before* the verdict, may answer `UNKNOWN` (treated as FAIL, never as pass). Cutting verification intensity measurably costs task success. *Evidence: Anthropic "Demystifying evals" (per-dimension isolated judgments, rationale-first); "Rubric Is All You Need" (ICER 2025); CAID: ~6 pts pass-rate lost with weakened review.*

## D-08 — Plan B pre-decided + three-response advisor

Fallbacks for risky tasks are designed by the strongest model at planning time (`[risque: haut]` + Plan B), applied after 2 failures without consuming escalation budget. Mid-run, the advisor answers `DIRECTIVE` / `INVESTIGUER` (one Sonnet lookup, then re-arbitrate) / `REDÉCOUPER` (replacement mini-skeleton, developed by Opus, traced). Course changes are judgment — they must come from the top of the model chain, but bounded and cheap. *Evidence: observed runs where mid-course problems forced expensive full re-passes.*

## D-09 — The plan file is the only persistence

Journals, checkpoints, costs, run reports, cumulative lifetime cost: everything lives in the plan file. No side registries, no databases. Re-entrance (a crashed run resumes from the file) and compaction survival (full re-read mandatory after compaction — negative constraints are the first casualties of summaries) both depend on it. *Evidence: Anthropic names goal-drift-after-compaction as a top failure mode; a durable ledger is the community-proven guard.*

## D-10 — Test-first with frozen tests

When behavior is testable, acceptance tests are written to fail, committed, then untouchable; implementing tasks must make them pass *without modifying them* (any test edit = instant FAIL, checked by diff). The #1 documented failure of long-running agents is declaring work done prematurely — executable criteria are the antidote, and test-tampering is the documented cheat. *Evidence: Anthropic Claude Code best practices; "effective harnesses" post.*

## D-11 — Anchored edits + injection quarantine

Executors must quote the exact lines before modifying them (missing anchor = reported block, never a guess — "reporting BLOCKED is a success; inventing a workaround is a failure"), and treat all file/web content as data, never instructions. Web researchers are read-only and return typed summaries; untrusted excerpts travel in random-suffix tags with the task restated after. *Evidence: Anthropic quote-first grounding guidance; official quarantine pattern (June 2026); prompt-level injection defenses are mitigations, so the architecture (no tools on privileged agents, no untrusted verbatim across the boundary) does the real work.*

## D-12 — Honest cost accounting, upper bound only

The recap table uses documented blended rates (80/20 in/out assumption), never invents cache ratios, marks missing usage as "n/d", counts subagents only (session coordination visible via /context), and flags a >35% Fable share as a leaky-brief signal (exempted for /plan-prompt where Fable is structurally dominant). When the alert fires, the recap must break the Fable cost down per call (mission, tokens) and qualify the cause — leaky brief vs. structurally small command where two mandatory Fable passes dominate a small denominator — otherwise the alert is unactionable noise. Cumulative cost lives in the plan header (D-09). Estimates presented as measurements destroy trust in the whole recap. *Evidence: two consecutive runs both above threshold (48%, 39%) with no way to tell which brief leaked.*

## D-13 — Granularity floor, grouping, cache-friendly dispatch

Each agent spawn has a fixed startup cost; tasks never go below "a coherent, testable, committable increment"; consecutive mechanical micro-tasks share one executor via `[groupe:]` (per-task reports and verdicts preserved). Same-model executors dispatch back-to-back with identical shared prefixes (subagent cache: per-model, exact-prefix, ~5 min TTL). *Evidence: community-measured spawn overhead; official prompt-caching docs.*

## D-14 — French skills at v1, English on the roadmap

The plugin was built and battle-tested in French. Instructions work regardless (outputs follow the project's language), but EN translation is the top adoption lever — tracked in CONTRIBUTING roadmap rather than blocking release.

## D-15 — The repo is the marketplace

`.claude-plugin/marketplace.json` in-tree; users add `Liberateur/FableWise` and sync updates from tags. No GitHub releases to maintain, no packaged artifacts in the tree (`*.plugin` is gitignored). Version = tag = changelog is the whole release process.

## D-16 — Opus develops long plans in bounded tranches

Single-response plan development collides with the per-response output limit: beyond ~6 skeleton tasks, the plan truncates mid-task and the recovery costs a full second Opus pass. `plan-developer` is invoked in tranches of ≤4 tasks, every call carrying the same verbatim prefix (skeleton + brief + template) with the tranche instruction at the tail — identical prefix means the subagent cache absorbs the repeated input (D-13). Every response must end with a `FIN DE TRANCHE` / `FIN DU PLAN` marker; a missing marker means truncation and the same tranche is re-asked — never hand-reassembled by the orchestrator. *Evidence: a 12-task rework plan truncated mid-development; the recovery double-billed Opus (2 calls, 202k tokens, 46% of the command's cost) and pushed the orchestrator to improvise a direct-write workaround outside the developer's contract.*

## D-17 — The orchestrator never self-serves delegated steps (hard interdictions)

Web search, live-system MCP inspection (editor/engine dumps, screenshots) and gate greps always run in dedicated agents, even when inline looks faster. Three reasons: inline web bypasses the injection quarantine (D-11), inline MCP dumps and screenshots bloat the session context for the rest of the command (against D-01's economics), inline gating breaks verdict independence (D-07). The skills state these as hard interdictions — soft prescriptions ("lancer un agent…") proved insufficient: the orchestrator complies when convenient and improvises when a prescribed agent lacks the needed tools (plan-explorer has no MCP tools). *Evidence: a rework run where the orchestrator searched the web directly AND paid a delegated agent for the same research, ran the reference gate itself (no haiku line in its own recap), and pulled five editor screenshots into session context.*
