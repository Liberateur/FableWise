# Benchmarks

Cost/latency measurement harness for fablewise. Protocol: run the **same request, cold** (no prior plans read, fresh sessions) through each variant, then price every session **cache-inclusive from its transcript** with `bench-report.sh`. Volumetric recaps (`subagent_tokens`) are never used as cost figures — measured runs show real cost at up to 4.7× the non-cache volumetry (see D-12).

- `bench-report.sh` — prices the most recent session transcript (main `.jsonl` + `subagents/`) at API rates. Rates are validated against measured sessions in `results/`.
- `results/` — versioned measurement reports (they back the README and DECISIONS figures).
- `runs/` — local working copies, gitignored.

## Measured results

| Date | Variant | Cost | API time | Wall | Fable line | Report |
|---|---|---|---|---|---|---|
| 2026-07-03 | /plan v0.20 (full pipeline) | **$7.13** | 25m19 | 36m55 | $1.04 | [results/2026-07-03-conception.md](results/2026-07-03-conception.md) |
| 2026-07-03 | Direct Fable, no tools (floor) | **$0.77** | 1m32 | 91 s to plan | $0.77 | idem |
| — | /plan v0.21 (projected, same request) | **~$3.2** | — | ~10-13 min | ~$1.5 | idem (projection method) |

The v0.21 projection is **not a measurement** — it is derived from the measured component costs (explorer, web agents, evidence/gate) plus a modeled Fable session (direct-run baseline + delegated-synthesis ingestion + multi-turn cache + plan writing). First real v0.21 run should be added here and the projection retired.
