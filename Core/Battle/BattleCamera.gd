extends SubViewport
class_name BattleCamera

@export var camera:Camera3D

func _ready():
	var window = get_window()
	updateScreenSize(window.content_scale_size)

func _enter_tree():
	if Global.Config != null: 
		Global.Config.onScreenSizeChange.connect(updateScreenSize)
func _exit_tree():
	if Global.Config != null: 
		Global.Config.onScreenSizeChange.disconnect(updateScreenSize)

func _process(delta):
	pass

func updateScreenSize(newSize:Vector2i):
	size = newSize
	camera.size = newSize.y * Global.PIXEL_SIZE
	camera.fov = newSize.y * Global.PIXEL_FOV
