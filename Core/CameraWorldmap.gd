extends CameraControlBase
class_name CameraWorldmap

const GAME_TIME_SCALE = 600

@export var pivot : Node3D

func _ready():
	super._ready()
	if target != null:
		global_position = target.global_position
		align_with_target()

func _process(delta):
	Global.State.advanceTime(delta * GAME_TIME_SCALE * Global.GAME_TIME_SCALE)
	if target != null:
		global_position = target.global_position
		#global_rotation_degrees = target.transform.basis.y
		align_with_target()
	var h = getHorz()
	if h != 0:
		pivot.rotate_y(delta * h)

func getHorz():
	#if !canMove(): return 0
	return Input.get_axis("cam_left", "cam_right")

func align_with_target():
	global_transform = align_with_y(global_transform, target.transform.basis.y)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func getLayers():
	return camera.cull_mask
