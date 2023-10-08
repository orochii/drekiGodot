extends Object
class_name GameInventoryEntry

var id : StringName
var amount : int

func _serialize():
	var savedata = {
		"id" : id,
		"amount" : amount
	}
	return savedata

func _deserialize(savedata : Dictionary):
	for key in savedata:
		set(key, savedata[key])
