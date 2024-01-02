extends SpritesheetEntry
class_name BigMapSpritesheetEntry

@export var base : Texture2D
@export var blink : Texture2D
@export var totalFrames : int = 6
@export var shortMode : bool = true
@export var events : Array[StringName] = ["","","step","","","step"]

#----------------  0 1 2 3 4 5 6 7
const DIR_REMAP = [0,1,2,3,4,3,2,1]

func _resolveDir(target : Sprite3D):
	var step : float = 45.0
	var angle : float = target.global_rotation_degrees.y + 180 #+ (step/2)
	var cam = target.get_viewport().get_camera_3d()
	if (cam != null): angle -= cam.global_rotation_degrees.y
	if angle >= 360: angle -= 360
	if angle < 0: angle += 360
	var dir : int = roundi(angle / step)
	if (dir == 8): dir = 0
	return dir

func _resolveRow(dir : int, blinkState : bool):
	var row = DIR_REMAP[dir] if shortMode else dir
	return {
		&"row" : row,
		&"texture" : _resolveBlink(base, blink, blinkState),
		&"flip" : (shortMode && dir > 4)
	}

func _resolveBlink(baseT : Texture2D, blinkT : Texture2D, state : bool) -> Texture2D:
	if state:
		return baseT if blinkT==null else blinkT
	else:
		return baseT

func getFrame(target : Sprite3D, frame : int, blinkState : bool):
	var dir = _resolveDir(target)
	var rr = _resolveRow(dir, blinkState)
	var texture = rr[&"texture"]
	var row = rr[&"row"]
	var col = frame
	var maxRow = 5 if shortMode else 8
	var cellW = texture.get_width() / totalFrames
	var cellH = texture.get_height() / maxRow
	#Apply changes
	target.texture = texture
	target.region_rect.position = Vector2(col * cellW, row * cellH)
	target.region_rect.size = Vector2(cellW, cellH)
	#target.position.y = (cellH * 0.5) * target.pixel_size
	target.offset.y = (cellH * 0.5)
	target.flip_h = rr[&"flip"]

func getTotalFrames():
	return totalFrames

func getFrameEvent(idx:int) -> StringName:
	if(events.size() > idx):
		if events[idx]==null: return &""
		return events[idx]
	return &""
