// Get modules
const http = require('http')

// Init server
const server = http.createServer((req, res) =>
{
	const url = new URL(req.url, 'http://' + (req.headers.host||'localhost'))

	// Health
	if(url.pathname == '/health'){ res.writeHead(200, { 'Content-Type':'application/json' }); return res.end(JSON.stringify({ ok:true })) }

	// Api status
	if(url.pathname == '/api/status'){ res.writeHead(200, { 'Content-Type':'application/json' }); return res.end(JSON.stringify({ status:'up', time:+new Date() })) }

	// Api echo
	if(url.pathname == '/api/echo' && req.method == 'POST')
	{
		let body = ''
		req.on('data', e => body += e)
		req.on('end', () =>
		{
			res.writeHead(200, { 'Content-Type':'application/json' })
			res.end(JSON.stringify({ echo:body }))
		})
		return
	}

	// Not found
	res.writeHead(404, { 'Content-Type':'application/json' })
	res.end(JSON.stringify({ msg:'not found' }))
})

// Start
server.listen(process.env.PORT||3000, () => console.log('listening on ' + (process.env.PORT||3000)))
