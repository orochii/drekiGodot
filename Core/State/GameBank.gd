extends Object
class_name GameBank

const MAX_GOLD = 9999999

var gold:int
var items:Array[GameInventoryEntry]

var transactionData:Array = [
	# {$"type":&"deposit","detail":"monsterHunt","amount":420,"timestamp":0}
]

#region Gold Storage
func maxTakeOutGold():
	var _availableSpace = (GameParty.MAX_GOLD - Global.State.party.gold)
	return mini(_availableSpace, gold)
func maxDepositGold():
	var _availableSpace = (MAX_GOLD - gold)
	return mini(_availableSpace, Global.State.party.gold)

func addGold(amount:int):
	gold += amount

func takeOutGold(amount:int):
	amount = clampi(amount, 0, maxTakeOutGold())
	gold -= amount
	Global.State.party.gainGold(amount)

func depositGold(amount:int):
	amount = clampi(amount,0, maxDepositGold())
	Global.State.party.loseGold(amount)
	gold += amount
#endregion

#region Item Storage
func itemCount(id:StringName):
	for i in items:
		if i.id == id:
			return i.amount
	return 0

func takeOutItem(id:StringName, amount:int):
	if amount <= 0: return
	var _toRemove = -1
	for idx in range(items.size()):
		var i = items[idx]
		if i.id == id:
			var _availableSpace = GameParty.MAX_ITEMS - Global.State.party.itemCount(i.id)
			amount = mini(i.amount, amount)
			amount = mini(_availableSpace, amount)
			i.amount -= amount
			Global.State.party.gainItem(i.id, amount)
			if i.amount <= 0:
				_toRemove = idx
			break
	if _toRemove > -1:
		items.remove_at(_toRemove)
func depositItem(id:StringName,amount:int):
	if amount <= 0: return
	for i in items:
		if i.id == id:
			var _availableSpace = GameParty.MAX_ITEMS - i.amount
			amount = mini(_availableSpace, amount)
			Global.State.party.loseItem(id, amount)
			i.amount += amount
			return
	var i = GameInventoryEntry.new()
	i.id = id
	i.amount = amount
	items.append(i)
#endregion

#region Serialization
func _serialize():
	var savedata = {
		"gold" : gold,
		"items" : _serializeInventory()
	}
	return savedata

func _serializeInventory():
	var ary = []
	for i in items: ary.append(i._serialize())
	return ary

func _deserialize(savedata : Dictionary):
	for key in savedata:
		match key:
			"inventory":
				var _inv = _deserializeInventory(savedata[key])
				items = _inv
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
