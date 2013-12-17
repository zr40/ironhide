define [
	'cs!resultview'
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
				    relid::regclass "table",
				    pg_stat_user_tables.n_live_tup "rows",
				    pg_size_pretty(pg_relation_size(relid)) "data",
				    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) "index"

				from pg_catalog.pg_stat_user_tables

				order by relid::regclass
			'''
			@options.socket.emit 'query', sql, (result) =>
				@result.setResult result
