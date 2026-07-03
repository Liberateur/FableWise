#!/usr/bin/env bash
# fablewise Stop hook — opt-in anti-premature-stop for /plan-run sessions.
#
# Active ONLY when .claude/fablewise-autorun exists in the project (content: the plan
# path, one line). While the plan is neither ✅ terminé nor 🔴 interrompu, any attempt
# by the session to stop is blocked with an instruction to re-read the plan and continue.
# The session exits legitimately by doing the bookkeeping: terminal state written into
# the plan (✅/🔴) — or, for a gate / user-awaited stop, /plan-run deletes the autorun
# file itself before ending (see SKILL.md). Claude Code's native consecutive-block cap
# bounds worst-case loops.
#
# Enable:  echo "_docs/plans/mon-plan.md" > .claude/fablewise-autorun
# Disable: rm .claude/fablewise-autorun

set -u
INPUT=$(cat 2>/dev/null || true)

FLAG=".claude/fablewise-autorun"
[ -f "$FLAG" ] || exit 0                       # opt-in absent → allow stop

PLAN=$(head -1 "$FLAG" | tr -d '[:space:]')
[ -n "$PLAN" ] && [ -f "$PLAN" ] || exit 0     # no/missing plan → allow stop (misconfig, never trap)

STATUS=$(grep -m1 '\*\*Statut\*\*' "$PLAN" 2>/dev/null || true)
case "$STATUS" in
  *"✅"*|*"🔴"*) exit 0 ;;                      # legitimate end → allow stop
esac

printf '{"decision":"block","reason":"fablewise-autorun actif : le plan %s n'"'"'est pas en état terminal. Relis ENTIÈREMENT le fichier plan puis continue /plan-run (tâches prêtes → exécuter ; délégation des tâches [contexte: lourd]). Si l'"'"'arrêt est légitime (gate atteint, utilisateur attendu), consigne-le dans le plan ET supprime .claude/fablewise-autorun, puis termine."}\n' "$PLAN"
exit 0
