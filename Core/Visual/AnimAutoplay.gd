extends AnimationPlayer

func _ready():
	play("standby")

func _process(delta):
	if !is_playing():
		play("standby")
