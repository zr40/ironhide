define [
	'socket.io'
], (io) ->
	class DatabaseConnection
		constructor: (@settings) ->

		connect: (callback) ->
			@socket = io.connect undefined,
				'reconnect': false
			@socket.emit 'connect', @settings, callback
