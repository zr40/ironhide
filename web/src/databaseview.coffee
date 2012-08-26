define [
	'resultview'
	'backbone'
], (ResultView, Backbone) ->
	class DatabaseView extends Backbone.View
		initialize: ->
			@render()

			window.setInterval @refresh, 15000

			@refresh()

		render: ->
			@result = new ResultView
				el: @$el

		refresh: =>
			sql = '''
				ANALYZE;
				SELECT
				tables.table_schema || '.' || tables.table_name AS "table",
				pg_stat_user_tables.n_live_tup AS rows,
				pg_size_pretty(pg_relation_size(tables.table_schema || '.' || tables.table_name)) AS data,
				pg_size_pretty(pg_total_relation_size(tables.table_schema || '.' || tables.table_name) - pg_relation_size(tables.table_schema || '.' || tables.table_name)) AS "index"

				FROM information_schema.tables
				INNER JOIN pg_catalog.pg_stat_user_tables ON pg_stat_user_tables.schemaname = tables.table_schema AND pg_stat_user_tables.relname = tables.table_name

				WHERE tables.table_schema NOT IN ('pg_catalog', 'information_schema')
				ORDER BY "table"
			'''
			@options.socket.emit 'query', sql, (result) =>
				@result.setResult result
