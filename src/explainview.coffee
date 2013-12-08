define [
	'backbone'
	'jquery'
], (Backbone, $) ->
	class ExplainView extends Backbone.View
		initialize: ->
			@render

		truncate_array = (arr) ->
			return arr.join ', ' if arr.length <= 5
			first = arr.slice(0, 5)
			first.push '…'
			first.join ', '

		render: ->
			@$el.html '<canvas id=planCanvas></canvas><canvas id=timeCanvas></canvas>'

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

			@timeCanvas = @$el.find('#timeCanvas')
			@timeCanvas[0].width = x * gridWidth
			@timeCanvas[0].height = y * gridHeight

			@timeCtx = @timeCanvas[0].getContext '2d'
			@timeCtx.fillStyle = '#ccc'
			@timeCtx.lineWidth = 0.5

			@renderExplain item.Plan, 1 for item in @explain

			@$el.append "<div class=duration>#{Math.round(@duration * 100) / 100}</div>"

			if @explain[0].Plan['Actual Total Time']
				opt = $ '<input type=radio name=type checked>'
				opt.change =>
					@planCanvas.show()
					@timeCanvas.hide()
				div = $ '<label id=planRadio>'
				div.append opt
				div.append 'Planned cost'
				@$el.append div

				opt = $ '<input type=radio name=type>'
				opt.change =>
					@timeCanvas.show()
					@planCanvas.hide()
				div = $ '<label id=timeRadio>'
				div.append opt
				div.append 'Actual time'
				@$el.append div


		types =
			'Append': 'append'
			'Aggregate': 'aggregate'
			'BitmapAnd': 'hash_setop_intersect'
			'Bitmap Heap Scan': 'bmp_heap'
			'Bitmap Index Scan': 'bmp_index'
			'CTE Scan': 'cte_scan'
			'Group': 'group'
			'Hash Join': 'join'
			'Hash': 'hash'
			'Index Only Scan': 'index_scan'
			'Index Scan': 'index_scan'
			'Limit': 'limit'
			'Materialize': 'materialize'
			'Merge Append': 'merge'
			'Merge Join': 'merge'
			'Nested Loop': 'nested'
			'Result': 'result'
			'Seq Scan': 'scan'
			'Sort': 'sort'
			'Subquery Scan': 'subplan'
			'Unique': 'unique'
			'Values Scan': 'result'
			'WindowAgg': 'window_aggregate'

		textFns =
			'Aggregate': (node) -> [
				'Aggregate'
				node['Subplan Name']
			]
			'Bitmap Heap Scan': (node) -> [
				node['Relation Name']
				node['Recheck Cond']
				"filter: #{node['Filter']}" if node['Filter']
			]
			'Bitmap Index Scan': (node) -> [
				node['Index Name']
				node['Index Cond']
			]
			'CTE Scan': (node) -> [
				node['CTE Name']
				"alias: #{node['Alias']}" unless node['Alias'] is node['CTE Name']
			]
			'Hash Join': (node) -> [
				'Hash Join'
				node['Hash Cond']
			]
			'Index Scan': (node) -> [
				node['Index Name']
				"alias: #{node['Alias']}" unless node['Alias'] is node['Relation Name']
				node['Index Cond']
				"filter: #{node['Filter']}" if node['Filter']
			]
			'Index Only Scan': (node) -> [
				node['Index Name']
				"alias: #{node['Alias']}" unless node['Alias'] is node['Relation Name']
				node['Index Cond']
			]
			'Merge Append': (node) -> [
				'Merge Append'
				node['Sort Key']
			]
			'Merge Join': (node) -> [
				"Merge#{[" #{node['Join Type']}"]} Join"
				node['Merge Cond']
			]
			'Nested Loop': (node) -> [
				'Nested Loop'
				"filter: #{node['Join Filter']}" if node['Join Filter']
			]
			'Seq Scan': (node) -> [
				node['Relation Name']
				"alias: #{node['Alias']}" unless node['Alias'] is node['Relation Name']
				node['Filter']
			]
			'Sort': (node) -> [
				'Sort'
				truncate_array node['Sort Key']
			]
			'Subquery Scan': (node) -> [
				'Subquery Scan'
				"alias: #{node['Alias']}"
				node['Filter']
			]

		gridWidth = 165 # 128
		gridHeight = 90 # 88

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

		renderExplain: (node, depth, parentY=0) ->
			img = $ '<img>'

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

				table.append "<tr><th>#{item}<td>#{value}" unless item is 'Plans'
			hoverdiv.append detail

			text = $ '<div>'

			fn = textFns[node['Node Type']] || -> [node['Node Type']]

			text.text fn(node).join('\n').replace(/\n\n+/g, '\n').replace(/\(public\./g, '(').replace(/\ public\./g, ' ').replace(/\npublic./g, '\n')
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

			drawLine node['Actual Total Time'] * 16 * node['Actual Loops'], @timeCtx if node['Actual Total Time']
			drawLine node['Total Cost'], @planCtx

			@renderExplain plan, depth + 1, node.y for plan in node.Plans if node.Plans

		setExplain: (@explain, @duration) ->
			@render()
