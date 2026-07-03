#!/usr/bin/env bash
# Frozen acceptance — bugfix-pagination. Written before any run. Do not edit after publication.
set -u
RUN_DIR="${1:?usage: acceptance.sh <run dir>}"
PORT=4101
PASS=0; TOTAL=5

PORT=$PORT node "$RUN_DIR/server.js" >/dev/null 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null' EXIT
sleep 1

get(){ curl -s --max-time 5 "http://127.0.0.1:$PORT/items?$1"; }
field(){ echo "$1" | node -e 'let d;try{d=JSON.parse(require("fs").readFileSync(0,"utf-8"))}catch(e){};console.log(eval("d"+process.argv[1])??"ERR")' "$2" 2>/dev/null; }
check(){ if [ "$1" = "$2" ]; then PASS=$((PASS+1)); echo "PASS $3"; else echo "FAIL $3 (got: $1, want: $2)"; fi }

P1=$(get 'page=1&limit=10')
P2=$(get 'page=2&limit=10')
P6=$(get 'page=6&limit=10')

check "$(field "$P1" '?.items?.[0]?.id')" 1  "page 1 starts at item 1"
check "$(field "$P2" '?.items?.[0]?.id')" 11 "page 2 starts at item 11"

OVERLAP=$(node -e '
	let a = JSON.parse(process.argv[1]).items.map(e => e.id)
	let b = JSON.parse(process.argv[2]).items.map(e => e.id)
	console.log(a.filter(e => b.includes(e)).length)
' "$P1" "$P2" 2>/dev/null || echo ERR)
check "$OVERLAP" 0 "no overlap between page 1 and page 2"

check "$(field "$P1" '?.total_pages')"      6 "total_pages is 6 for 57 items, limit 10"
check "$(field "$P6" '?.items?.length')"    7 "page 6 holds the last 7 items"

echo "RESULT $PASS/$TOTAL"
[ "$PASS" = "$TOTAL" ]
