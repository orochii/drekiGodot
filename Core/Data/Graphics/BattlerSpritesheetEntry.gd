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
		#target.position.y = (bParent.cellH * 0.5) * target.pixel_size
		target.offset.y = (bParent.cellH * 0.5)
	target.flip_h = resolveFlip(target)

func getTotalFrames():
	return frames.size()

func resolveFlip(target : Sprite3D):
	var angle : float = target.global_rotation_degrees.y
	var cam = target.get_viewport().get_camera_3d()
	if (cam != null): angle -= cam.global_rotation_degrees.y
	if angle >= 360: angle -= 360
	if angle < 0: angle += 360
	return angle < 180
