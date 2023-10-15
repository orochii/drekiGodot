extends GameBattler
class_name GameActor

var name : String
var position : int = 0
var exp : int
var equips : Array
var _expList : Array[int] = []

func _init(_id:StringName):
	id = _id
	var actor:Actor = getData()
	if (actor == null): return
	name = actor.name
	level = actor.startLevel
	currHP = getMaxHP()
	currMP = getMaxMP()
	makeExpList()
	# Resize array if needed
	var _slotsData = Global.Db.equipSlots
	if(equips.size() < _slotsData.size()):
		equips.resize(_slotsData.size())
	# Set starting equipment
	for item in actor.startingEquipment:
		for i in range(_slotsData.size()):
			var s = _slotsData[i].kind
			if item.slot==s && equips[i]==null && canEquip(item):
				equips[i] = item.getId()
				break

func getFeatures():
	var actor:Actor = getData()
	var features = []
	# Base features
	features.append_array(actor.features)
	# Equip features
	for e in equips:
		if(e != null):
			var data = Global.Db.getItem(e)
			if data is EquipItem:
				var equip = data as EquipItem
				features.append_array(equip.features)
	# Status features
	for s in states:
		var data:Status = Global.Db.getStatus(s.id)
		features.append_array(data.features)
	return features

func getBaseMaxHP():
	var actor:Actor = getData()
	return calcBaseStat(actor.mhp.x, actor.mhp.y, level)
func getBaseMaxMP():
	var actor:Actor = getData()
	return calcBaseStat(actor.mmp.x, actor.mmp.y, level)
func getBaseStr():
	var actor:Actor = getData()
	return calcBaseStat(actor.str.x, actor.str.y, level)
func getBaseVit():
	var actor:Actor = getData()
	return calcBaseStat(actor.vit.x, actor.vit.y, level)
func getBaseMag():
	var actor:Actor = getData()
	return calcBaseStat(actor.mag.x, actor.mag.y, level)
func getBaseAgi():
	var actor:Actor = getData()
	return calcBaseStat(actor.agi.x, actor.agi.y, level)

func calcBaseStat(base:int, mult:int, level:int) -> int:
	var lm : float = (mult * (level - 1)) / 100.0
	var m : float = (lm + 10.0) / 10.0
	return roundi(base * m)

func makeExpList():
	if _expList.size() != 0: return
	_expList.resize(Actor.MAX_LEVEL)
	var data = getData()
	var pow_i = 2.4 + (data.expGrowth.y/100.0)
	var div = pow(5.0, pow_i)
	for i in range(Actor.MAX_LEVEL):
		if i<=1:
			_expList[i] = 0
		else:
			var n = data.expGrowth.x * pow((i+3.0),pow_i) / div
			_expList[i] = _expList[i-1] + roundi(n)

func getLevelExp(l:int):
	if l < 1: return 0
	if l > Actor.MAX_LEVEL: return 0
	makeExpList()
	return _expList[l]
func getNextLvlExp():
	return getLevelExp(level+1)
func getRemainingNextLvlExp():
	return getLevelExp(level+1)-getLevelExp(level)

func equip(slotIdx:int, item:EquipItem):
	# Resize array if needed
	var _slotsData = Global.Db.equipSlots
	if(equips.size() < _slotsData.size()):
		equips.resize(_slotsData.size())
	# remove current item at slot, send back to inventory
	if(equips[slotIdx] != null):
		var oldEquip = equips[slotIdx]
		equips[slotIdx] = null
		Global.State.party.gainItem(oldEquip,1)
	# add new item into the slot
	if(item != null):
		# Can't equip
		if(canEquip(item) == false): return false
		# Wrong slot
		if(item.slot != _slotsData[slotIdx].kind): return false
		# Equip
		var newEquip = item.getId()
		equips[slotIdx] = newEquip
		Global.State.party.loseItem(newEquip,1)
func canEquip(equip:EquipItem)->bool:
	var a:Actor = getData()
	for flag in equip.flags:
		if a.equippableFlags.has(flag)==false:
			return false
	return true

func getData():
	if id=="": return null
	return Global.Db.getActor(id)

func _serialize():
	var savedata = {
		"id" : id,
		"name" : name,
		"level" : level,
		"position" : position,
		"exp" : exp,
		"currHP" : currHP,
		"currMP" : currMP,
		"states" : _serializeStates(),
		"equips" : equips
	}
	return savedata

func _serializeStates():
	var data = []
	for s in states:
		data.append(s._serialize())
	return data

func _deserialize(savedata : Dictionary):
	for key in savedata:
		match key:
			"equips":
				equips = savedata[key]
			_:
				set(key, savedata[key])

func _deserializeStates(data:Array):
	for s in data:
		var ss = StatusState.new()
		ss._deserialize(s)
		states.append(ss)
