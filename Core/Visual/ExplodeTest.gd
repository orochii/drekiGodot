extends Sprite3D

@export var impostorTemplate:PackedScene

func _process(delta):
	var axis = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	position += Vector3(axis.x, axis.y, 0) * delta
	
	if Input.is_action_just_pressed("action_cancel"):
		visible = true
	if Input.is_action_just_pressed("action_ok"):
		var impostor = impostorTemplate.instantiate()
		get_parent().add_child(impostor)
		visible = false
		impostor.setup(self)
