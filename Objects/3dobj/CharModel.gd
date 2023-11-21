extends Node3D

@export var model:Node3D

var animation:AnimationPlayer
var blend:float = 0.8

func _ready():
	# I really don't like to do things through names but this will do for now.
	animation = model.get_node("AnimationPlayer")
	animation.play("Standing")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var axis = Input.get_vector("move_left", "move_right", "move_down", "move_up")
	if axis != Vector2.ZERO:
		animation.play("Run",blend)
	else:
		animation.play("Standing",blend)
