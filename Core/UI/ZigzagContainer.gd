@tool
extends Container
class_name ZigzagContainer

@export var columns:int = 7
@export var spacing:Vector2i = Vector2i(2,2)
@export var offset:int = 8

func _notification(what):
	reposition_children()

func reposition_children():
	var line_idx = 0
	var curr_pos = Vector2(0,0)
	var curr_line_height = 0
	for c in get_children():
		if c is Control:
			var control:Control = c as Control
			curr_line_height = max(control.size.y, curr_line_height)
			if curr_pos.x + control.size.x > size.x:
				line_idx += 1
				curr_pos.x = 0 if line_idx%2==0 else offset
				curr_pos.y += curr_line_height + spacing.y
				curr_line_height = 0
			control.position = curr_pos
			curr_pos += Vector2(control.size.x + spacing.x, 0)
