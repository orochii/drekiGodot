@tool
extends Control

@export var sprite:Sprite2D
@export var spritesheet:Spritesheet
@export var direction:int = 0
@export var state:StringName = &"run"
@export var speed:float = 1
var frame:float = 0

func _ready():
	visible = spritesheet==null
	if speed > 0:
		frame = randf() * 4

func setup(s:Spritesheet):
	spritesheet = s
	if spritesheet==null:
		visible = false
	else:
		visible = true
		frame = randf() * spritesheet.getSheet(state).getTotalFrames()

func _process(delta):
	if spritesheet==null: return
	var sheet = spritesheet.getSheet(state)
	if sheet != null:
		var f = sheet.getFrameAsData(int(frame),false,direction)
		if f == null: return
		if speed > 0:
			frame += delta * sheet.fps
			if frame >= sheet.getTotalFrames():
				frame -= sheet.getTotalFrames()
		else:
			frame = 0
		sprite.texture = f["texture"]
		sprite.region_rect.position = f["rect_pos"]
		sprite.region_rect.size = f["rect_size"]
		sprite.offset.y = -f["offset_y"]
		sprite.flip_h = f["flip_h"]
	
