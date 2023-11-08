extends SubViewport
class_name BattleCamera

@export var pivot:Node3D
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
	if Input.is_action_pressed("cam_left"):
		pivot.global_rotation_degrees.y += delta * 60
	elif Input.is_action_pressed("cam_right"):
		pivot.global_rotation_degrees.y -= delta * 60

func updateScreenSize(newSize:Vector2i):
	size = newSize
	camera.size = newSize.y * Global.PIXEL_SIZE
	camera.fov = newSize.y * Global.PIXEL_FOV
