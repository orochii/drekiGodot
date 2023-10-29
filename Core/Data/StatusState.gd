extends Resource
class_name StatusState

@export var id:StringName
@export var turns:int
@export var stack:int

func _serialize():
	return {
		"id":id,
		"turns":turns,
		"stack":1
	}

func _deserialize(data:Dictionary):
	id = data["id"]
	turns = data["turns"]
	stack = 1
