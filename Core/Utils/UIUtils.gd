extends Object
class_name UIUtils

static func setVNeighbors(srcAry:Array):
	for i in range(srcAry.size()):
		var current:Button = srcAry[i]
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
		var current:Button = srcAry[i]
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
		var current:Button = srcAry[i]
		var ti = max(0,i-1)
		var left:Button = srcAry[ti]
		ti = min(srcAry.size()-1,i+1)
		var right:Button = srcAry[ti]
		ti = max(0,i-columns)
		var top:Button = srcAry[ti]
		ti = min(srcAry.size()-1,i+columns)
		var bottom:Button = srcAry[ti]
		# Set neighbors
		current.focus_neighbor_top = top.get_path()
		current.focus_neighbor_bottom = bottom.get_path()
		current.focus_neighbor_left = left.get_path()
		current.focus_neighbor_right = right.get_path()
		current.focus_next = current.focus_neighbor_left
		current.focus_previous = current.focus_neighbor_right
