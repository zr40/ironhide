define [
	'cs!explainview'
	'backbone'
	'jquery'
	'hbs!template/queryview'
], (ExplainView, Backbone, $, template) ->

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

			sql.focus()

			execute = =>
				@options.socket.emit 'query', codeMirror.getValue(), (result) ->
					explainView.setExplain result.explain, result.duration, result.error

			plan = =>
				@options.socket.emit 'explainOnly', codeMirror.getValue(), (result) ->
					explainView.setExplain result.explain, result.duration, result.error

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
