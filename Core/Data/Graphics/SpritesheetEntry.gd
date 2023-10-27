extends Resource
class_name SpritesheetEntry

@export var name : StringName
@export var fps : int = 8

var parent : Spritesheet

func getFrame(target : Sprite3D, frame : int, blinkState : bool):
	# Apply changes
	# target.texture = texture
	# target.region_rect.position = Vector2(col * cellW, row * cellH)
	# target.region_rect.size = Vector2(cellW, cellH)
	pass

func getTotalFrames():
	return 1

func getFrameEvent(idx:int) -> StringName:
	return &""
