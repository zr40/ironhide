define [
  'backbone'
  'jquery'
  'hbs!template/resulterror'
], (Backbone, $, error_template) ->
  class ExplainView extends Backbone.View
    initialize: ->
      @render

    truncate_array = (arr) ->
      return arr.join ', ' if arr.length <= 5
      first = arr.slice(0, 5)
      first.push '…'
      first.join ', '

    truncate = (str) ->
      return str unless str

      if str.length > 32
        return str[...31] + '…'
      str

    render: ->
      if @error
        @$el.html error_template @error
        return

      @$el.html '<canvas id=planCanvas></canvas><canvas id=planRowsCanvas></canvas><canvas id=timeCanvas></canvas><canvas id=actualRowsCanvas></canvas>'

      return unless @explain

      @usedSpace = []
      @layoutPlan item.Plan for item in @explain

      x = 0
      y = 0
      findGridDimensions = (node) ->
        x = node.x if node.x > x
        y = node.y if node.y > y

        findGridDimensions plan for plan in node.Plans if node.Plans

      findGridDimensions item.Plan, 0 for item in @explain

      y += 1

      @planCanvas = @$el.find('#planCanvas')
      @planCanvas[0].width = x * gridWidth
      @planCanvas[0].height = y * gridHeight
      @planCtx = @planCanvas[0].getContext '2d'
      @planCtx.fillStyle = '#ccc'
      @planCtx.lineWidth = 0.5

      @planRowsCanvas = @$el.find('#planRowsCanvas')
      @planRowsCanvas[0].width = x * gridWidth
      @planRowsCanvas[0].height = y * gridHeight
      @planRowsCtx = @planRowsCanvas[0].getContext '2d'
      @planRowsCtx.fillStyle = '#ccc'
      @planRowsCtx.lineWidth = 0.5

      @timeCanvas = @$el.find('#timeCanvas')
      @timeCanvas[0].width = x * gridWidth
      @timeCanvas[0].height = y * gridHeight
      @timeCtx = @timeCanvas[0].getContext '2d'
      @timeCtx.fillStyle = '#ccc'
      @timeCtx.lineWidth = 0.5

      @actualRowsCanvas = @$el.find('#actualRowsCanvas')
      @actualRowsCanvas[0].width = x * gridWidth
      @actualRowsCanvas[0].height = y * gridHeight
      @actualRowsCtx = @actualRowsCanvas[0].getContext '2d'
      @actualRowsCtx.fillStyle = '#ccc'
      @actualRowsCtx.lineWidth = 0.5

      @renderExplain item.Plan, 1 for item in @explain

      duration = Math.round(@duration * 100) / 100
      @$el.append "<div class=duration>#{duration}</div>"

      if @explain[0].Plan['Actual Total Time']
        opt = $ '<input type=radio name=type>'
      else
        opt = $ '<input type=radio name=type checked>'

      opt.change =>
        @planCanvas.show()
        @planRowsCanvas.hide()
        @timeCanvas.hide()
        @actualRowsCanvas.hide()
      div = $ '<label id=planRadio>'
      div.append opt
      div.append 'Planned cost'
      @$el.append div

      opt = $ '<input type=radio name=type>'
      opt.change =>
        @planCanvas.hide()
        @planRowsCanvas.show()
        @timeCanvas.hide()
        @actualRowsCanvas.hide()
      div = $ '<label id=planRowsRadio>'
      div.append opt
      div.append 'Planned rows'
      @$el.append div

      if @explain[0].Plan['Actual Total Time']
        opt = $ '<input type=radio name=type checked>'
        opt.change =>
          @planCanvas.hide()
          @planRowsCanvas.hide()
          @timeCanvas.show()
          @actualRowsCanvas.hide()
        div = $ '<label id=timeRadio>'
        div.append opt
        div.append 'Actual time'
        @$el.append div

        opt.change()

        opt = $ '<input type=radio name=type>'
        opt.change =>
          @planCanvas.hide()
          @planRowsCanvas.hide()
          @timeCanvas.hide()
          @actualRowsCanvas.show()
        div = $ '<label id=actualRowsRadio>'
        div.append opt
        div.append 'Actual rows'
        @$el.append div

    types =
      'Append': 'append'
      'Aggregate': 'aggregate'
      'BitmapAnd': 'bmp_and'
      'BitmapOr': 'bmp_or'
      'Bitmap Heap Scan': 'bmp_heap'
      'Bitmap Index Scan': 'bmp_index'
      'CTE Scan': 'cte_scan'
      'Delete': 'delete'
      'Except All': 'hash_setop_except_all'
      'Except': 'hash_setop_except'
      'Function Scan': 'result'
      'Group': 'group'
      'Hash Join': 'join'
      'Hash': 'hash'
      'Index Only Scan': 'index_only_scan'
      'Index Scan': 'index_scan'
      'Intersect All': 'hash_setop_intersect_all'
      'Intersect': 'hash_setop_intersect'
      'Insert': 'insert'
      'Limit': 'limit'
      'Materialize': 'materialize'
      'Merge Append': 'merge_append'
      'Merge Join': 'merge'
      'Nested Loop': 'nested'
      'Result': 'result'
      'Seq Scan': 'scan'
      'Sort': 'sort'
      'Subquery Scan': 'subplan'
      'Unique': 'unique'
      'Update': 'update'
      'Values Scan': 'values_scan'
      'WindowAgg': 'window_aggregate'

    textFns =
      'Aggregate': (node) -> [
        'Aggregate'
      ]
      'Bitmap Heap Scan': (node) -> [
        truncate node['Relation Name']
        truncate node['Recheck Cond']
      ]
      'Bitmap Index Scan': (node) -> [
        truncate node['Index Name']
        truncate node['Index Cond']
      ]
      'CTE Scan': (node) -> [
        truncate node['CTE Name']
      ]
      'Function Scan': (node) -> [
        'Function Scan'
        truncate node['Function Call']
      ]
      'Hash Join': (node) -> [
        "Hash #{node['Join Type']} Join"
        truncate node['Hash Cond']
      ]
      'Index Scan': (node) -> [
        truncate node['Index Name']
        truncate node['Index Cond']
      ]
      'Index Only Scan': (node) -> [
        truncate node['Index Name']
        truncate node['Index Cond']
      ]
      'Merge Append': (node) -> [
        'Merge Append'
        truncate node['Sort Key']
      ]
      'Merge Join': (node) -> [
        "Merge#{[" #{node['Join Type']}"]} Join"
        truncate node['Merge Cond']
      ]
      'ModifyTable': (node) -> [
        node['Operation']
        truncate node['Relation Name']
      ]
      'Nested Loop': (node) -> [
        "#{node['Join Type']} Join Loop"
      ]
      'Seq Scan': (node) -> [
        truncate node['Relation Name']
      ]
      'SetOp': (node) -> [
        node['Command']
      ]
      'Sort': (node) -> [
        'Sort'
        truncate truncate_array node['Sort Key']
        "#{node['Sort Space Type']}, #{node['Sort Method']}" if node['Sort Space Type']
      ]

    commonTextFn = (node, prev) -> [
      prev.splice 1, 0, "alias: #{node['Alias']}" if node['Alias'] unless node['Alias'] is node['Relation Name'] or node['Alias'] is node['CTE Name']
      prev.push "subplan: #{node['Subplan Name']}" if node['Subplan Name']
      prev.push truncate "filter: #{node['Join Filter']}" if node['Join Filter']
      prev.push truncate "filter: #{node['Filter']}" if node['Filter']
    ]

    gridWidth = 176 # 128
    gridHeight = 96 # 88

    iconSize = 50
    arrowMid = (gridWidth - iconSize) / 2

    layoutPlan: (node, x=1, y=0) ->
      return true if @usedSpace[y] <= x

      if node.Plans
        childY = y
        firstChild = true

        for plan in node.Plans
          collision = @layoutPlan plan, x + 1, childY

          return true if collision and firstChild

          while collision
            childY += 1
            collision = @layoutPlan plan, x + 1, childY

          firstChild = false

      @usedSpace[y] = x

      node.x = x
      node.y = y

      false

    renderExplain: (node, depth, parentY=0, planMultiplier=1) ->
      img = $ '<img>'

      if node['Node Type'] is 'SetOp'
        type = types[node['Command']] || 'hash_setop_unknown'
      else
        type = types[node['Node Type']] || 'unknown'

      hoverdiv = $ '<div class=hover>'

      img.attr 'src', "img/ex_#{type}.png"
      img.addClass 'icon'
      img.css
        left: node.x * gridWidth
        top: node.y * gridHeight
      hoverdiv.append img

      detail = $ '<div>'
      detail.addClass 'detail'
      detail.css
        left: node.x * gridWidth
        top: node.y * gridHeight

      table = $ '<table>'
      detail.append table

      for item of node
        continue if item is 'Plans' or item is 'x' or item is 'y'

        value = node[item]
        value = value.join '\n' if value instanceof Array

        unless item is 'Plans'
          table.append "<tr><th>#{item}<td>#{"#{value}".replace(/</g, '&lt;')}"

      hoverdiv.append detail

      text = $ '<div>'

      fn = textFns[node['Node Type']] || -> [node['Node Type']]

      textBody = fn node
      commonTextFn node, textBody
      textBody = textBody.join '\n'
      textBody = textBody.replace /\n\n+/g, '\n'
      textBody = textBody.replace /\(public\./g, '('
      textBody = textBody.replace /\ public\./g, ' '
      textBody = textBody.replace /\npublic./g, '\n'

      text.text textBody
      text.addClass 'label'
      text.css
        left: node.x * gridWidth
        top: node.y * gridHeight
      hoverdiv.append text

      @$el.append hoverdiv

      toX = (node.x - 1) * gridWidth
      toY = parentY * gridHeight + iconSize / 2

      fromX = node.x * gridWidth - iconSize
      fromY = node.y * gridHeight + iconSize / 2

      drawLine = (value, ctx) ->
        thickness = Math.log(1 + value) / Math.LN2 / 2
        ctx.beginPath()
        ctx.moveTo toX, toY
        ctx.lineTo toX + thickness + 5, toY - thickness - 5
        ctx.lineTo toX + thickness + 5, toY - thickness
        ctx.bezierCurveTo toX + arrowMid + thickness, toY - thickness, toX + arrowMid + thickness, fromY - thickness, fromX, fromY - thickness
        ctx.lineTo fromX, fromY + thickness
        ctx.bezierCurveTo toX + arrowMid - thickness, fromY + thickness, toX + arrowMid - thickness, toY + thickness, toX + thickness + 5, toY + thickness
        ctx.lineTo toX + thickness + 5, toY + thickness + 5
        ctx.lineTo toX, toY
        ctx.fill()
        ctx.stroke()

      if node['Actual Total Time']?
        drawLine node['Actual Total Time'] * 16 * node['Actual Loops'], @timeCtx
        drawLine node['Actual Rows'] * node['Actual Loops'], @actualRowsCtx
      drawLine node['Total Cost'] * planMultiplier, @planCtx
      drawLine node['Plan Rows'] * planMultiplier, @planRowsCtx

      if node.Plans
        for subPlan in node.Plans
          if node['Node Type'] == 'Nested Loop'
            if subPlan['Parent Relationship'] == 'Outer'
              innerPlanMultiplier = planMultiplier * subPlan['Plan Rows']
              subPlanMultiplier = planMultiplier
            else
              subPlanMultiplier = innerPlanMultiplier
          else if subPlan['Parent Relationship'] == 'SubPlan'
            subPlanMultiplier = planMultiplier * node['Plan Rows']
          else
            subPlanMultiplier = planMultiplier
          @renderExplain subPlan, depth + 1, node.y, subPlanMultiplier

    setExplain: (@explain, @duration, @error) ->
      @render()
