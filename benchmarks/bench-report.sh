#!/usr/bin/env bash
# bench-report.sh — price the most recent Claude Code session (cache-inclusive, API rates).
# Usage: run from the project folder whose session you want to price. Requires jq.
# Rates ($/MTok in): fable 10, opus 5, sonnet 3, haiku 1 · out = 5× in · cache write = 1.25× in · cache read = 0.10× in.
# Validated against measured sessions of 2026-07-03 (per-model error ≤ +16%, see results/).
set -euo pipefail
D=~/.claude/projects/$(pwd | tr '/' '-')
S=$(ls -t "$D"/*.jsonl 2>/dev/null | head -1)
[ -n "${S:-}" ] || { echo "no transcript found under $D"; exit 1; }
cat "$S" "${S%.jsonl}/subagents/"*.jsonl 2>/dev/null | jq -r '
  select(.type=="assistant" and .message.usage!=null) |
  [.message.model,
   .message.usage.input_tokens//0,
   .message.usage.cache_creation_input_tokens//0,
   .message.usage.cache_read_input_tokens//0,
   .message.usage.output_tokens//0] | @tsv' |
awk -F'\t' '{i[$1]+=$2;cw[$1]+=$3;cr[$1]+=$4;o[$1]+=$5}
END{split("fable:10 opus:5 sonnet:3 haiku:1",T," ");
for(m in i){r=3; for(t in T){split(T[t],p,":"); if(index(m,p[1]))r=p[2]};
c=(i[m]*r+cw[m]*r*1.25+cr[m]*r*0.10+o[m]*r*5)/1e6;
printf "%-22s in %8d  cw %8d  cr %9d  out %7d   $%.2f\n",m,i[m],cw[m],cr[m],o[m],c; tot+=c}
printf "%-22s %s $%.2f\n","TOTAL","",tot}'
