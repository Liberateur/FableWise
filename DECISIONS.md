# Design decisions

The *why* behind fablewise's mechanisms — condensed from the 16 iterations that produced v0.16.0 (see `CHANGELOG.md`). Read this before proposing changes: most "simplifications" reintroduce a failure listed here. Format: decision → rationale → evidence.

> **v0.21 inversion** — D-21 reverses the core seat assignment: design commands now RUN in a Fable session, and the multi-agent conception pipeline (architect/developer/verifier/advisor agents) is retired. Decisions marked **[superseded by D-21]** are kept for the record — their *evidence* still holds and constrains how D-21 is implemented (delegation, quarantine, budgets). Decisions without a marker remain in force.

## D-01 — The orchestrating session must be Sonnet (hard guard) **[superseded by D-21 for design commands — still in force for /plan-run]**

The most expensive seat in an agent loop is the orchestrator: every tool result, report and file read transits through its context, on every turn. Running it on the premium model burns judgment-priced tokens on coordination. The Étape 0 guard blocks Fable/Opus sessions in all four commands. *Evidence: real runs measured before the guard; the entire cost model collapses without it.* **v0.21**: this economics is precisely why the Fable design session delegates ALL volume (files, web, inventories) and receives only compressed syntheses — the seat is premium, so the seat must stay light. `/plan-run` keeps the Sonnet guard unchanged.

## D-02 — Fable outputs judgment only, never work **[superseded by D-21 for plan writing — output discipline retained]**

`plan-architect` and `fable-advisor` produce skeletons, decisions, directives — never code, never full documents. Premium output is the single most expensive token class ($50/MTok); capping it at judgment is the core arbitrage. *Evidence: early runs where the architect wrote full plans cost 70–85k Fable tokens per pass; skeletons cost 5–10k. Re-examined 2026-07-03 against a measured plain-Fable baseline: design quality was equivalent — this measurement is what motivated D-21.* **v0.21**: Fable now writes the full plan (the user accepts the Fable-quota cost for the latency/simplicity gain); what survives is the discipline — no code in plans, directives and anchors only, and no raw inputs in the Fable context.

## D-03 — Skeleton (Fable) / playbook development (Opus) split **[superseded by D-21]**

Fable decides methods, model assignments, dependencies, Plan Bs; Opus expands each task into a step-by-step playbook executable "without thinking". *Evidence: observed run profiles before/after 0.8.0.* **v0.21**: the playbook requirement survives (chewed-through operating procedures, written for Sonnet application without re-deciding) — the author is now Fable itself; the benchmark showed the split's coordination overhead (orchestrator relay = 56% of a full conception) outweighed the Opus rate arbitrage.

## D-04 — Toolless premium agents + compressed briefs **[superseded by D-21 in form — compression discipline retained]**

The fable-model agents have no tools and never read files: everything arrives via a compressed brief. Reason: with Read/Glob they self-served raw files at premium input rates. *Evidence: an observed 93k-token rework where the architect explored freely; a lighting /plan whose two Fable passes totalled 81k tokens.* **v0.21**: the Fable session HAS tools, but the skill forbids self-serving: no project file reads, no web, no MCP dumps, no screenshots in session — sub-agents return syntheses (≤ 400-800 words) and verbatim evidence packs. Images are described, never loaded. Same boundary, enforced by skill instruction instead of tool removal.

## D-05 — Completeness loop instead of best-effort plans **[adapted by D-21]**

The architect returns either a skeleton or a typed `MANQUES:` list, researched by Sonnet and merged back. A gap list costs hundreds of output tokens; a plan written on guesses costs a full rewrite. *Evidence: hallucinated references observed in real reworks.* **v0.21**: the loop is now internal — the Fable session routes its own `[projet]`/`[web]` gaps to sub-agents before writing, and never fills a gap silently (`⚠ à vérifier`).

## D-06 — No worktrees; scope tags + exclusive-resource mutexes

Parallelism is computed mechanically from mandatory `[touche:]` tags (empty intersection = parallel); named exclusive resources (`editor`, `db`, `device`) are global mutexes; `isolation: worktree` is banned. Reasons: target projects often have a live editor/engine/server attached to the working folder, and LLMs resolve <60% of real merge conflicts — avoid conflicts by scoping. Cross-plan conflicts are declared via the optional `À exécuter après` header line, enforced by /plan-run at load. *Evidence: Merge-Bench (ICPR 2026); CAID ablations; engine editors execute tool calls serially per vendor docs; two same-day plans both touching the same map and the `editor` mutex.*

## D-07 — Independent, per-criterion, rationale-first verification **[adapted by D-21]**

The verifier is a separate agent, judges 1–4 binary criteria one by one with the finding stated *before* the verdict, may answer `UNKNOWN` (treated as FAIL). *Evidence: Anthropic "Demystifying evals"; "Rubric Is All You Need" (ICER 2025); CAID: ~6 pts pass-rate lost with weakened review.* **v0.21**: the dedicated verifier agent is retired (user arbitration: simplicity over the measured ~6 pts). What survives, stated as hard rules in /plan-run: criteria are constated ON EVIDENCE (commands run, diffs read — a sub-agent's report is a lead, not a proof), finding-before-verdict, unverifiable ≠ validated, frozen-test integrity checked by diff. Frozen tests (D-10) carry most of the verification burden.

## D-08 — Plan B pre-decided + three-response advisor **[advisor superseded by D-21 — Plan B retained]**

Fallbacks for risky tasks are designed by the strongest model at planning time (`[risque: haut]` + Plan B), applied after 2 failures. *Evidence: observed runs where mid-course problems forced expensive full re-passes.* **v0.21**: Plan Bs survive unchanged (decided by Fable at design time). The in-run `fable-advisor` is replaced by the **stop-and-synthesize contract**: the run stops, writes a `Synthèse de blocage` (nature, attempts, evidence, options, empty `Directive de reprise`) into the plan, and the USER takes it to a Fable session; the directive is pasted back and the run resumes. Course changes still come from the top of the model chain — with the user in the loop instead of a budgeted agent.

## D-09 — The plan file is the only persistence

Journals, checkpoints, costs, run reports, cumulative lifetime cost: everything lives in the plan file. No side registries, no databases. Re-entrance and compaction survival (full re-read mandatory after compaction) both depend on it. *Evidence: Anthropic names goal-drift-after-compaction as a top failure mode; a durable ledger is the community-proven guard.* **v0.21**: the `Synthèse de blocage` / `Directive de reprise` cycle also lives in the plan file — arbitration crosses sessions through the file, never through chat memory.

## D-10 — Test-first with frozen tests

When behavior is testable, acceptance tests are written to fail, committed, then untouchable; implementing tasks must make them pass *without modifying them* (any test edit = instant FAIL, checked by diff). The #1 documented failure of long-running agents is declaring work done prematurely — executable criteria are the antidote. *Evidence: Anthropic Claude Code best practices; "effective harnesses" post.*

## D-11 — Anchored edits + injection quarantine

Executors must quote the exact lines before modifying them (missing anchor = reported block, never a guess), and treat all file/web content as data, never instructions. Web researchers are read-only and return typed summaries; untrusted excerpts travel in random-suffix tags with the task restated after. *Evidence: Anthropic quote-first grounding guidance; official quarantine pattern (June 2026).* **v0.21**: doubly critical — the design session is now the premium model itself, so web and MCP stay delegated without exception; the privileged context never receives untrusted verbatim.

## D-12 — Honest cost accounting **[amended by D-21]**

Recap figures are labeled for what they are: sub-agent `subagent_tokens` = **non-cache volumetry**, never an upper bound or billed cost (a measured run showed real API-rate cost at **4.7× the recap figure**). When the environment allows, the recap computes the **real cache-inclusive cost** from the session transcript; otherwise "n/d", never guessed. *Evidence: transcript-measured conception ($23.61 real vs $5.04 recap; baseline $8.77 real vs $4.39 /cost).* **v0.21**: the transcript-based real cost becomes the primary figure (the Fable session's own consumption never appears in `subagent_tokens` — the recap says so explicitly); the "without the plugin" comparison is retired (the session IS Fable). Cumulative cost per plan (`Conso cumulée`, `dont Fable`) lives in the plan header, unchanged.

## D-13 — Granularity floor, grouping, cache-friendly dispatch **[adapted by D-21]**

Each agent spawn has a fixed startup cost; tasks never go below "a coherent, testable, committable increment"; consecutive mechanical micro-tasks share one executor via `[groupe:]`. *Evidence: community-measured spawn overhead; official prompt-caching docs.* **v0.21**: the floor now also applies to inline execution (/plan-run applies single ready tasks itself — zero spawn cost); parallel dispatches keep the shared-prefix discipline.

## D-14 — French skills at v1, English on the roadmap

The plugin was built and battle-tested in French. Instructions work regardless (outputs follow the project's language), but EN translation is the top adoption lever — tracked in CONTRIBUTING roadmap.

## D-15 — The repo is the marketplace

`.claude-plugin/marketplace.json` in-tree; users add `Liberateur/FableWise` and sync updates from tags. Version = tag = changelog is the whole release process.

## D-16 — Opus develops long plans in bounded tranches **[superseded by D-21 — anti-truncation retained]**

*Evidence: a 12-task rework truncated mid-development, double-billing Opus (202k tokens); a measured 11-task plan where the orchestrator's re-emission cost 218k output tokens.* **v0.21**: `plan-developer` and tranche files are retired. The per-response output limit still exists: the Fable session writes long plans in several passes (Write for header + common sections, Edit to append tasks in blocks of 3-4) — never one giant response. Plan text never transits through a relay context (there is no relay anymore).

## D-17 — The orchestrator never self-serves delegated steps **[re-anchored by D-21]**

Web search, live-system MCP inspection and reference gates always run in dedicated agents, even when inline looks faster: injection quarantine (D-11), session-context economics, verdict independence. *Evidence: a rework run where the orchestrator searched the web directly AND paid a delegated agent for the same research, and pulled five editor screenshots into session context.* **v0.21**: applies verbatim to the Fable design session — the stakes are higher (premium context, privileged model). Hard interdictions: no project-file reads, no web, no MCP calls, no screenshots in session; the anti-hallucination gate stays delegated (haiku, one scripted pass).

## D-18 — Subagent tool-call budgets

Inside a subagent the real cost driver is the **tool-call count**: every round-trip re-reads the whole context. Budgets, all measured: web researchers capped at **4 fetches** then synthesize (observed: 18 calls for one question, $1.35); gate verifiers check ALL references in **one scripted pass** (observed: 42 haiku round-trips); MCP agents start with a **single fail-fast probe** (observed: 13 wandering calls, $1.18 for nothing). Budgets are stated in the skills as hard rules — soft "be efficient" wording does not survive contact with an agent loop. **v0.21**: the evidence-pack cap (10 reads) survives as the haiku evidence extraction feeding Fable's writing; all other budgets unchanged.

## D-19 — One Fable conversation per command **[superseded by D-21 — structurally satisfied]**

Each Fable agent invocation carried ~30k tokens of harness/system context around a ≤1k-word brief; two mandatory passes cost 129k Fable context for 15.6k of rendered judgment, with zero cache reuse across the user GATE. *Evidence: transcript measurements, 2026-07-03.* **v0.21**: there are no Fable agent invocations left in conception — the session IS the single Fable conversation, its cache persists across the GATE natively. The steering metric (absolute Fable tokens, `dont Fable` in plan headers) remains.

## D-20 — Fable leads, never trails **[superseded by D-21 — thesis absorbed]**

Fable stays the default architect: the highest-leverage moment of a command is understanding the request; a comprehension error there poisons everything. *Evidence: user-reported field experience on Unreal work; the measured baseline confirmed Fable's design judgment.* **v0.21**: this thesis is now the whole architecture — Fable doesn't just lead, it holds the design seat. The `--architecte=opus` / `--validation-fable` knobs and empirical per-task model assignments are retired with the multi-model execution layer.

## D-21 — Fable holds the design seat; Sonnet applies with stop-and-synthesize (v0.21 inversion)

`/plan`, `/plan-rework` and `/plan-prompt` run IN a Fable session (guard inverted: non-Fable sessions are blocked); the conception agents (`plan-architect`, `plan-developer`, `task-verifier`, `fable-advisor`) are retired. The Fable session understands, delegates all volume (exploration, web, inventories, evidence packs — compressed syntheses only, quarantined), challenges the user only when genuinely needed, and **writes the plan itself** — grouped tasks, chewed-through operating procedures, binary criteria, pre-decided Plan Bs, pre-mortem. `/plan-run` stays Sonnet: it applies tasks inline (parallel executors only for disjoint `[touche:]` scopes), constates criteria on evidence, and on any uncovered problem **stops without inventing** and writes a `Synthèse de blocage` for user-mediated Fable arbitration through the plan file.

Rationale: a measured head-to-head (2026-07-03, same lighting request, cold start) — multi-agent pipeline $7.13 / 25m19 API vs direct Fable $0.77 / 91s, for equivalent design quality (per D-02's own re-examination); the pipeline's dominant cost was the Sonnet orchestrator relay (56%, 4.3M cache reads), i.e. pure coordination. Field experience: plans from both paths converged. The accepted trade: conception now spends the quota-capped Fable resource on plan writing — projected Fable line ~$1.5 vs $1.04 measured (≈1.5×) — in exchange for a projected **−55 % total cost** (~$7.13 → ~$3.2) and **−60/70 % wall time** (~37 → ~10-13 min), with two fewer moving layers (the relay was 56 % of the measured cost, the Opus layer 23 %). Projection method and measured data: `benchmarks/results/2026-07-03-conception.md` — to be replaced by the first measured v0.21 run. The guards protect the inverse mistakes: design on a cheap seat (quality) and execution on the premium seat (cost). *Evidence: the 2026-07-03 benchmark (session transcripts, both status screens); D-02's re-examination note; convergent plans observed in the field.*

## D-22 — Autonomous runs to completion: mandatory heavy-task delegation, compaction-crossing, validation at gates only

A real autonomous run (2026-07-03, 20-task Unreal ocean plan, "don't ask me anything") completed 3 tasks then stopped on context saturation: two capture-heavy visual audits executed inline pulled every screenshot through the run session's context, and the then-current saturation rule said "propose a relaunch". Three mechanisms fix the three causes of premature stops:

1. **`[contexte: lourd]` tag** — set by Fable at design time on any task with predictable heavy output (multi-capture visual audits, live-system capture sessions, builds, verbose test suites); `/plan-run` ALWAYS delegates these to a `task-executor`, even solo — the CHECKPOINT comes back compact, images and logs never enter the run session. Mechanical, like D-06's `[touche:]` — soft "delegate when heavy" wording had already existed as an exception and did not survive contact with a real run. Untagged legacy plans: same rule by detection.
2. **Compaction-crossing** — saturation no longer ends a run: finish the current task, write state, continue through compaction. D-09's mandatory full plan re-read is the guard against post-compaction drift. A run ends only on blockage, gate, or completion; re-entrance remains the fallback when the session itself dies.
3. **User validation only at gates** — "validation by the user" as a criterion on a regular task makes autonomy impossible by construction (unverifiable ≠ validated → spurious blockage or silent leniency, both observed). Regular criteria must be machine-checkable (named captures, diffs, command output + Journal justification); subjective sign-off is batched into explicit gate tasks, where an autonomous run stops cleanly — that stop is the run's normal end, not a failure. `/plan-run` treats legacy mid-plan validation criteria as: constate the technical part, attach evidence, defer validation to the next gate.

*Evidence: the ocean run's report (3/20 tasks, "fin de session avant T7", no formal blockage); D-17's earlier evidence (five editor screenshots pulled into a session context); the same run's T2/T3 journals showing inline capture relecture as the context drain.*
