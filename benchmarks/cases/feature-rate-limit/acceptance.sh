#!/usr/bin/env bash
# Frozen acceptance — feature-rate-limit. Written before any run. Do not edit after publication.
set -u
RUN_DIR="${1:?usage: acceptance.sh <run dir>}"
PORT=4102
PASS=0; TOTAL=5

PORT=$PORT node "$RUN_DIR/server.js" >/dev/null 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null' EXIT
sleep 1

code(){ curl -s --max-time 5 -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT$1"; }
check(){ if [ "$1" = "$2" ]; then PASS=$((PASS+1)); echo "PASS $3"; else echo "FAIL $3 (got: $1, want: $2)"; fi }

# First 5 requests pass
OK=0
for i in 1 2 3 4 5; do [ "$(code /api/status)" = 200 ] && OK=$((OK+1)); done
check "$OK" 5 "first 5 requests in the window get 200"

# 6th is limited
check "$(code /api/status)" 429 "6th request gets 429"

# 429 shape: JSON error + integer Retry-After >= 1
HDRS_BODY=$(curl -s --max-time 5 -D - "http://127.0.0.1:$PORT/api/status")
SHAPE=$(echo "$HDRS_BODY" | node -e '
	let raw = require("fs").readFileSync(0, "utf-8")
	let retry = raw.match(/retry-after:\s*(\d+)/i)
	let body  = raw.slice(raw.indexOf("\r\n\r\n") >= 0 ? raw.indexOf("\r\n\r\n") : raw.indexOf("\n\n"))
	let error = /"error"\s*:\s*"rate_limited"/.test(body)
	console.log(retry && parseInt(retry[1], 10) >= 1 && error ? "ok" : "bad")
' 2>/dev/null || echo ERR)
check "$SHAPE" ok "429 carries Retry-After >= 1 and {\"error\":\"rate_limited\"}"

# Health never limited
check "$(code /health)" 200 "/health stays 200 while the IP is limited"

# Window resets
sleep 11
check "$(code /api/status)" 200 "requests pass again after the window resets"

echo "RESULT $PASS/$TOTAL"
[ "$PASS" = "$TOTAL" ]
