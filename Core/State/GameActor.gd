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

func getFeatures():
	var actor:Actor = getData()
	var features = []
	features.append_array(actor.features)
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
		"states" : states,
		"equips" : equips
	}
	return savedata

func _deserialize(savedata : Dictionary):
	for key in savedata:
		set(key, savedata[key])
