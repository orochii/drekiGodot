extends Object
class_name GameParty

const MAX_ITEMS = 99

var members : Array
var inventory : Array[GameInventoryEntry]
var gold : int

func gainItem(id:StringName,n:int):
	if(n<=0): return
	for e in inventory:
		if(e.id==id):
			e.amount = mini(e.amount+n, MAX_ITEMS)
			return
	var e = GameInventoryEntry.new()
	e.id = id
	e.amount = mini(n, MAX_ITEMS)
	inventory.append(e)

func loseItem(id:StringName,n:int):
	if(n<=0): return
	var toRemove = null
	for e in inventory:
		if(e.id==id):
			e.amount = e.amount-n
			toRemove = e
			break
	if(toRemove != null):
		if(toRemove.amount <= 0):
			inventory.erase(toRemove)

func itemCount(id:StringName):
	for e in inventory:
		if(e.id==id):
			return e.amount
	return 0

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
				inventory = _inv
			_:
				set(key, savedata[key])

func _deserializeInventory(data : Array):
	var _inv:Array[GameInventoryEntry] = []
	for i in data:
		var _e = GameInventoryEntry.new()
		_e._deserialize(i)
		_inv.append(_e)
	return _inv
