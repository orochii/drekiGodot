@tool
extends Resource
class_name SpritesheetEntry

@export var name : StringName
@export var fps : int = 12
@export var idleSpeed : float = 0

var parent : Spritesheet

func getFrame(target : Sprite3D, frame : int, blinkState : bool):
	# Apply changes
	# target.texture = texture
	# target.region_rect.position = Vector2(col * cellW, row * cellH)
	# target.region_rect.size = Vector2(cellW, cellH)
	pass

func getFrameAsData(frame:int,blink:bool,dir:int):
	return {
		"texture":null,
		"rect_pos":Vector2(),
		"rect_size":Vector2(),
		"offset_y":0.0,
		"flip_h":false
	}

func getTotalFrames():
	return 1

func getFrameEvent(idx:int) -> StringName:
	return &""
