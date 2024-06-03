extends BaseEvent

@export var vehicle:Node3D

func _run():
	vehicle.onInteract()