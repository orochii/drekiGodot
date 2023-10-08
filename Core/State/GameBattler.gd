extends Object
class_name GameBattler

var id : StringName
var level : int = 1
var currHP : int
var currMP : int
var states : Array[StringName]

func getFeatures():
	return []

func getMaxHP():
	return applyFeatureStatChange(getBaseMaxHP(), Global.Stat.HP)
func getMaxMP():
	return applyFeatureStatChange(getBaseMaxMP(), Global.Stat.MP)
func getStr():
	return applyFeatureStatChange(getBaseStr(), Global.Stat.Str)
func getVit():
	return applyFeatureStatChange(getBaseVit(), Global.Stat.Vit)
func getMag():
	return applyFeatureStatChange(getBaseMag(), Global.Stat.Mag)
func getAgi():
	return applyFeatureStatChange(getBaseAgi(), Global.Stat.Agi)

func applyFeatureStatChange(base:int, stat : Global.Stat):
	var perc = 100
	var plus = 0
	var features = getFeatures()
	for f in features:
		if f is StatChangeFeature:
			var scf = f as StatChangeFeature
			if scf.stat == stat:
				if scf.kind == StatChangeFeature.Kind.PERC:
					perc += scf.amount
				else:
					plus += scf.amount
	return (base * perc / 100) + plus

func getBaseMaxHP():
	return 1
func getBaseMaxMP():
	return 1
func getBaseStr():
	return 1
func getBaseVit():
	return 1
func getBaseMag():
	return 1
func getBaseAgi():
	return 1

func getData():
	return null
