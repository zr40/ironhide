define [
	'queryview'
	'tablesview'
	'backbone'
	'templates'
], (QueryView, TablesView, Backbone, templates) ->
	class MainView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			@$el.html templates.mainview()

			toolbar = @$el.find '.navbar'

			toolbar.find('.query').click =>
				toolbar.find('.active').removeClass 'active'
				toolbar.find('.query').addClass 'active'

				new QueryView
					el: @$el.find('.view')
					socket: @options.socket

			toolbar.find('.tables').click =>
				toolbar.find('.active').removeClass 'active'
				toolbar.find('.tables').addClass 'active'

				new TablesView
					el: @$el.find('.view')
					socket: @options.socket

			toolbar.find('.newwindow').click =>
				window.open("/").ironhide =
					params: @options.params

			toolbar.find('.connectedto a').text "#{@options.params.host}/#{@options.params.database}"

			toolbar.find('.query').click()
