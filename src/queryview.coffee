define [
	'cs!explainview'
	'cs!resultview'
	'cs!databaseview'
	'backbone'
	'jquery'
	'hbs!template/queryview'
], (ExplainView, ResultView, DatabaseView, Backbone, $, template) ->

	class QueryView extends Backbone.View
		initialize: ->
			@render()

		render: ->
			@$el.html template()

			sql = @$el.find '.sql textarea'
			codeMirror = CodeMirror.fromTextArea sql[0], {
				mode: 'text/x-plsql'
				tabSize: 2
				lineNumbers: yes
				indentWithTabs: yes
			}

			codeMirror.addKeyMap
			executeButton = @$el.find '.execute'
			planButton = @$el.find '.plan'

			explainView = new ExplainView
				el: @$el.find '.explain'
			resultView = new ResultView
				el: @$el.find '.results'
			databaseView = new DatabaseView
				el: @$el.find '.database'
				socket: @options.socket

			sql.focus()

			execute = =>
				@options.socket.emit 'query', codeMirror.getValue(), (result) ->
					resultView.setResult result
					explainView.setExplain result.explain, result.duration

			plan = =>
				@options.socket.emit 'explainOnly', codeMirror.getValue(), (result) ->
					resultView.setResult result
					explainView.setExplain result.explain, result.duration

			codeMirror.addKeyMap {
				'Cmd-Enter': plan,
				'Ctrl-Enter': plan,
			}

			executeButton.click execute
			planButton.click plan

			sql.on 'keypress', (evt) ->
				if evt.keyCode is 13 and (evt.metaKey or evt.ctrlKey)
					evt.preventDefault()
					plan()
