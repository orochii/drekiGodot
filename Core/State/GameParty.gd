extends Object
class_name GameParty

var members : Array[StringName]
var inventory : Array[GameInventoryEntry]
var gold : int

func _init():
	members = []
	for a in Global.Db.startingParty:
		var id = a.getId()
		members.append(id)
		var actor = Global.State.getActor(id)
	inventory = []
	gold = 0

func _serialize():
	var savedata = {
		"members" : members,
		"inventory" : _serializeInventory(),
		"gold" : gold
	}
	return savedata

func _serializeInventory():
	var ary = []
	for i in inventory: ary.append(i._serialize())
	return ary

func _deserialize(savedata : Dictionary):
	for key in savedata:
		match key:
			"inventory":
				var _inv = _deserializeInventory(savedata[key])
				set(key, _inv)
			_:
				set(key, savedata[key])

func _deserializeInventory(data : Array):
	var _inv = []
	for i in data:
		var _e = GameInventoryEntry.new()
		_e._deserialize(i)
		_inv.append(_e)
	return _inv
