extends AnimationPlayer

@export var animName:String = "standby"
@export var loop:bool = true

func _ready():
	play("standby")

func _process(delta):
	if !is_playing():
		play("standby")
