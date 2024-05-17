extends Object
class_name GameParty

const MAX_PARTY_SIZE = 3
const MAX_ITEMS = 99
const MAX_GOLD = 99999

var members : Array
var currentParty : int = 0
var reserve : Array
var inventory : Array[GameInventoryEntry]
var gold : int

#region Inventory Operations
func gainGold(n:int):
	gold = clamp(gold+n,0,MAX_GOLD)
func loseGold(n:int):
	gold = clamp(gold-n,0,MAX_GOLD)

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

func hasItem(id:StringName):
	return (itemCount(id) > 0)
#endregion

#region Party Operations
func getMembers():
	if members.size() <= currentParty:
		for i in range(members.size(), currentParty+1):
			members.append([])
	return members[currentParty]

func getMember(i:int):
	if i >= getMembers().size() || i < 0: return null
	var id = getMembers()[i]
	var actor = Global.State.getActor(id)
	return actor

func addMember(dataActor):
	var id = dataActor.getId()
	var gameActor = Global.State.getActor(id)
	if !getMembers().has(id) && !reserve.has(id):
		if getMembers().size() < MAX_PARTY_SIZE:
			getMembers().append(id)
		else:
			reserve.append(id)

func removeMember(dataActor,completely=false):
	var id = dataActor.getId()
	if getMembers().has(id):
		getMembers().erase(id)
		reserve.append(id)
	if completely:
		reserve.erase(id)

func swapMember(idx1:int,type1:int,idx2:int,type2:int):
	# Make references
	var actors_array1 = reserve if type1==-1 else members[type1]
	var actors_array2 = reserve if type2==-1 else members[type2]
	var affected_actors = [null,null]
	if idx1 < actors_array1.size(): affected_actors[0] = actors_array1[idx1]
	if idx2 < actors_array2.size(): affected_actors[1] = actors_array2[idx2]
	# Make changes, remove nils
	actors_array1[idx1] = affected_actors[1]
	actors_array2[idx2] = affected_actors[0]
	actors_array1.erase(null)
	actors_array2.erase(null)

func checkSwap():
	pass
#endregion

#region Init and Serialization
func _init():
	members = []
	for a in Global.Db.startingParty:
		var id = a.getId()
		getMembers().append(id)
		var actor = Global.State.getActor(id)
	inventory = []
	gold = 0

func _serialize():
	var savedata = {
		"members" : members,
		"currentParty" : currentParty,
		"reserve" : reserve,
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
#endregion
