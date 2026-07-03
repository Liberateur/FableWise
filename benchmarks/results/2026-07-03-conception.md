# 2026-07-03 — Conception head-to-head: /plan v0.20 vs direct Fable (+ v0.21 projection)

Same request, cold start, sessions run in parallel on the same machine (Wakewitch project, "cinematic lighting on MainMap" — real codebase, live UE bridge available). No existing plans read (explicit constraint in both prompts). Figures from the CLI `/usage` panels and session transcripts.

## Measured — /plan v0.20 (full multi-agent pipeline, run to completion)

Total **$7.13** · API **25m19** · wall **36m55** · 348 lines written (plan file).

| Model | in | out | cache read | cache write | measured $ | share |
|---|---|---|---|---|---|---|
| sonnet (orchestrator + explorer + 2 web agents) | 52.8k | 48.0k | 4.3M | 374.0k | $3.96 | 56 % |
| opus (plan-developer) | 1.6k | 40.1k | 154.5k | 89.4k | $1.65 | 23 % |
| fable (architect, 2 passes) | 9.6k | 9.4k | 21.4k | 35.7k | $1.04 | 15 % |
| haiku (+6 web searches) | 103.0k | 20.4k | 904.2k | 105.1k | $0.49 | 7 % |

Timeline: exploration 17:40→17:42 (22 tool calls) · Fable questions 17:43 · user GATE 17:44 · 2 parallel web agents 17:44→17:45 · Fable skeleton 17:47 · Opus development + gates + write → 18:17.

**Dominant cost = the Sonnet orchestrator relay** (4.3M cache reads: the session re-reads its growing context every turn for 25 minutes of coordination). This measurement motivated the v0.21 inversion (D-21).

## Measured — direct Fable, no tools (the floor)

Total **$0.77** · API **1m32** · plan delivered in chat **91 s** after prompt. fable: 16.4k in / 6.1k out / 18.3k cache read / 14.2k cache write. Zero tool calls (exploration forbidden by the test prompt).

Design quality: equivalent structure and judgment (per D-02's re-examination), but three groundedness defects the pipeline caught: convolution bloom recommended where official docs say standard-for-realtime (post-cutoff prior, no web check); a static PPV colliding with the project's existing curve-driven architecture (no exploration); "fixed magic hour" self-decided where the user's actual GATE answer was 2-3 keyframes (no rechallenge).

## Rate validation

Published API rates (in $/MTok: fable 10, opus 5, sonnet 3, haiku 1; out = 5× in; cache write 1.25× in; cache read 0.10× in) reproduce the measured session costs:

| Session | calc | measured | error |
|---|---|---|---|
| 0.20 sonnet | $3.57 | $3.96 | +11 % |
| 0.20 fable | $1.03 | $1.04 | +1 % |
| 0.20 opus | $1.65 | $1.65 | ±0 % |
| 0.20 haiku | $0.49 | $0.49 | ±0 % |
| direct fable | $0.66 | $0.77 | +16 % |

Error ≤ +16 % (likely 1h-TTL cache writes billed at 2× on part of the traffic). The rates in the skills' recap blocks and `bench-report.sh` are therefore kept as-is.

## Projection — /plan v0.21 (same request; NOT a measurement)

Method: measured component costs reused where the component survives unchanged; the Fable session modeled from the direct-run baseline plus delegated-synthesis ingestion, multi-turn cache traffic, and plan writing.

| Component | basis | projected $ |
|---|---|---|
| Fable session (understand + GATE + write plan) | 5k in · 10k out · ~450k cache read (~12 turns) · ~45k cache write | ~$1.56 |
| plan-explorer (sonnet) | measured 0.20 component | ~$0.80 |
| 2 web agents (sonnet, 4-fetch cap) | measured 0.20 component | ~$0.60 |
| evidence pack + anti-hallucination gate (haiku) | measured 0.20 component minus web searches | ~$0.25 |
| **Total** | | **~$3.2** |

Projected vs measured 0.20: **cost −55 %** ($7.13 → ~$3.2) · **wall −60/70 %** (~37 → ~10-13 min: exploration ~2 min, web parallel ~1.5, writing ~4-6, gate ~1, plus user GATE time) · pipeline layers 6 → 3. The **Fable line rises ~1.5×** ($1.04 → ~$1.55): that is the accepted trade of D-21 — the quota-capped resource buys the removal of the relay (56 % of 0.20's cost) and of the Opus layer (23 %).

`/plan-run` projection (secondary): inline execution removes one executor spawn + one verifier spawn per sequential task (~30k harness tokens each measured, D-19); for a typical 8-task plan that is ~10-16 spawns avoided — orchestration overhead roughly −40 %, execution work itself unchanged. Counter-risk (session context growth) is mitigated by the heavy-output delegation rule and re-entrant relaunch.

**To do**: replace this projection with the first measured v0.21 run (`bench-report.sh` from the project folder right after the command).
