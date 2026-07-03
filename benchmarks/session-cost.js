// Real session cost from Claude Code transcripts (~/.claude/projects/**/*.jsonl)
// Usage: node session-cost.js <run dir> <since epoch seconds>
// Prints JSON { cost_usd, fable_tokens, per_model } — exits 1 if no matching session.

// Get modules
const fs   = require('fs')
const os   = require('os')
const path = require('path')

// Get args
const RUN_DIR = process.argv[2]
const SINCE   = parseInt(process.argv[3]||'0', 10) * 1000

// Init rates ($ per Mtok, API mid-2026 — cache write 1.25x input, cache read 0.1x input)
const RATES =
{
	fable:  { in:10, out:50 },
	opus:   { in:5,  out:25 },
	sonnet: { in:3,  out:15 },
	haiku:  { in:1,  out:5 }
}

// Match model family
function family(model){ for(const k of Object.keys(RATES)) if(model.includes(k)) return k; return null }

// Scan transcripts touched since the run started, keep entries whose cwd is the run dir
let seen = {}, usage = {}
const ROOT = path.join(process.env.CLAUDE_CONFIG_DIR||path.join(os.homedir(), '.claude'), 'projects')
for(const dir of fs.existsSync(ROOT) ? fs.readdirSync(ROOT) : [])
{
	const full = path.join(ROOT, dir)
	if(!fs.statSync(full).isDirectory()) continue
	for(const f of fs.readdirSync(full).filter(e => e.endsWith('.jsonl')))
	{
		const file = path.join(full, f)
		if(fs.statSync(file).mtimeMs < SINCE) continue
		for(const line of fs.readFileSync(file, 'utf-8').split('\n'))
		{
			let d; try { d = JSON.parse(line) } catch(e){ continue }
			if(d.cwd != RUN_DIR || !d.message || !d.message.usage || !d.message.model) continue

			// Dedupe streamed duplicates of the same API response
			let id = d.message.id||d.requestId||''
			if(id && seen[id]) continue
			if(id) seen[id] = true

			// Accumulate per model family
			let fam = family(d.message.model); if(!fam) continue
			let u = d.message.usage
			usage[fam] = usage[fam]||{ input:0, output:0, cacheWrite:0, cacheRead:0 }
			usage[fam].input      += u.input_tokens||0
			usage[fam].output     += u.output_tokens||0
			usage[fam].cacheWrite += u.cache_creation_input_tokens||0
			usage[fam].cacheRead  += u.cache_read_input_tokens||0
		}
	}
}

// Prevent silent zero
if(!Object.keys(usage).length){ console.error('no session found for ' + RUN_DIR); process.exit(1) }

// Compute cost
let cost = 0, fable = 0
for(const [fam, u] of Object.entries(usage))
{
	cost += (u.input * RATES[fam].in + u.output * RATES[fam].out + u.cacheWrite * RATES[fam].in * 1.25 + u.cacheRead * RATES[fam].in * 0.1) / 1e6
	if(fam == 'fable') fable = u.input + u.output + u.cacheWrite
}

// Report
console.log(JSON.stringify({ cost_usd:Math.round(cost * 100) / 100, fable_tokens:fable||null, per_model:usage }))
