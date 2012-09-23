define [
	'backbone'
	'databaseconnection'
	'mainview'
	'templates'
], (Backbone, DatabaseConnection, MainView, templates) ->

	class ConnectView extends Backbone.View
		initialize: ->
			if window.ironhide?.params
				@connect window.ironhide.params
			else
				@render()

		render: ->
			@$el.html templates.connectview()

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
			db.connect =>
				new MainView
					el: @$el
					params: params
					socket: db.socket
