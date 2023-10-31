extends Object
class_name GameBattler

var id : StringName
var level : int = 1
var currHP : int
var currMP : int
var states : Array[StatusState]
var lastIndexes:Dictionary

func getLastIndex(tag:StringName):
	if lastIndexes.has(tag): return lastIndexes[tag]
	return null
func setLastIndex(tag:StringName,value):
	lastIndexes[tag] = value

func getSkills():
	return []

func getFeatures():
	return []

func changeHP(val:int):
	currHP = clampi(currHP + val, 0, getMaxHP())
	var deathStatus = Global.Db.getStatus("Death")
	if currHP == 0:
		# Add death
		addStatus(deathStatus,true)
	else:
		removeStatus(deathStatus)

func changeMP(val:int):
	currMP = clampi(currMP + val, 0, getMaxHP())
	var deathStatus = Global.Db.getStatus("Dry")
	if currMP == 0:
		# Add death
		addStatus(deathStatus,true)
	else:
		removeStatus(deathStatus)

func hasStatus(s:Status):
	var sid = s.getId()
	for ss in states:
		if ss.id == sid:
			return ss
	return null

func addStatus(s:Status,force:bool=false):
	var ss = hasStatus(s)
	var rate = getStatusRate(s)
	if (force || rate > randf()):
		if ss == null: # Doesn't have status
			ss = StatusState.new()
			ss.id = s.getId()
			ss.turns = 0
			ss.stack = 1
			states.append(ss)
		else: # Does have status
			ss.stack = clampi(ss.stack+1, 1, 3)
		for rs in s.statusRemove:
			removeStatus(rs)

func removeStatus(s:Status):
	var ss = hasStatus(s)
	if ss != null:
		states.erase(ss)

func getStatusRate(s:Status):
	var rate = 1.0
	var features = getFeatures()
	for f in features:
		if f is StatusAffinityFeature:
			var statusAffinityFeature = f as StatusAffinityFeature
			if statusAffinityFeature.status == s:
				rate *= statusAffinityFeature.getEffect()
	return rate

func getSortedStates():
	var ary:Array[StatusState] = []
	ary.append_array(states)
	ary.sort_custom(_sort_states_by_priority)
	return ary

func _sort_states_by_priority(a:StatusState, b:StatusState):
	# If true, b will be after
	var aData = Global.Db.getStatus(a.id)
	var bData = Global.Db.getStatus(b.id)
	if aData.displayRating > bData.displayRating:
		return true
	return false

func getName():
	return ""
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
func getPhyAbs():
	return applyFeatureStatChange(0, Global.Stat.PhyAbs)
func getMagAbs():
	return applyFeatureStatChange(0, Global.Stat.MagAbs)

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

func getBattleGraphic():
	return null
func getSmallFace():
	return null

func isDead():
	#for s in states:
	#	var data:Status = Global.Db.getStatus(s.id)
	#	if (data.flags & Global.EStatusFlags.INCAPACITATED) != 0: return false
	return currHP == 0

func inputable():
	for s in states:
		var data:Status = Global.Db.getStatus(s.id)
		if data.restriction >= Global.ERestriction.AttackAnyone: return false
	return true
func canAct():
	for s in states:
		var data:Status = Global.Db.getStatus(s.id)
		if data.restriction >= Global.ERestriction.CantMove: return false
	return true
func hasRestriction(r:Global.ERestriction):
	for s in states:
		var data:Status = Global.Db.getStatus(s.id)
		if data.restriction == r: return true
	return false

func automatic():
	return true
func isEnemy(other:GameBattler):
	return false

func getActionScriptList() -> Array[ActionScript]:
	return [ActionScript.new()]
func pickActionScript() -> ActionScript:
	var actions = getActionScriptList()
	if actions.size() == 0:
		return null
	var validActions:Array[ActionScript] = []
	var maxPriority = 0
	for a in actions:
		var valid = true
		for c in a.conditions:
			if !c.evaluate():
				valid = false
				break
		if valid:
			validActions.append(a)
			if(maxPriority < a.priority): maxPriority = a.priority
	var minPriority = maxPriority - 3
	var prioritizedActions:Array[ActionScript] = []
	for a in validActions:
		if a.priority >= minPriority: prioritizedActions.append(a)
	var rIdx = randi()%prioritizedActions.size()
	return prioritizedActions[rIdx]

func getPosition() -> int:
	return 0
