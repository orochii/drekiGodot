extends Node3D

@export var refBody : Node3D

func _process(delta):
	look_at(refBody.global_position, Vector3.UP)
	
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	global_position += Vector3(input_dir.x, input_dir.y, 0)
