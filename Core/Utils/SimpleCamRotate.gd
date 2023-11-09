extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("cam_left"):
		global_rotation_degrees.y += delta * 60
	elif Input.is_action_pressed("cam_right"):
		global_rotation_degrees.y -= delta * 60
