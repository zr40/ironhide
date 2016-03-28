define [
  'cs!explainview'
  'backbone'
  'jquery'
  'hbs!template/queryview'
], (ExplainView, Backbone, $, template) ->

  class JsonExplainView extends Backbone.View
    initialize: ->
      @render()

    render: ->
      @$el.html template()

      sql = @$el.find '.sql textarea'
      codeMirror = CodeMirror.fromTextArea sql[0], {
        mode: 'application/json'
        tabSize: 2
        lineNumbers: yes
        indentWithTabs: yes
      }

      codeMirror.addKeyMap
      executeButton = @$el.find '.execute'

      explainView = new ExplainView
        el: @$el.find '.explain'

      sql.focus()

      doRender = ->
        try
          value = JSON.parse codeMirror.getValue()
          value = [value] unless value instanceof Array
          explainView.setExplain value
        catch error
          explainView.setExplain undefined, error

      codeMirror.addKeyMap {
        'Cmd-Enter': doRender,
        'Ctrl-Enter': doRender,
      }

      executeButton.click doRender

      sql.on 'keypress', (evt) ->
        if evt.keyCode is 13 and (evt.metaKey or evt.ctrlKey)
          evt.preventDefault()
          doRender()
