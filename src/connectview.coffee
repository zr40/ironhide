define [
  'backbone'
  'cs!databaseconnection'
  'cs!mainview'
  'hbs!template/connectview'
], (Backbone, DatabaseConnection, MainView, template) ->

  class ConnectView extends Backbone.View
    initialize: ->
      @render()

      if window.ironhide?.params
        @connect window.ironhide.params
        delete window.ironhide

    render: ->
      @$el.html template(window.ironhide?.params || {})

      @$el.find('form').submit (e) =>
        e.preventDefault()

        @connect
          host: @$el.find('#host').val()
          port: @$el.find('#port').val()
          database: @$el.find('#db').val()
          user: @$el.find('#user').val()
          password: @$el.find('#pass').val()

    connect: (params) ->
      db = new DatabaseConnection params
      db.connect (err) =>
        if err
          db.socket.disconnect()
          alert err.message
        else
          new MainView
            el: @$el
            params: params
            socket: db.socket
