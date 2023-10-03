extends SpritesheetEntry
class_name BattlerSpritesheetEntry

@export var frames : Array[Vector2i]

func getFrame(target : Sprite3D, frame : int, blinkState : bool):
	var bParent = parent as BattlerSpritesheet
	if bParent != null:
		var f = frames[frame]
		target.texture = bParent.texture
		target.region_rect.position = Vector2(f.x * bParent.cellW, f.y * bParent.cellH)
		target.region_rect.size = Vector2(bParent.cellW, bParent.cellH)
		target.position.y = (bParent.cellH * 0.5) * target.pixel_size
	pass

func getTotalFrames():
	return frames.size()
