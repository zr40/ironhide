define [
	'backbone'
	'databaseconnection'
	'mainview'
	'templates'
], (Backbone, DatabaseConnection, MainView, templates) ->

	class ConnectView extends Backbone.View
		initialize: ->
			@render()

			if window.ironhide?.params
				@connect window.ironhide.params

		render: ->
			@$el.html templates.connectview(window.ironhide?.params || {})

			@$el.find('form').submit (e) =>
				e.preventDefault()

				@connect
					host: @$el.find('#host').val()
					port: @$el.find('#port').val()
					database: @$el.find('#db').val()
					user: @$el.find('#user').val()
					password: @$el.find('#pass').val()

		connect: (params) ->
			db = new DatabaseConnection params
			db.connect (err) =>
				if err
					db.socket.disconnect()
					alert err.message
				else
					new MainView
						el: @$el
						params: params
						socket: db.socket
