extends SubViewportContainer

@export var compass:Node3D
@export var container:Control
@export var worldmapPlayerRef:Node3D

var allSprites:Array = []
var compassState:bool = false

func _ready():
	getAllSprites()
	setupCompassAnchor(false)

func anyBusy():
	if Global.Ev.isBusy(): return true
	if Global.UI.busy(): return true
	return false

func _process(delta):
	if compass != null:
		if worldmapPlayerRef != null:
			if !anyBusy() && Input.is_action_just_pressed("action_extra"):
				toggleCompassAnchor()
			compass.look_at(worldmapPlayerRef.global_position)
		else:
			var cam = get_viewport().get_camera_3d()
			compass.global_rotation = cam.global_rotation

func toggleCompassAnchor():
	compassState = !compassState
	setupCompassAnchor(compassState)

func setupCompassAnchor(v:bool):
	if v:
		container.anchor_left = 0
		container.anchor_top = 0
		container.anchor_right = 1
		container.anchor_bottom = 1
		container.offset_left = 0
		container.offset_top = 0
		container.offset_right = 0
		container.offset_bottom = 0
		setAllSpritePixelSize(0.0025)
	else:
		container.anchor_left = 1
		container.anchor_top = 1
		container.anchor_right = 1
		container.anchor_bottom = 1
		container.offset_left = -64
		container.offset_top = -96
		container.offset_right = 0
		container.offset_bottom = -32
		if worldmapPlayerRef != null: 
			setAllSpritePixelSize(0.01)

func getAllSprites():
	allSprites.clear()
	getChildren(container)

func getChildren(root:Node):
	var cs = root.get_children(true)
	for c in cs:
		if c is Sprite3D:
			allSprites.append(c)
		getChildren(c)

func setAllSpritePixelSize(newsize:float):
	for s in allSprites:
		s.pixel_size = newsize
