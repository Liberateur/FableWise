#!/usr/bin/env bash
# Frozen acceptance — refactor-callbacks. Written before any run. Do not edit after publication.
set -u
RUN_DIR="${1:?usage: acceptance.sh <run dir>}"
CASE_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0; TOTAL=4

check(){ if [ "$1" = "$2" ]; then PASS=$((PASS+1)); echo "PASS $3"; else echo "FAIL $3 (got: $1, want: $2)"; fi }

# Test file untouched (frozen tests, D-10)
if cmp -s "$RUN_DIR/store.test.js" "$CASE_DIR/frozen-store.test.js"; then UNTOUCHED=yes; else UNTOUCHED=no; fi
check "$UNTOUCHED" yes "store.test.js is byte-identical to the frozen copy"

# Original callback tests still pass
rm -f "$RUN_DIR/data.json"
if (cd "$RUN_DIR" && node --test >/dev/null 2>&1); then TESTS=pass; else TESTS=fail; fi
check "$TESTS" pass "original callback test suite passes unchanged"

# Promise API roundtrip
rm -f "$RUN_DIR/data.json"
RT=$(cd "$RUN_DIR" && node -e '
	const store = require("./store")
	;(async () =>
	{
		await store.promises.set("k", 42)
		let v = await store.promises.get("k")
		let missing = await store.promises.get("nope")
		console.log(v === 42 && missing === null ? "ok" : "bad")
	})().catch(() => console.log("ERR"))
' 2>/dev/null || echo ERR)
check "$RT" ok "promises.set / promises.get roundtrip, missing key gives null"

# Promise del + sorted list
rm -f "$RUN_DIR/data.json"
DL=$(cd "$RUN_DIR" && node -e '
	const store = require("./store")
	;(async () =>
	{
		await store.promises.set("z", 1)
		await store.promises.set("a", 2)
		await store.promises.set("m", 3)
		await store.promises.del("m")
		let keys = await store.promises.list()
		console.log(JSON.stringify(keys) === JSON.stringify(["a", "z"]) ? "ok" : "bad")
	})().catch(() => console.log("ERR"))
' 2>/dev/null || echo ERR)
check "$DL" ok "promises.del works and promises.list returns sorted keys"

echo "RESULT $PASS/$TOTAL"
[ "$PASS" = "$TOTAL" ]
