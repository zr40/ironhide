define [
	'queryview'
	'backbone'
	'templates'
], (QueryView, Backbone, templates) ->
	class MainView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			@$el.html templates.mainview()

			toolbar = @$el.find '.navbar'
			toolbar.find('.newwindow').click =>
				window.open("/").ironhide =
					params: @options.params

			toolbar.find('.connectedto a').text "#{@options.params.host}/#{@options.params.database}"

			new QueryView
				el: @$el.find('.view')
				socket: @options.socket
