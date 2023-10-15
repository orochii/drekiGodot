extends Resource
class_name StatusState

@export var id:StringName
@export var turns:int

func _serialize():
	return {
		"id":id,
		"turns":turns
	}

func _deserialize(data:Dictionary):
	id = data["id"]
	turns = data["turns"]
