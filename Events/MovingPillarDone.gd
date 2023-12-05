extends BaseEvent

@export var affectedNode:Node3D
@export var newPosition:Vector3

func setup(immediate:bool = false):
	var o = self.get_parent()
	affectedNode.global_position = newPosition
	o.global_position = newPosition
