extends Node3D
class_name VisualEffect

@export var done:bool = false
@export var queueForDeletion:bool = false

func _process(delta):
	if queueForDeletion:
		queue_free()

func setup(user:Node3D, targets:Array[Node3D]):
	user.get_parent().add_child(self)
	var pos = getAvgPosition(targets)
	self.global_position = pos

func getAvgPosition(targets:Array[Node3D]):
	var pos = Vector3(0,0,0)
	if targets.size()==0: return pos
	for t in targets:
		pos += t.global_position
	pos /= targets.size()
	return pos
