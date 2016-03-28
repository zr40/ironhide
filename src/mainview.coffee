define [
  'cs!jsonexplainview'
  'backbone'
  'hbs!template/mainview'
], (JsonExplainView, Backbone, template) ->
  class MainView extends Backbone.View
    initialize: ->
      @render()

    render: ->
      @$el.html template()

      new JsonExplainView
        el: @$el.find('.view')
