#!/usr/bin/env bash
# fablewise-loop — relaunch /plan-run in fresh headless Sonnet sessions until the plan
# reaches one of its legitimate ends: ✅ done, 🔴 blockage (Fable arbitration),
# ⏸ human action awaited (see the plan's "Attendu humain" block), or a no-progress stop.
#
# The plan file on disk is the single source of truth (D-09): every relaunch resumes
# exactly where the previous session stopped. This loop NEVER crosses a blockage —
# it only cures session mortality (a session that dies or ends is relaunched).
#
# Usage:   scripts/fablewise-loop.sh <plan.md> [max_iterations]
# Run it FROM THE PROJECT ROOT (so .mcp.json / project config apply to the sessions).
# Requires: Claude Code CLI (`claude`). Sessions run with --dangerously-skip-permissions.
# Extra CLI flags: FABLEWISE_CLAUDE_ARGS env var (e.g. --allowedTools ...).
#
# Exit codes: 0 plan ✅ terminé · 2 blockage 🔴 (arbitrate with Fable, then relaunch)
#             3 ⏸ human action awaited, or no progress · 4 max iterations reached · 1 usage/error

set -u

PLAN="${1:-}"
MAX_ITER="${2:-20}"

[ -f "$PLAN" ] || { echo "usage: $0 <plan.md> [max_iterations] — plan introuvable : '$PLAN'" >&2; exit 1; }
command -v claude >/dev/null || { echo "Claude Code CLI ('claude') introuvable dans le PATH." >&2; exit 1; }

notify() { # best-effort, opt-in via .claude/fablewise-notify (one URL)
  [ -f .claude/fablewise-notify ] && curl -s -d "fablewise-loop [$(basename "$PLAN")] $1" "$(cat .claude/fablewise-notify)" >/dev/null 2>&1
  return 0
}

status_of() { grep -m1 '\*\*Statut\*\*' "$PLAN" 2>/dev/null || echo ""; }
hash_of()   { shasum "$PLAN" 2>/dev/null | cut -d' ' -f1; }

i=0
while [ "$i" -lt "$MAX_ITER" ]; do
  i=$((i + 1))
  BEFORE=$(hash_of)
  echo "=== fablewise-loop: itération $i/$MAX_ITER — $(date '+%H:%M:%S') ==="

  # shellcheck disable=SC2086
  claude -p "/plan-run $PLAN — run autonome : ne pose aucune question, va aussi loin que le plan le permet." \
    --model sonnet --dangerously-skip-permissions ${FABLEWISE_CLAUDE_ARGS:-}

  STATUS=$(status_of)
  case "$STATUS" in
    *"✅"*) echo "Plan terminé (✅) après $i itération(s)."; notify "terminé ✅ ($i itérations)"; exit 0 ;;
    *"🔴"*) echo "Run interrompu sur BLOCAGE (🔴) — ouvre une session Fable pour arbitrer la Synthèse de blocage, reporte la Directive de reprise, puis relance cette boucle."
            notify "blocage 🔴 — arbitrage Fable requis"; exit 2 ;;
    *"⏸"*) echo "En attente d'action humaine (⏸) — voir le bloc « Attendu humain » du Rapport de run ; fais les gestes listés puis relance cette boucle."
            notify "⏸ action humaine attendue (voir Attendu humain)"; exit 3 ;;
  esac

  if [ "$(hash_of)" = "$BEFORE" ]; then
    echo "Plan inchangé sur cette itération — gate atteint ou aucun progrès possible : ton regard est requis."
    notify "arrêt sur gate / sans progrès — validation utilisateur attendue"; exit 3
  fi
  echo "--- progrès constaté, relance ---"
done

echo "Limite de $MAX_ITER itérations atteinte — vérifier le plan avant de relancer."
notify "limite d'itérations atteinte ($MAX_ITER)"; exit 4
