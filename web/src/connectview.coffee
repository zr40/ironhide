define [
	'backbone'
	'databaseconnection'
	'queryview'
	'templates'
], (Backbone, DatabaseConnection, QueryView, templates) ->

	class ConnectView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			@$el.html templates.connectview()

			@$el.find('form').submit (e) =>
				e.preventDefault()

				connection = new DatabaseConnection
					host: @$el.find('#host').val()
					port: @$el.find('#port').val()
					database: @$el.find('#db').val()
					user: @$el.find('#user').val()
					password: @$el.find('#pass').val()

				connection.connect =>
					new QueryView
						el: @$el
						connection: connection
						socket: connection.socket
