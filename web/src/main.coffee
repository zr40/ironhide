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
	'connectview'
	'jquery'
], (ConnectView, $) ->

	new ConnectView
		el: $ 'div'
