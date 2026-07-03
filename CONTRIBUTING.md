# Contributing to fablewise

Thanks for wanting to improve fablewise! It's a prompt-architecture plugin: the "code" is markdown (skills, agents, template), so contributions are readable diffs — but discipline matters more than in code, because nothing is compiled and drift is silent.

## Reporting an issue

Include:

1. The command used and the model of your session.
2. The **cost recap table** the command printed (it's the built-in telemetry).
3. What you expected vs. what happened — if a session or agent misbehaved (executor improvised instead of stopping, blockage synthesized poorly, Fable session read raw files itself), quote the relevant output.
4. Your surface: Claude Code (version) or Cowork.

## Proposing a change (PR)

- **The four-layer rule** — any pipeline change must propagate to every layer it touches: `skills/*/SKILL.md` (the workflows), `agents/*.md` (the system prompts), `skills/plan/references/plan-template.md` (the artifact format), `README.md`. Most historical bugs in this project were desynchronizations between these layers.
- **Cost first**: the steering metric is **absolute Fable tokens** (see D-21). Any change that puts volume into the Fable design session (raw file reads, inline web, MCP dumps, screenshots) or weakens the delegation/synthesis boundary needs a strong justification. Subagent tool-call budgets (D-18) are part of the contract too.
- **Quality gates are not negotiable**: evidence-based criteria checks, frozen tests, anchored edits, stop-and-synthesize on blockage, user gates before execution/deletion. PRs weakening them for speed will be declined — see README "Why this shape".
- Keep skills self-contained (each SKILL.md must work alone), imperative, and lean.
- Update `CHANGELOG.md` and bump `plugin.json` version (semver). Version, git tag and changelog entry must match.

## Testing

Cost measurement harness: `benchmarks/` (baseline-vs-fablewise protocol, `bench-report.sh` prices sessions cache-inclusive from transcripts). No behavioral eval suite yet (top roadmap item, via skill-creator evals). Minimum manual checks for a PR: the guards block both wrong directions (`/plan` from Sonnet, `/plan-run` from Fable/Opus); `/plan` from a Fable session on a small real request produces a template-conformant plan with `[touche:]` tags, per-task criteria and the Contrat d'exécution, without the session reading project files itself; the anti-hallucination gate catches a planted fake path; a task with an unfindable anchor stops the run with a `Synthèse de blocage`.

## Roadmap (help wanted)

- English translation of the skills (highest impact).
- Eval suite via skill-creator (non-regression per model update).
- Hardened model guard via Claude Code hooks.
