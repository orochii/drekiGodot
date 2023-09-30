extends Character
class_name NPC

@export var event : BaseEvent

func _ready():
	pass

func _process(delta):
	pass

func onTouch():
	if (event != null): event.execute()
