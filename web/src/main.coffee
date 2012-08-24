requirejs.config
	paths:
		backbone: 'lib/backbone'
		underscore: 'lib/underscore'
		jquery: 'lib/jquery'
		handlebars: 'lib/handlebars.runtime'

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

requirejs [
	'queryview'
	'jquery'
], (QueryView, $) ->
	new QueryView
		el: $ 'div'