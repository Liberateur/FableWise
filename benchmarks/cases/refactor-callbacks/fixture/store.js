// Get modules
const fs = require('fs')

// Init file
const FILE = __dirname + '/data.json'

// Load database
function load(callback)
{
	fs.readFile(FILE, 'utf-8', function(err, raw)
	{
		if(err) return callback(null, {})
		try { callback(null, JSON.parse(raw)) }
		catch(e){ callback(null, {}) }
	})
}

// Save database
function save(data, callback)
{
	fs.writeFile(FILE, JSON.stringify(data), function(err)
	{
		if(err) return callback(err)
		callback(null)
	})
}

// Export
module.exports =
{
	get(key, callback)
	{
		load(function(err, data)
		{
			if(err) return callback(err)
			callback(null, data[key] === undefined ? null : data[key])
		})
	},

	set(key, value, callback)
	{
		load(function(err, data)
		{
			if(err) return callback(err)
			data[key] = value
			save(data, function(err)
			{
				if(err) return callback(err)
				callback(null)
			})
		})
	},

	del(key, callback)
	{
		load(function(err, data)
		{
			if(err) return callback(err)
			delete data[key]
			save(data, function(err)
			{
				if(err) return callback(err)
				callback(null)
			})
		})
	},

	list(callback)
	{
		load(function(err, data)
		{
			if(err) return callback(err)
			callback(null, Object.keys(data).sort())
		})
	}
}
