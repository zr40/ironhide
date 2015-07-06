define [
  'cs!queryview'
  'cs!tablesview'
  'cs!jsonexplainview'
  'backbone'
  'hbs!template/mainview'
], (QueryView, TablesView, JsonExplainView, Backbone, template) ->
  class MainView extends Backbone.View
    initialize: ->
      @render()

    render: ->
      @$el.html template()

      toolbar = @$el.find '.navbar'

      toolbar.find('.query').click =>
        toolbar.find('.active').removeClass 'active'
        toolbar.find('.query').addClass 'active'

        new QueryView
          el: @$el.find('.view')
          socket: @options.socket

      toolbar.find('.jsonexplain').click =>
        toolbar.find('.active').removeClass 'active'
        toolbar.find('.jsonexplain').addClass 'active'

        new JsonExplainView
          el: @$el.find('.view')

      toolbar.find('.tables').click =>
        toolbar.find('.active').removeClass 'active'
        toolbar.find('.tables').addClass 'active'

        new TablesView
          el: @$el.find('.view')
          socket: @options.socket

      toolbar.find('.newwindow').click =>
        window.open("/").ironhide =
          params: @options.params

      toolbar.find('.connectedto a').text "#{@options.params.host}:#{@options.params.port}/#{@options.params.database}"

      toolbar.find('.query').click()
