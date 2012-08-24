express = require 'express'
pg = require 'pg'

db = new pg.Client 'tcp://zr40@localhost/steamstats'
db.connect()

notices = []

db.on 'notice', (notice) ->
	notices.push notice.message

db.query 'SET timezone=utc'

app = express()

app.use express.static 'web/public'
app.use express.bodyParser()

app.post '/query', (req, res) ->
	sql = req.body.sql

	query = db.query sql, (err, result) ->
		if err
			res.send
				error:
					message: err.toString()
					data: err
				notices: notices
			notices = []
		else
			db.query "EXPLAIN (FORMAT JSON) #{sql}", (err, explainResult) ->
				explain = if err then null else JSON.parse explainResult.rows[0]['QUERY PLAN']
				res.send
					explain: explain
					rows: result.rows
					notices: notices
				notices = []


app.listen 3000#, '127.0.0.1'
