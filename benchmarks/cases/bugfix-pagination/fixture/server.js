// Get modules
const http = require('http')

// Init data
const items = []; for(let i = 1; i <= 57; i++) items.push({ id:i, name:'item-' + i })

// Init server
const server = http.createServer((req, res) =>
{
	const url = new URL(req.url, 'http://' + (req.headers.host||'localhost'))

	// Prevent unknown route
	if(url.pathname != '/items'){ res.writeHead(404, { 'Content-Type':'application/json' }); return res.end(JSON.stringify({ msg:'not found' })) }

	// Get params
	let page  = parseInt(url.searchParams.get('page')||'1', 10)
	let limit = parseInt(url.searchParams.get('limit')||'10', 10)

	// Slice page
	let start = page * limit
	let rows  = items.slice(start, start + limit)

	// Return page
	res.writeHead(200, { 'Content-Type':'application/json' })
	res.end(JSON.stringify({ page:page, limit:limit, total:items.length, total_pages:Math.floor(items.length / limit), items:rows }))
})

// Start
server.listen(process.env.PORT||3000, () => console.log('listening on ' + (process.env.PORT||3000)))
