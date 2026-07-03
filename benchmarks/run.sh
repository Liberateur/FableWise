#!/usr/bin/env bash
# fablewise benchmark harness — semi-automatic. See benchmarks/README.md for the protocol.
# Usage: ./run.sh <case> <baseline|fablewise>
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CASE="${1:?usage: run.sh <case> <baseline|fablewise>}"
VARIANT="${2:?usage: run.sh <case> <baseline|fablewise>}"
BASELINE_MODEL="${BASELINE_MODEL:-fable}"
ORCH_MODEL="${ORCH_MODEL:-sonnet}"

CASE_DIR="$DIR/cases/$CASE"
[ -d "$CASE_DIR" ] || { echo "unknown case: $CASE (available: $(ls "$DIR/cases" | tr '\n' ' '))"; exit 1; }
[ "$VARIANT" = baseline ] || [ "$VARIANT" = fablewise ] || { echo "variant must be baseline or fablewise"; exit 1; }

STAMP="$(date +%Y%m%d-%H%M%S)"
RUN_DIR="$DIR/runs/$STAMP-$CASE-$VARIANT"
mkdir -p "$DIR/runs" "$DIR/results"
cp -r "$CASE_DIR/fixture" "$RUN_DIR"

REQUEST="$(cat "$CASE_DIR/request.md")"
COST="null"
FABLE_TOKENS="null"
NOTES=""
START=$(date +%s)

if [ "$VARIANT" = baseline ]; then
	echo "── baseline: $BASELINE_MODEL, headless, $RUN_DIR ──"
	(cd "$RUN_DIR" && claude -p "$REQUEST" --model "$BASELINE_MODEL" \
		--output-format json --dangerously-skip-permissions \
		> claude-result.json) || NOTES="claude exited non-zero; "
	END=$(date +%s)
else
	echo "── fablewise: interactive, gates approved by you ──"
	echo ""
	echo "In ANOTHER terminal:"
	echo "  1. cd $RUN_DIR"
	echo "  2. claude --model $ORCH_MODEL"
	echo "  3. /plan <paste the content of $CASE_DIR/request.md, verbatim>"
	echo "  4. answer the framing questions, validate the plan"
	echo "  5. exit, open a FRESH session (claude --model $ORCH_MODEL), /plan-run <plan file>"
	echo "  6. when the run completes, exit and come back here"
	echo ""
	read -rp "Press Enter when the fablewise run is finished... "
	END=$(date +%s)
fi

# Real usage from the session transcripts — same accounting for both variants
METRICS=$(node "$DIR/session-cost.js" "$RUN_DIR" "$START" 2>/dev/null || true)
if [ -n "$METRICS" ]; then
	echo "$METRICS" > "$RUN_DIR/session-cost.json"
	COST=$(node -pe 'JSON.parse(process.argv[1]).cost_usd ?? "null"' "$METRICS")
	FABLE_TOKENS=$(node -pe 'JSON.parse(process.argv[1]).fable_tokens ?? "null"' "$METRICS")
	echo "session transcripts: \$$COST · fable tokens: $FABLE_TOKENS (breakdown in $RUN_DIR/session-cost.json)"
fi

# Fallback (baseline): billed cost reported by the CLI
if [ "$COST" = "null" ] && [ "$VARIANT" = baseline ] && [ -s "$RUN_DIR/claude-result.json" ]; then
	M=$(node -e '
		let d = JSON.parse(require("fs").readFileSync(process.argv[1], "utf-8"))
		let fable = 0
		for(const [k, v] of Object.entries(d.modelUsage||{})) if(/fable/i.test(k)) fable += (v.inputTokens||0) + (v.outputTokens||0) + (v.cacheCreationInputTokens||0)
		console.log((d.total_cost_usd ?? "null") + " " + (fable||"null"))
	' "$RUN_DIR/claude-result.json") || M="null null"
	COST="${M%% *}"
	FABLE_TOKENS="${M##* }"
	NOTES="${NOTES}cost from CLI json (transcripts not found); "
fi

# Fallback (fablewise): plugin estimate from the plan file, then manual prompts
if [ "$COST" = "null" ] && [ "$VARIANT" = fablewise ]; then
	PLAN_FILE=$(ls -t "$RUN_DIR"/plans/*.md 2>/dev/null | head -1 || true)
	if [ -n "$PLAN_FILE" ]; then
		COST=$(grep -oE 'total \$[0-9]+([.,][0-9]+)?' "$PLAN_FILE" | tail -1 | grep -oE '[0-9]+([.,][0-9]+)?' | tr ',' '.' || true)
	fi
	if [ -z "${COST:-}" ] || [ "$COST" = "null" ]; then
		read -rp "Total cost \$ from the recap table (e.g. 1.85): " COST
	fi
	read -rp "Fable tokens from the recap (plain number, e.g. 9000; empty = n/d): " FABLE_TOKENS
	[ -z "$FABLE_TOKENS" ] && FABLE_TOKENS="null"
	NOTES="${NOTES}cost from plugin estimate/manual (transcripts not found); "
fi

[ "$VARIANT" = fablewise ] && read -rp "Notes (optional): " EXTRA && NOTES="$NOTES$EXTRA"

echo ""
echo "── frozen acceptance ──"
ACC_LOG="$RUN_DIR/acceptance.log"
bash "$CASE_DIR/acceptance.sh" "$RUN_DIR" | tee "$ACC_LOG" || true
RESULT_LINE=$(tail -1 "$ACC_LOG")
PASSED="${RESULT_LINE#RESULT }"; TOTAL="${PASSED#*/}"; PASSED="${PASSED%%/*}"

RESULT_FILE="$DIR/results/$CASE-$VARIANT.json"
cat > "$RESULT_FILE" <<EOF
{
	"case": "$CASE",
	"variant": "$VARIANT",
	"date": "$(date +%Y-%m-%d)",
	"cost_usd": ${COST:-null},
	"fable_tokens": ${FABLE_TOKENS:-null},
	"duration_s": $((END - START)),
	"tests_passed": ${PASSED:-0},
	"tests_total": ${TOTAL:-0},
	"notes": "$NOTES"
}
EOF

echo ""
echo "── done: $RESULT_LINE · \$${COST} · $((END - START))s → $RESULT_FILE ──"
echo "Regenerate the README table with: node $DIR/gen-table.js"
