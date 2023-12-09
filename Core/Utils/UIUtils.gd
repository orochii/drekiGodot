extends Object
class_name UIUtils

static func setVNeighbors(srcAry:Array):
	for i in range(srcAry.size()):
		var current = srcAry[i]
		current.focus_neighbor_left = current.get_path()
		current.focus_neighbor_right = current.get_path()
		# Prev
		if i-1 >= 0:
			current.focus_neighbor_top = srcAry[i-1].get_path()
		else:
			current.focus_neighbor_top = current.get_path()
		# Next
		if i+1 < srcAry.size():
			current.focus_neighbor_bottom = srcAry[i+1].get_path()
		else:
			#srcAry[0]
			current.focus_neighbor_bottom = current.get_path()
		current.focus_next = current.focus_neighbor_bottom
		current.focus_previous = current.focus_neighbor_top

static func setHNeighbors(srcAry:Array):
	for i in range(srcAry.size()):
		var current = srcAry[i]
		current.focus_neighbor_top = current.get_path()
		current.focus_neighbor_bottom = current.get_path()
		# Prev
		if i-1 >= 0:
			current.focus_neighbor_left = srcAry[i-1].get_path()
		else:
			current.focus_neighbor_left = current.get_path()
		# Next
		if i+1 < srcAry.size():
			current.focus_neighbor_right = srcAry[i+1].get_path()
		else:
			#srcAry[0]
			current.focus_neighbor_right = current.get_path()
		current.focus_next = current.focus_neighbor_left
		current.focus_previous = current.focus_neighbor_right

static func setGridNeighbors(srcAry:Array,columns:int):
	for i in range(srcAry.size()):
		# Get all references
		var current = srcAry[i]
		var ti = max(0,i-1)
		var left = srcAry[ti]
		ti = min(srcAry.size()-1,i+1)
		var right = srcAry[ti]
		ti = max(0,i-columns)
		var top = srcAry[ti]
		ti = min(srcAry.size()-1,i+columns)
		var bottom = srcAry[ti]
		# Set neighbors
		current.focus_neighbor_top = top.get_path()
		current.focus_neighbor_bottom = bottom.get_path()
		current.focus_neighbor_left = left.get_path()
		current.focus_neighbor_right = right.get_path()
		current.focus_next = current.focus_neighbor_left
		current.focus_previous = current.focus_neighbor_right

static func setFluxNeighbors(srcAry:Array):
	# Split controls into lines
	var lines = []
	var curr_line = []
	var last_x = -9999
	for n in srcAry:
		if n.position.x > last_x:
			last_x = n.position.x
			curr_line.append(n)
		else:
			last_x = -9999
			lines.append(curr_line)
			curr_line = []
			curr_line.append(n)
	lines.append(curr_line)
	# 
	for j in range(lines.size()):
		curr_line = lines[j]
		var prev_line = null if j < 1 else lines[j-1]
		var next_line = null if j >= (lines.size()-1) else lines[j+1]
		for i in range(curr_line.size()):
			var curr = curr_line[i]
			var left = curr if i < 1 else curr_line[i-1]
			var right= curr if i >= (curr_line.size()-1) else curr_line[i+1]
			# Find top
			var top = curr
			if prev_line != null:
				var cx1 = curr.position.x
				var cx2 = cx1 + curr.size.x
				var dst = 9999
				for n in prev_line:
					var max = n.position.x + n.size.x
					if (cx1 >= n.position.x && cx1 < max) || (cx2 >= n.position.x && cx2 < max):
						var cdst = abs(curr.position.x-n.position.x)
						if dst > cdst:
							dst = cdst
							top = n
			# Find bottom
			var bot = curr
			if next_line != null:
				var cx1 = curr.position.x
				var cx2 = cx1 + curr.size.x
				var dst = 9999
				for n in next_line:
					var max = n.position.x + n.size.x
					if (cx1 >= n.position.x && cx1 < max) || (cx2 >= n.position.x && cx2 < max):
						var cdst = abs(curr.position.x-n.position.x)
						if dst > cdst:
							dst = cdst
							bot = n
			# Set neighbors
			curr.focus_neighbor_top = top.get_path()
			curr.focus_neighbor_bottom = bot.get_path()
			curr.focus_neighbor_left = left.get_path()
			curr.focus_neighbor_right = right.get_path()
			curr.focus_next = curr.focus_neighbor_left
			curr.focus_previous = curr.focus_neighbor_right
