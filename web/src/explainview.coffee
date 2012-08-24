define [
	'backbone'
	'jquery'
], (Backbone, $) ->
	class ExplainView extends Backbone.View
		initialize: ->
			@render

		render: ->
			@$el.html '<canvas>'

			return unless @explain

			@x = 1
			@y = 0

			x = 0
			y = 1
			maxX = 1
			findGridDimensions = (node, depth) ->
				if x != depth
					x = depth
					y++

				thisY = y
				x++
				maxX = x if x > maxX
				findGridDimensions plan, depth + 1, thisY for plan in node.Plans if node.Plans
			findGridDimensions item.Plan, 0 for item in @explain

			canvas = @$el.find('canvas')[0]
			canvas.width = maxX * gridWidth
			canvas.height = y * gridHeight

			@ctx = canvas.getContext '2d'
			@ctx.fillStyle = '#ccc'
			@ctx.lineWidth = 0.5

			@renderExplain item.Plan, 1 for item in @explain

		types =
			'Aggregate': 'aggregate'
			'Bitmap Heap Scan': 'bmp_heap'
			'Bitmap Index Scan': 'bmp_index'
			'Hash Join': 'join'
			'Hash': 'hash'
			'Index Scan': 'index_scan'
			'Limit': 'limit'
			'Materialize': 'materialize'
			'Merge Join': 'merge'
			'Nested Loop': 'nested'
			'Result': 'result'
			'Seq Scan': 'scan'
			'Sort': 'sort'
			'Unique': 'unique'

		textFns =
			'Bitmap Heap Scan': (node) ->
				node['Relation Name']
			'Bitmap Index Scan': (node) ->
				node['Index Name']
			'Index Scan': (node) ->
				node['Index Name']
			'Seq Scan': (node) ->
				node['Relation Name']

		gridWidth = 128
		gridHeight = 80

		iconSize = 50
		arrowMid = (gridWidth - iconSize) / 2

		renderExplain: (node, depth, targetY) ->
			if @x != depth
				@x = depth
				@y++

			targetY ?= @y

			img = $ '<img>'

			type = types[node['Node Type']] || 'unknown'

			hoverdiv = $ '<div class=hover>'

			img.attr 'src', "img/ex_#{type}.png"
			img.addClass 'icon'
			img.css
				left: @x * gridWidth
				top: @y * gridHeight
			hoverdiv.append img

			detail = $ '<div>'
			detail.addClass 'detail'
			detail.css
				left: @x * gridWidth
				top: @y * gridHeight

			table = $ '<table>'
			detail.append table

			for item of node
				table.append "<tr><th>#{item}<td>#{node[item]}" unless item is 'Plans'
			hoverdiv.append detail

			text = $ '<div>'

			fn = textFns[node['Node Type']] || -> node['Node Type']

			text.text fn node
			text.addClass 'label'
			text.css
				left: @x * gridWidth
				top: @y * gridHeight
			hoverdiv.append text

			@$el.append hoverdiv

			thickness = Math.log(node['Total Cost']) / Math.LN2 / 2

			toX = (@x - 1) * gridWidth
			toY = targetY * gridHeight + iconSize / 2

			fromX = @x * gridWidth - iconSize
			fromY = @y * gridHeight + iconSize / 2

			@ctx.beginPath()
			@ctx.moveTo toX, toY
			@ctx.lineTo toX + thickness + 5, toY - thickness - 5
			@ctx.lineTo toX + thickness + 5, toY - thickness
			@ctx.bezierCurveTo toX + arrowMid + thickness, toY - thickness, toX + arrowMid + thickness, fromY - thickness, fromX, fromY - thickness
			@ctx.lineTo fromX, fromY + thickness
			@ctx.bezierCurveTo toX + arrowMid - thickness, fromY + thickness, toX + arrowMid - thickness, toY + thickness, toX + thickness + 5, toY + thickness
			@ctx.lineTo toX + thickness + 5, toY + thickness + 5
			@ctx.lineTo toX, toY
			@ctx.fill()
			@ctx.stroke()

			thisY = @y

			@x++
			@renderExplain plan, depth + 1, thisY for plan in node.Plans if node.Plans

		setExplain: (@explain) ->
			@render()
