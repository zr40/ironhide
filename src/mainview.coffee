define [
	'cs!queryview'
	'cs!tablesview'
	'backbone'
	'hbs!template/mainview'
], (QueryView, TablesView, Backbone, template) ->
	class MainView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			@$el.html template()

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

			toolbar.find('.connectedto a').text "#{@options.params.host}:#{@options.params.port}/#{@options.params.database}"

			toolbar.find('.query').click()
