extends GameBattler
class_name GameActor

var exp : int
var equips : Array[StringName]

func _init(_id:StringName):
	id = _id
	var actor:Actor = getData()
	if (actor == null): return
	level = actor.startLevel
	currHP = getMaxHP()
	currMP = getMaxMP()

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

func getData():
	if id=="": return null
	return Global.Db.getActor(id)

func _serialize():
	var savedata = {
		"id" : id,
		"level" : level,
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
