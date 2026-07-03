# Contributing to fablewise

Thanks for wanting to improve fablewise! It's a prompt-architecture plugin: the "code" is markdown (skills, agents, template), so contributions are readable diffs — but discipline matters more than in code, because nothing is compiled and drift is silent.

## Reporting an issue

Include:

1. The command used and the model of your session.
2. The **cost recap table** the command printed (it's the built-in telemetry).
3. What you expected vs. what happened — if an agent misbehaved (executor improvised, verifier rubber-stamped, architect wrote prose), quote the relevant output.
4. Your surface: Claude Code (version) or Cowork.

## Proposing a change (PR)

- **The four-layer rule** — any pipeline change must propagate to every layer it touches: `skills/*/SKILL.md` (the workflows), `agents/*.md` (the system prompts), `skills/plan/references/plan-template.md` (the artifact format), `README.md`. Most historical bugs in this project were desynchronizations between these layers.
- **Cost first**: fablewise exists to spend premium tokens only on judgment. Any change that sends more raw content to the `fable`-model agents, gives them tools, or lengthens their required output needs a strong justification.
- **Quality gates are not negotiable**: independent verification, frozen tests, anchored edits, user gates before execution/deletion. PRs weakening them for speed will be declined — see README "Why quality goes up".
- Keep skills self-contained (each SKILL.md must work alone), imperative, and lean.
- Update `CHANGELOG.md` and bump `plugin.json` version (semver). Version, git tag and changelog entry must match.

## Testing

No automated harness yet (top roadmap item, via skill-creator evals). Minimum manual checks for a PR: the model guard blocks from a Fable/Opus session; `/plan` on a small real request produces a template-conformant plan with `[touche:]` tags and per-task criteria; the anti-hallucination gate catches a planted fake path.

## Roadmap (help wanted)

- English translation of the skills (highest impact).
- Eval suite via skill-creator (non-regression per model update).
- Hardened model guard via Claude Code hooks.
