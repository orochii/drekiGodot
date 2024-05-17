extends BaseEvent

@export var anim:AnimationPlayer
@export var ladder:BaseEvent
@export var waitTime:float

func _run():
	var s = get_parent().getLocalVar(&"dropped")
	if !s:
		get_parent().setLocalVar(&"dropped", true)
		setup()
		await get_tree().create_timer(waitTime).timeout
	else:
		await ladder._run()

func setup(immediate:bool=false):
	var s = get_parent().getLocalVar(&"dropped")
	if s:
		if immediate:
			anim.play(&"end_pos")
		else:
			anim.play(&"execute")
	else:
		anim.play(&"RESET")
