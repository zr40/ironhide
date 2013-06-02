define [
	'explainview'
	'resultview'
	'databaseview'
	'backbone'
	'jquery'
	'templates'
], (ExplainView, ResultView, DatabaseView, Backbone, $, templates) ->

	class QueryView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			@$el.html templates.queryview()

			sql = @$el.find '.sql textarea'
			codeMirror = CodeMirror.fromTextArea sql[0], {
				mode: 'text/x-plsql'
				tabSize: 2
				lineNumbers: yes
				indentWithTabs: yes
			}



			codeMirror.addKeyMap
			execute = @$el.find '.execute'

			explainView = new ExplainView
				el: @$el.find '.explain'
			resultView = new ResultView
				el: @$el.find '.results'
			databaseView = new DatabaseView
				el: @$el.find '.database'
				socket: @options.socket

			sql.focus()

			submit = =>
				@options.socket.emit 'query', codeMirror.getValue(), (result) ->
					resultView.setResult result
					explainView.setExplain result.explain, result.duration

			codeMirror.addKeyMap {
				'Cmd-Enter': submit,
				'Ctrl-Enter': submit,
			}

			execute.click submit

			sql.on 'keypress', (evt) ->
				if evt.keyCode is 13 and (evt.metaKey or evt.ctrlKey)
					evt.preventDefault()
					submit()
