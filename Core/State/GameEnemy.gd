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
	return enemy.name

func getFeatures():
	var enemy:Enemy = getData()
	var features = []
	features.append_array(enemy.features)
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

func getBattleGraphic():
	return getData().battleSprite

func isEnemy(other:GameBattler):
	if other is GameActor:
		return true
	return false

func getActionScriptList() -> Array[ActionScript]:
	var enemy:Enemy = getData()
	return enemy.actions
