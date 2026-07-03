# Design decisions

The *why* behind fablewise's mechanisms — condensed from the 16 iterations that produced v0.16.0 (see `CHANGELOG.md`). Read this before proposing changes: most "simplifications" reintroduce a failure listed here. Format: decision → rationale → evidence.

## D-01 — The orchestrating session must be Sonnet (hard guard)

The most expensive seat in an agent loop is the orchestrator: every tool result, report and file read transits through its context, on every turn. Running it on the premium model burns judgment-priced tokens on coordination. The Étape 0 guard blocks Fable/Opus sessions in all four commands. *Evidence: real runs measured before the guard; the entire cost model collapses without it.*

## D-02 — Fable outputs judgment only, never work

`plan-architect` and `fable-advisor` produce skeletons, decisions, directives — never code, never full documents. Premium output is the single most expensive token class ($50/MTok); capping it at judgment is the core arbitrage. A hard output discipline completes it: Fable agents never recopy or paraphrase the brief — identifiers are referenced, never redefined. *Evidence: early runs where the architect wrote full plans cost 70–85k Fable tokens per pass; skeletons cost 5–10k. Deliberately re-examined 2026-07-03 against a measured plain-Fable baseline (design quality was equivalent): the split's dollar case is thin, but the plugin's stated objective is minimizing ABSOLUTE Fable consumption (the quota-capped resource) — under that metric, Fable must never hold volume, and never be the orchestrator seat (measured: the orchestrator seat processed 6.1M tokens for one conception; Fable's seat 129k).*

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

## D-12 — Honest cost accounting: labeled non-cache volumetry + measured real cost

The recap table (blended rates, 80/20 in/out) is explicitly labeled **non-cache volumetry** — the `subagent_tokens` the Agent tool returns exclude cache traffic, and cache dominates real cost (writes at 1.25× input rate, reads at 10%). It must NEVER be presented as an upper bound or as billed cost: a measured run showed real API-rate cost at **4.7× the recap figure** ($23.61 vs $5.04 "majorant"). When the environment allows (Claude Code CLI + jq), the recap adds the **real cache-inclusive cost** computed from the session transcript (main jsonl + subagents/); otherwise "n/d", never guessed. The "without the plugin" comparison stays on the same non-cache basis — volumetries, not invoices. Missing usage = "n/d"; session coordination visible via /context; >35% Fable share flagged with per-call breakdown (mission, tokens) and a qualified cause — leaky brief vs. structurally small command — exempted for /plan-prompt. Cumulative cost lives in the plan header (D-09), including lifetime Fable tokens (`dont Fable`) — the recap's steering metric is the absolute Fable line (calls · in · out), per D-19; the share alert is only a leak detector. Estimates presented as measurements destroy trust in the whole recap. *Evidence: transcript-measured wakes conception (fablewise $23.61 real vs $5.04 recap; baseline $8.77 real vs $4.39 /cost); two earlier runs above the Fable threshold (48%, 39%) undiagnosable without per-call detail.*

## D-13 — Granularity floor, grouping, cache-friendly dispatch

Each agent spawn has a fixed startup cost; tasks never go below "a coherent, testable, committable increment"; consecutive mechanical micro-tasks share one executor via `[groupe:]` (per-task reports and verdicts preserved). Same-model executors dispatch back-to-back with identical shared prefixes (subagent cache: per-model, exact-prefix, ~5 min TTL). *Evidence: community-measured spawn overhead; official prompt-caching docs.*

## D-14 — French skills at v1, English on the roadmap

The plugin was built and battle-tested in French. Instructions work regardless (outputs follow the project's language), but EN translation is the top adoption lever — tracked in CONTRIBUTING roadmap rather than blocking release.

## D-15 — The repo is the marketplace

`.claude-plugin/marketplace.json` in-tree; users add `Liberateur/FableWise` and sync updates from tags. No GitHub releases to maintain, no packaged artifacts in the tree (`*.plugin` is gitignored). Version = tag = changelog is the whole release process.

## D-16 — Opus develops long plans in bounded tranches, written straight to tranche files

Single-response plan development collides with the per-response output limit: beyond ~6 skeleton tasks, the plan truncates mid-task and the recovery costs a full second Opus pass. `plan-developer` is invoked in tranches of ≤4 tasks and **writes each tranche itself to a file** (`<plan>.tranche-N.md`, Write restricted to that path); the last line must be a `FIN DE TRANCHE` / `FIN DU PLAN` marker (missing = invalid, same tranche re-asked — never hand-reassembled). The orchestrator assembles with `cat` and deletes the tranche files: plan text never transits through chat or the orchestrator's context. Reason: with chat-rendered tranches the orchestrator re-emitted the whole plan at Sonnet output rates and carried it in context for the rest of the command. Follow-up tranches prefer CONTINUATION of the same agent (context kept, prefix paid once); fallback is relaunch with the identical verbatim prefix (skeleton + brief + evidence pack + template) dispatched back-to-back (D-13 cache). *Evidence: a 12-task rework truncated mid-development, double-billing Opus (202k tokens); a measured 11-task plan where the orchestrator's re-emission cost 218k output tokens (48.5k for the final Write alone) — 42% of its main-thread cost.*

## D-17 — The orchestrator never self-serves delegated steps (hard interdictions)

Web search, live-system MCP inspection (editor/engine dumps, screenshots) and gate greps always run in dedicated agents, even when inline looks faster. Three reasons: inline web bypasses the injection quarantine (D-11), inline MCP dumps and screenshots bloat the session context for the rest of the command (against D-01's economics), inline gating breaks verdict independence (D-07). The skills state these as hard interdictions — soft prescriptions ("lancer un agent…") proved insufficient: the orchestrator complies when convenient and improvises when a prescribed agent lacks the needed tools (plan-explorer has no MCP tools). *Evidence: a rework run where the orchestrator searched the web directly AND paid a delegated agent for the same research, ran the reference gate itself (no haiku line in its own recap), and pulled five editor screenshots into session context.*

## D-18 — Subagent tool-call budgets (evidence pack, fetch caps, batched gates, fail-fast probes)

Inside a subagent the real cost driver is the **tool-call count**: every round-trip re-reads the whole context and extends cache writes at 1.25× the input rate, so an agent that "just looks around" multiplies its own cost. Four budgets, all measured on one real conception run: the plan developer receives a **dossier de pièces** (verbatim excerpts collected by a Sonnet agent from the files the skeleton cites) and is capped at 10 reads per tranche, reporting `PIÈCE MANQUANTE` instead of hunting (without it: 87 Opus calls of self-exploration, $8.95 — the single largest cost of the command); web researchers are capped at **4 fetches** then synthesize (observed: 18 calls for one question, $1.35); gate verifiers extract ALL references first and check them in **one scripted pass** (observed: 42 haiku round-trips); agents needing MCP tools start with a **single fail-fast probe** and return ÉCHEC OUTILS immediately if unavailable (observed: 13 wandering calls without its tools, $1.18 for nothing). Budgets are stated in the skills as hard rules — soft "be efficient" wording does not survive contact with an agent loop.

## D-19 — One Fable conversation per command; single pass when the request is clean

The steering metric is **absolute Fable tokens** (the quota-capped resource), not relative share or total dollars. Measured: each Fable agent invocation carries ~30k tokens of harness/system context around a ≤1k-word brief, and the two mandatory passes (rechallenge, skeleton) cost 129k Fable context for 15.6k of rendered judgment — with zero cache reuse between them (the user GATE outlives the 5-min TTL). Three mechanisms: (1) **single-pass contract** — the architect chains the skeleton into the same response when the rechallenge raises no question and no gap (one invocation instead of two on clean requests); (2) **continuation, never relaunch** — the skeleton after a GATE, completeness-loop answers, and the advisor's INVESTIGUER answer are sent as deltas into the SAME conversation (relaunch with a full re-compressed brief only when the harness lacks continuation); (3) **invocation dedup** — skills stop recopying mission texts that already live in the agents' system prompts (each repeat is Fable input paid twice); the fallback `general-purpose` route reads `agents/plan-architect.md` and inlines the missions itself. The recap always shows the absolute line `Fable : n appels · nk in · nk out`, and each plan header cumulates lifetime Fable tokens (`dont Fable`). Projected: ~129k → ~55-70k Fable per conception, unchanged judgment.

## D-20 — Fable leads, never trails: architect default + digest-only validation + empirical assignments

Three linked choices. (1) **Fable stays the default architect** — the highest-leverage moment of a command is understanding the request; a comprehension error there poisons skeleton, plan and run, and review-after catches less than deciding-before. *Evidence: user-reported field experience on Unreal work — Fable understood the requests far better than Opus; the measured baseline confirmed Fable's design judgment.* (2) **`--architecte=opus` knob** for routine plans (clear scope, known system): same missions and contracts, zero conception Fable — with `--validation-fable` recommended as compensation: Fable then validates a **DIGEST** (consolidated statement + decisions + condensed task list + gate deviations — never the operating procedures: a full 595-line plan is ~50k of Fable input, a digest ~5-8k), answering `GO` or numbered `OBJECTIONS:` routed like `INCOHÉRENCES:`, one pass, no loop. Together the two knobs implement "Opus/Sonnet build, Fable signs off" as a user choice, not a doctrine change. (3) **Model assignments become empirical**: the run report records per-model rates (tasks, first-pass PASS, retries, Plan Bs, escalations), lessons propose reassignments backed by those rates, and future architect briefs carry them — because aggressive haiku downgrades can backfire on the Fable budget (a twice-failed task escalates to the advisor), the arbitration must come from the project's own data, not from cost doctrine. The evidence pack runs on haiku (mechanical verbatim extraction — copy, never summarize).
