// Get modules
const test   = require('node:test')
const assert = require('node:assert')
const fs     = require('fs')
const store  = require('./store')

// Clean database
fs.rmSync(__dirname + '/data.json', { force:true })

test('set then get', (t, done) =>
{
	store.set('a', 1, err =>
	{
		assert.ifError(err)
		store.get('a', (err, value) =>
		{
			assert.ifError(err)
			assert.strictEqual(value, 1)
			done()
		})
	})
})

test('get missing key returns null', (t, done) =>
{
	store.get('nope', (err, value) =>
	{
		assert.ifError(err)
		assert.strictEqual(value, null)
		done()
	})
})

test('del removes key', (t, done) =>
{
	store.set('b', 2, err =>
	{
		assert.ifError(err)
		store.del('b', err =>
		{
			assert.ifError(err)
			store.get('b', (err, value) =>
			{
				assert.ifError(err)
				assert.strictEqual(value, null)
				done()
			})
		})
	})
})

test('list returns sorted keys', (t, done) =>
{
	store.set('z', 1, err =>
	{
		assert.ifError(err)
		store.set('a', 2, err =>
		{
			assert.ifError(err)
			store.list((err, keys) =>
			{
				assert.ifError(err)
				assert.deepStrictEqual(keys, ['a', 'z'])
				done()
			})
		})
	})
})
