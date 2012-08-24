define [
	'explainview'
	'resultview'
	'databaseview'
	'backbone'
	'jquery'
	'templates'
], (ExplainView, ResultView, DatabaseView, Backbone, $, templates) ->

	class QueryView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			@$el.html templates.queryview()

			sql = @$el.find '.sql'
			execute = @$el.find '.execute'

			explainView = new ExplainView
				el: @$el.find '.explain'
			resultView = new ResultView
				el: @$el.find '.results'
			databaseView = new DatabaseView
				el: @$el.find '.database'

			sql.focus()

			submit = ->
				$.ajax
					type: 'POST'
					url: 'query'
					data:
						sql: sql.val()
					dataType: 'json'
					error: (xhr, errorType, error) ->
						alert "Error: #{errorType}\n\n#{error}"
						console.log error
					success: (result) ->
						# console.log result

						resultView.setResult result
						explainView.setExplain result.explain

			execute.click submit

			sql.on 'keypress', (evt) ->
				if evt.keyCode is 13 and (evt.metaKey or evt.ctrlKey)
					evt.preventDefault()
					submit()