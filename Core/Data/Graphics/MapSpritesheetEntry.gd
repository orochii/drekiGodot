@tool
extends SpritesheetEntry
class_name MapSpritesheetEntry

@export var base : Texture2D
@export var baseDiag : Texture2D
@export var blink : Texture2D
@export var blinkDiag : Texture2D
@export var totalFrames : int = 4
@export var events : Array[StringName] = ["","step","","step"]
@export var offset : Vector2i
@export var offsetTowardsCamera : float

func _resolveDir(target : Sprite3D):
	var hasDiag = (baseDiag != null)
	var step : float = 90.0 if !hasDiag else 45.0
	var angle : float = 0
	if !Engine.is_editor_hint():
		angle = target.global_rotation_degrees.y + 180 #+ (step/2)
		#if !hasDiag: angle -= 30
	else:
		angle = 180
	var yRefNode = null
	if !Engine.is_editor_hint(): yRefNode = target.get("yRefNode")
	if yRefNode != null:
		angle = -target.rotation_degrees.y - 90
		angle -= yRefNode.rotation_degrees.y
	else:
		var cam = null
		if !Engine.is_editor_hint(): cam = target.get_viewport().get_camera_3d()
		if (cam != null): angle -= cam.global_rotation_degrees.y
	if angle >= 360: angle -= 360
	if angle < 0: angle += 360
	var dir : int = roundi(angle / step)
	if (dir == 8): dir = 0
	return {
		&"dir" : dir,
		&"hasDiag" : hasDiag,
		&"angle" : angle
	}

func _resolveRow(hasDiag : bool, dir : int, blinkState : bool):
	var texture = null
	var row = 0
	if hasDiag:
		match dir:
			0:
				texture = _resolveBlink(base,blink,blinkState)
				row = 3
			1:
				texture = _resolveBlink(baseDiag,blinkDiag,blinkState)
				row = 2
			2:
				texture = _resolveBlink(base,blink,blinkState)
				row = 1
			3:
				texture = _resolveBlink(baseDiag,blinkDiag,blinkState)
				row = 0
			4:
				texture = _resolveBlink(base,blink,blinkState)
				row = 0
			5:
				texture = _resolveBlink(baseDiag,blinkDiag,blinkState)
				row = 1
			6:
				texture = _resolveBlink(base,blink,blinkState)
				row = 2
			_:
				texture = _resolveBlink(baseDiag,blinkDiag,blinkState)
				row = 3
	else:
		texture = _resolveBlink(base,blink,blinkState)
		match dir:
			0:
				row = 3
			1:
				row = 1
			2:
				row = 0
			_:
				row = 2
	return {
		&"row" : row,
		&"texture" : texture
	}

func _resolveBlink(baseT : Texture2D, blinkT : Texture2D, state : bool) -> Texture2D:
	if state:
		return baseT if blinkT==null else blinkT
	else:
		return baseT

func _resolveFrame(texture:Texture2D, row, col):
	var cellW = texture.get_width() / totalFrames
	var cellH = texture.get_height() / 4
	#Apply changes
	return {
		"texture":texture,
		"rect_pos":Vector2(col * cellW, row * cellH),
		"rect_size":Vector2(cellW, cellH),
		"offset_y":(cellH * 0.5) + offset.y,
		"flip_h":false
	}

func getFrame(target : Sprite3D, frame : int, blinkState : bool):
	if target==null: return
	var r = _resolveDir(target)
	var rr = _resolveRow(r[&"hasDiag"], r[&"dir"], blinkState)
	var f = _resolveFrame(rr[&"texture"],rr[&"row"],frame)
	#Move towards camera
	var _otc = Vector3(0,0,offsetTowardsCamera).rotated(Vector3.UP, deg_to_rad(-r[&"angle"]))
	target.position = _otc
	#Apply changes
	target.texture = f["texture"]
	target.region_rect.position = f["rect_pos"]
	target.region_rect.size = f["rect_size"]
	target.offset.y = f["offset_y"]

func getFrameAsData(frame:int,blink:bool,dir:int):
	var hasDiag = (baseDiag != null)
	var rr = _resolveRow(hasDiag, dir, blink)
	var f = _resolveFrame(rr[&"texture"],rr[&"row"],frame)
	return f

func getTotalFrames():
	return totalFrames

func getFrameEvent(idx:int) -> StringName:
	if(events.size() > idx):
		if events[idx]==null: return &""
		return events[idx]
	return &""
