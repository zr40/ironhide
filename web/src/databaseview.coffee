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

			# TODO: replace regexp with case

			sql = '''
				select
				regexp_replace(tables.table_schema || '.' || tables.table_name, '^public\\.', '') "table",
				pg_stat_user_tables.n_live_tup "rows",
				pg_size_pretty(pg_relation_size(tables.table_schema || '.' || tables.table_name)) "data",
				pg_size_pretty(pg_total_relation_size(tables.table_schema || '.' || tables.table_name) - pg_relation_size(tables.table_schema || '.' || tables.table_name)) "index"

				from information_schema.tables
				inner join pg_catalog.pg_stat_user_tables on pg_stat_user_tables.schemaname = tables.table_schema and pg_stat_user_tables.relname = tables.table_name

				where tables.table_schema not in ('pg_catalog', 'information_schema')
				order by "table"
			'''
			@options.socket.emit 'query', sql, (result) =>
				@result.setResult result
