define [
	'backbone'
	'underscore'
	'jquery'
	'templates'
	'handlebars'
], (Backbone, _, $, templates, Handlebars) ->

	Handlebars.registerHelper 'eachValue', (context, options) ->
		ret = ''

		items = for field of context
			options.fn context[field]
		items.join ''

	class ResultView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			if @rows?.length > 0
				@$el.html templates.resultview
					columns: _.keys @rows[0]
					rows: @rows
					notices: @notices
			else if @error
				@$el.html templates.resulterror @error
			else
				@$el.html templates.resultview
					columns: []
					rows: []
					notices: @notices

		setResult: (result) ->
			@error = result.error
			@notices = result.notices
			@rows = result.rows

			@render()