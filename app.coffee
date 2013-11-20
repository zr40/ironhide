express = require 'express'
io = require 'socket.io'
pg = require 'pg'

#notices = []

#db.on 'notice', (notice) ->
#	notices.push notice.message

app = express()
server = app.listen 3000, '127.0.0.1'
io = io.listen server
io.set 'log level', 1

app.use express.static 'src'
app.use express.bodyParser()


io.sockets.on 'connection', (socket) ->
	socket.on 'connect', (params, callback) ->
		db = new pg.Client params
		db.on 'error', (err) ->
			callback
				message: err.toString()
				data: err
		db.on 'connect', ->
			db.query 'SET timezone=utc'

			socket.db = db
			callback()

		db.connect()

	socket.on 'disconnect', ->
		socket.db?.end()

	socket.on 'query', (sql, callback) ->
		db = socket.db

		start = process.hrtime()
		query = db.query sql, (err, result) ->
			duration = process.hrtime(start)
			if err
				callback
					error:
						message: err.toString()
						data: err
						duration: duration[0] + (duration[1] / 1000000000)
					notices: notices
				notices = []
			else
				db.query "explain (format json, verbose true) #{sql}", (err, explainResult) ->
					explain = if err then null else JSON.parse explainResult.rows[0]['QUERY PLAN']
					callback
						explain: explain
						rows: result.rows
						notices: notices
						duration: duration[0] + (duration[1] / 1000000000)
					notices = []

	socket.on 'explainOnly', (sql, callback) ->
		db = socket.db

		query = db.query "explain (format json, verbose true) #{sql}", (err, explainResult) ->
			if err
				callback
					error:
						message: err.toString()
						data: err
						duration: 0
					notices: notices
				notices = []
			else
				explain = JSON.parse explainResult.rows[0]['QUERY PLAN']
				callback
					explain: explain
					rows: []
					notices: notices
					duration: 0
				notices = []
