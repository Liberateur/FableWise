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

## Non-negotiable invariants

Cost:
- The orchestrating session is Sonnet — the model guard (Étape 0 of every skill) blocks Fable/Opus sessions and must never be weakened.
- The `fable`-model agents (`plan-architect`, `fable-advisor`) have **no tools**, receive **compressed briefs only**, and output **judgment only** (skeletons, decisions, directives — never code, never long documents). Any change increasing their input or required output needs strong justification.
- Fable is never an executor model; escalations are budgeted.

Quality:
- Verification is independent (verifier ≠ executor), per-criterion, rationale-before-verdict, `UNKNOWN` ≠ pass.
- Frozen acceptance tests are untouchable; anchored edits (quote before modify); user gates before execution and before any deletion.
- The plan file on disk is the single source of truth: re-entrant, updated after every task, fully re-read after any context compaction. No side registries.

## Release discipline

`plugin.json` version == git tag == `CHANGELOG.md` entry, in the same commit. Semver: prompts-only fixes = patch, new behavior = minor, breaking plan-format changes = major. No GitHub releases to maintain — users sync from the marketplace.

## Testing before commit (manual, minimum)

1. Model guard: invoke a command from a Fable or Opus session → must block with the exact alert, zero side effects.
2. `/plan` on a small real request → plan conforms to the template (tags `[touche:]`, per-task binary criteria, Méthode line, pre-mortem section), and ends with the cost table + "new Sonnet session" reminder.
3. Anti-hallucination gate: a planted fake path in a skeleton must be flagged, not silently written.
Roadmap: automate these via skill-creator evals.

## Style

- Skills and agents are currently written in French (English translation is the top roadmap item); README/CONTRIBUTING/CHANGELOG/DECISIONS are English.
- Skill bodies are imperative instructions for Claude, lean, self-contained per file; agent prompts are dense system prompts with hard interdictions spelled out.
- Never put current tuning values in docs where a mechanism is meant to evolve — name the knob and where it lives (plan header, template) instead. Exception: structural constants (loop bounds, default escalation budget) and the documented pricing assumptions in the recap blocks.
