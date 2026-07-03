// Get modules
const fs = require('fs')

// Init paths
const DIR     = __dirname
const RESULTS = DIR + '/results'
const README  = DIR + '/../README.md'

// Get results
let entries = {}
for(const f of fs.readdirSync(RESULTS).filter(e => e.endsWith('.json')))
{
	let r = JSON.parse(fs.readFileSync(RESULTS + '/' + f, 'utf-8'))
	entries[r.case] = entries[r.case]||{}
	entries[r.case][r.variant] = r
}

// Format helpers
function money(n){ return typeof n == 'number' ? '$' + n.toFixed(2) : 'n/d' }
function tokens(n){ return typeof n == 'number' ? Math.round(n / 1000) + 'k' : 'n/d' }
function mins(s){ return typeof s == 'number' ? Math.round(s / 60) + ' min' : 'n/d' }

// Build rows
let rows = []
for(const name of Object.keys(entries).sort())
{
	let b = entries[name].baseline, w = entries[name].fablewise
	if(!b || !w) continue

	// Compute savings
	let delta = (typeof b.cost_usd == 'number' && typeof w.cost_usd == 'number' && b.cost_usd > 0) ? Math.round((1 - w.cost_usd / b.cost_usd) * 100) : null
	let cost  = money(b.cost_usd) + ' → ' + money(w.cost_usd) + (delta === null ? '' : ' (' + (delta >= 0 ? '**−' + delta : '**+' + -delta) + ' %**)')

	rows.push('| ' + name + ' | ' + cost + ' | ' + b.tests_passed + '/' + b.tests_total + ' → **' + w.tests_passed + '/' + w.tests_total + '** | ' + tokens(b.fable_tokens) + ' → ' + tokens(w.fable_tokens) + ' | ' + mins(b.duration_s) + ' → ' + mins(w.duration_s) + ' |')
}

// Prevent empty campaign
if(!rows.length){ console.log('no complete case (need baseline + fablewise results) — nothing to inject'); process.exit(0) }

// Build table
const table =
[
	'| Case | Cost | Frozen tests passed | Fable tokens | Wall time |',
	'|---|---|---|---|---|',
	...rows
].join('\n')

// Inject between markers
let readme = fs.readFileSync(README, 'utf-8')
let updated = readme.replace(/(<!-- fablewise-bench:start -->)[\s\S]*?(<!-- fablewise-bench:end -->)/, (m, a, b) => a + '\n' + table + '\n' + b)
if(updated == readme){ console.log('markers not found in README.md — nothing injected'); process.exit(1) }

// Save
fs.writeFileSync(README, updated)
console.log('README table updated (' + rows.length + ' case(s))')
