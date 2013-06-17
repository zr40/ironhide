define [
	'backbone'
	'underscore'
	'jquery'
	'hbs!template/resultview'
	'hbs!template/resulterror'
	'Handlebars'
], (Backbone, _, $, template, error_template, Handlebars) ->

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
				@$el.html template
					columns: _.keys @rows[0]
					rows: @rows
					notices: @notices
			else if @error
				@$el.html error_template @error
			else
				@$el.html template
					columns: []
					rows: []
					notices: @notices

		setResult: (result) ->
			@error = result.error
			@notices = result.notices
			@rows = result.rows

			@render()
