define [
	'socket.io'
], (io) ->
	class DatabaseConnection
		constructor: (@settings) ->

		connect: (callback) ->
			@socket = io.connect()
			@socket.emit 'connect', @settings, callback
