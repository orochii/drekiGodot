extends GameBattler
class_name GameEnemy

func _init(_id:StringName):
	id = _id
	var enemy:Enemy = getData()
	level = enemy.level
	currHP = getMaxHP()
	currMP = getMaxMP()

func getName():
	var enemy:Enemy = getData()
	return enemy.getName()

func getFeatures():
	var enemy:Enemy = getData()
	var features = []
	# Base features
	features.append_array(enemy.features)
	# Status features
	for s in states:
		var data:Status = Global.Db.getStatus(s.id)
		features.append_array(data.features)
	# Passive skill features?
	# Return
	return features

func getBaseMaxHP():
	var enemy:Enemy = getData()
	return enemy.mhp
func getBaseMaxMP():
	var enemy:Enemy = getData()
	return enemy.mmp
func getBaseStr():
	var enemy:Enemy = getData()
	return enemy.str
func getBaseVit():
	var enemy:Enemy = getData()
	return enemy.vit
func getBaseMag():
	var enemy:Enemy = getData()
	return enemy.mag
func getBaseAgi():
	var enemy:Enemy = getData()
	return enemy.agi

func getData():
	return Global.Db.getEnemy(id)

func getInnateElement():
	return getData().innateElement

func getBattleGraphic():
	return getData().battleSprite
func getSmallFace():
	return getData().battleSprite

func isEnemy(other:GameBattler):
	if other is GameActor:
		return true
	return false

func getActionScriptList() -> Array[ActionScript]:
	var enemy:Enemy = getData()
	return enemy.actions
