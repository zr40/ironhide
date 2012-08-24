requirejs.config
	paths:
		backbone: 'lib/backbone'
		underscore: 'lib/underscore'
		jquery: 'lib/jquery'
		handlebars: 'lib/handlebars.runtime'
		'socket.io': 'socket.io/socket.io'

	shim:
		backbone:
			deps: ['underscore', 'jquery']
			exports: 'Backbone'
		handlebars:
			exports: 'Handlebars'
		templates:
			deps: ['handlebars']
			exports: 'Handlebars.templates'
		underscore:
			exports: '_'
		'socket.io':
			exports: 'io'

requirejs [
	'queryview'
	'jquery'
	'socket.io'
], (QueryView, $, io) ->

	# temporary HACK
	window.socket = io.connect()

	new QueryView
		el: $ 'div'
