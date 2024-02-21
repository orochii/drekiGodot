extends Node3D

@export var target : Node3D

func _ready():
	if target != null:
		global_position = target.global_position
		global_rotation_degrees = Vector3(target.global_rotation_degrees.x, 0, target.global_rotation_degrees.z)

func _process(delta):
	if target != null:
		global_position = target.global_position
		global_rotation_degrees = Vector3(target.global_rotation_degrees.x, 0, target.global_rotation_degrees.z)
	var h = getHorz()
	if h != 0:
		rotate_y(delta * h)

func getHorz():
	#if !canMove(): return 0
	return Input.get_axis("cam_left", "cam_right")
