extends BaseEvent

@export var elevator:Node

func _run():
	#var elevator = get_parent().get_parent()
	if(elevator != null): elevator.move()
