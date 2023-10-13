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
