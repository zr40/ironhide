express = require 'express'
io = require 'socket.io'
pg = require 'pg'

db = new pg.Client 'tcp://zr40@localhost/steamstats'
db.connect()

notices = []

db.on 'notice', (notice) ->
	notices.push notice.message

db.query 'SET timezone=utc'

app = express()
server = app.listen 3000, '127.0.0.1'
io = io.listen server
io.set 'log level', 1

app.use express.static 'web/public'
app.use express.bodyParser()


io.sockets.on 'connection', (socket) ->
	socket.on 'query', (sql, callback) ->

		query = db.query sql, (err, result) ->
			if err
				callback
					error:
						message: err.toString()
						data: err
					notices: notices
				notices = []
			else
				db.query "EXPLAIN (FORMAT JSON) #{sql}", (err, explainResult) ->
					explain = if err then null else JSON.parse explainResult.rows[0]['QUERY PLAN']
					callback
						explain: explain
						rows: result.rows
						notices: notices
					notices = []
