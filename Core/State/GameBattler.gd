extends Object
class_name GameBattler

const DEATH_STATUS = "Death"
const DRY_STATUS = "Dry"

var id : StringName
var level : int = 1
var currHP : int
var currMP : int
var states : Array[StatusState]
var lastIndexes:Dictionary
var skillConditions:Dictionary
var _cachedFeatures = null
var _cachedStatistics = null

func advanceSkillConditions():
	for key in skillConditions:
		var cd = getSkillCooldown(key)
		if cd > 0:
			setSkillCooldown(key, cd-1)
func getSkillCooldown(id:StringName):
	if skillConditions.has(id):
		var s = skillConditions[id]
		if s.has("cooldown"):
			return s["cooldown"]
	return 0
func getSkillChargesSpent(id:StringName):
	if skillConditions.has(id):
		var s = skillConditions[id]
		if s.has("chargesSpent"):
			return s["chargesSpent"]
	return 0
func setSkillCooldown(id:StringName,cooldown:int):
	if !skillConditions.has(id): skillConditions[id] = {}
	var s = skillConditions[id]
	s["cooldown"] = cooldown
	skillConditions[id] = s
func addSkillChargesSpent(id:StringName):
	if !skillConditions.has(id): skillConditions[id] = {}
	var s = skillConditions[id]
	if s.has("chargesSpent"):
		s["chargesSpent"] += 1
	else:
		s["chargesSpent"] = 1
	skillConditions[id] = s
func resetSkillCooldowns():
	for id in skillConditions:
		skillConditions[id].erase("cooldown")
func resetAllSkills():
	skillConditions[id] = {}

func getLastIndex(tag:StringName):
	if lastIndexes.has(tag): return lastIndexes[tag]
	return null
func setLastIndex(tag:StringName,value):
	lastIndexes[tag] = value

func getSkills():
	return []

func hasAirJuggling():
	var fs = getFeatures()
	for f in fs:
		if f is AirJugglingFeature:
			return true
	return false

func isFlying():
	var fs = getFeatures()
	for f in fs:
		if f is FlyingFeature:
			return true
	return false

func getFeatures():
	if _cachedFeatures==null: recreateFeatureCache()
	return _cachedFeatures
func recreateFeatureCache():
	_cachedFeatures = []

func changeHP(val:int):
	currHP = clampi(currHP + val, 0, getMaxHP())
	var deathStatus = Global.Db.getStatus(DEATH_STATUS)
	if currHP == 0:
		# Add death
		addStatus(deathStatus,true)
	else:
		removeStatus(deathStatus)
	Global.UI.onHpChange.emit(self,false)

func changeMP(val:int):
	currMP = clampi(currMP + val, 0, getMaxMP())
	var deathStatus = Global.Db.getStatus(DRY_STATUS)
	if currMP == 0:
		# Add death
		addStatus(deathStatus,true)
	else:
		removeStatus(deathStatus)
	Global.UI.onMpChange.emit(self,false)

func recoverAll():
	currHP = getMaxHP()
	currMP = getMaxMP()
	states.clear()
	resetAllSkills()

func hasStatus(s:Status):
	var sid = s.getId()
	for ss in states:
		if ss.id == sid:
			return ss
	return null

func addStatus(s:Status,force:bool=false,noFeatureCache:bool=false):
	var ss = hasStatus(s)
	var rate = getStatusRate(s)
	if (force || rate > randf()):
		if ss == null: # Doesn't have status
			ss = StatusState.new()
			ss.id = s.getId()
			ss.turns = 0
			ss.stack = 1
			states.append(ss)
			if s.getId()==DEATH_STATUS:
				currHP = 0
			if s.getId()==DRY_STATUS:
				currMP = 0
		else: # Does have status
			ss.stack = clampi(ss.stack+1, 1, 3)
		for rs in s.statusRemove:
			var _status:Status = Global.Db.getStatus(rs)
			removeStatus(_status,true)
	if noFeatureCache==false: 
		recreateFeatureCache()
		Global.UI.onStatusChange.emit(self)
	return true

func removeStatus(s:Status,noFeatureCache:bool=false):
	var ss = hasStatus(s)
	if ss != null:
		states.erase(ss)
		if noFeatureCache==false: 
			recreateFeatureCache()
			Global.UI.onStatusChange.emit(self)
		return true
	return false

func getStatusRate(s:Status):
	var rate = -1.0
	var features = getFeatures()
	for f in features:
		if f is StatusAffinityFeature:
			var statusAffinityFeature = f as StatusAffinityFeature
			if statusAffinityFeature.status == s:
				var _fRate = statusAffinityFeature.getEffect()
				if rate < 0:
					rate = _fRate
				else:
					rate *= _fRate
	if rate < 0: return StatusAffinityFeature.RANK_EFFECT[2]
	return rate

func getElementSetRate(_set:Array[Global.Element]):
	if _set.size()==0: return 1
	var weaponRate = 0.0
	var magicRate = 1.0
	for e in _set:
		var rate = getElementRate(e)
		if ElementAffinityFeature.WEAPON_ELEMENTS.has(e):
			# Weapon element
			if weaponRate < rate: weaponRate = rate
		else:
			# Magic element
			magicRate *= rate
	var totalRate = weaponRate + magicRate
	if(weaponRate > 0): totalRate /= 2
	return totalRate

func getElementRate(e:Global.Element):
	var rate = getInnateElementRate(e)
	var features = getFeatures()
	for f in features:
		if f is ElementAffinityFeature:
			var elementAffinityFeature = f as ElementAffinityFeature
			if elementAffinityFeature.element == e:
				rate *= elementAffinityFeature.getEffect()
	return rate
func getInnateElement():
	return Global.Element.NONE
func getInnateElementRank(element:Global.Element):
	var innate = getInnateElement()
	for inn in Global.Db.innateElementRelations:
		if inn.id==innate:
			for relation in inn.relations:
				if relation.element==element:
					return relation.rank
	return Global.Rank.C
func getInnateElementRate(element:Global.Element):
	var rank = getInnateElementRank(element)
	var eaf = ElementAffinityFeature.new()
	eaf.element = element
	eaf.value = rank
	var _rate = eaf.getEffect()
	return _rate
func getAffinityRates():
	var elementRanks = {}
	var stateRanks = {}
	for element in Global.Element.values():
		var i = getInnateElementRate(element)
		elementRanks[element] = [i,i]
	var fs = getFeatures()
	for f in fs:
		if f is ElementAffinityFeature:
			var e = f as ElementAffinityFeature
			if !e.resource_path.contains("res://Data/Status/"):
				elementRanks[e.element][0] *= e.getEffect()
			elementRanks[e.element][1] *= e.getEffect()
		if f is StatusAffinityFeature:
			var s = f as StatusAffinityFeature
			var id = s.status.getId()
			if !stateRanks.has(id):
				stateRanks[id] = [2,2]
			if !s.resource_path.contains("res://Data/Status/"):
				stateRanks[id][0] *= s.getEffect()
			stateRanks[id][1] *= s.getEffect()
	return [elementRanks,stateRanks]

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

func removeStatesUponDamage():
	var toRemove = []
	for s in states:
		var d:Status = Global.Db.getStatus(s.id)
		var r = randf()
		if r < d.releaseOnDamageReceived:
			toRemove.append(s)
	for s in toRemove: states.erase(s)
func removeStatesAtBattleEnd():
	var toRemove = []
	for s in states:
		var d:Status = Global.Db.getStatus(s.id)
		if d.releaseAtBattleEnd: toRemove.append(s)
	for s in toRemove: states.erase(s)
func advanceStatesTurn():
	var toRemove = []
	for s in states:
		var d:Status = Global.Db.getStatus(s.id)
		s.turns += 1
		if s.turns >= d.releaseOnTurnsElapsed:
			var r = randf()
			if r < d.releaseOnTurnsElapsedRate:
				toRemove.append(s)
	for s in toRemove: states.erase(s)

func getName():
	return ""
func getDesc():
	return getData().getDesc()
func getMaxHP():
	return getCachedStatistic(Global.Stat.HP)
func getMaxMP():
	return getCachedStatistic(Global.Stat.MP)
func getStr():
	return getCachedStatistic(Global.Stat.Str)
func getVit():
	return getCachedStatistic(Global.Stat.Vit)
func getMag():
	return getCachedStatistic(Global.Stat.Mag)
func getAgi():
	return getCachedStatistic(Global.Stat.Agi)
func getAtk():
	return getCachedStatistic(Global.Stat.Atk)
func getPhyAbs():
	return getCachedStatistic(Global.Stat.PhyAbs)
func getMagAbs():
	return getCachedStatistic(Global.Stat.MagAbs)

func getCachedStatistic(stat : Global.Stat):
	if _cachedStatistics == null: regenCachedStatistics()
	return _cachedStatistics[stat]
func regenCachedStatistics():
	var _oldStatistics = _cachedStatistics
	_cachedStatistics = {
		Global.Stat.HP : applyFeatureStatChange(getBaseMaxHP(), Global.Stat.HP),
		Global.Stat.MP : applyFeatureStatChange(getBaseMaxMP(), Global.Stat.MP),
		Global.Stat.Str : applyFeatureStatChange(getBaseStr(), Global.Stat.Str),
		Global.Stat.Vit : applyFeatureStatChange(getBaseVit(), Global.Stat.Vit),
		Global.Stat.Mag : applyFeatureStatChange(getBaseMag(), Global.Stat.Mag),
		Global.Stat.Agi : applyFeatureStatChange(getBaseAgi(), Global.Stat.Agi),
		Global.Stat.Atk : applyFeatureStatChange(0, Global.Stat.Atk),
		Global.Stat.PhyAbs : applyFeatureStatChange(0, Global.Stat.PhyAbs),
		Global.Stat.MagAbs : applyFeatureStatChange(0, Global.Stat.MagAbs),
	}
	if _oldStatistics != null && !_oldStatistics.is_empty():
		for s in _oldStatistics:
			match s:
				Global.Stat.HP:
					if _oldStatistics[s] != _cachedStatistics[s]:
						Global.UI.onHpChange.emit(self,true)
				Global.Stat.MP:
					if _oldStatistics[s] != _cachedStatistics[s]:
						Global.UI.onMpChange.emit(self,true)

func applyFeatureStatChange(base:int, stat : Global.Stat):
	var perc = 1.0
	var plus = 0
	var features = getFeatures()
	for f in features:
		if f is StatChangeFeature:
			var scf = f as StatChangeFeature
			var _stack = getResourceStatusLevel(scf)
			var _amount = StatChangeFeature.getStackModAmount(scf.kind, _stack, scf.amount)
			if scf.stat == stat:
				if scf.kind == StatChangeFeature.Kind.PERC:
					perc += _amount
				else:
					plus += _amount
	return roundi(base * perc) + plus

func getResourceStatusLevel(res:Resource):
	var _path = res.resource_path
	if _path.contains("res://Data/Status/"):
		var _id = Status.stripId(_path)
		var _status = Global.Db.getStatus(_id)
		if _status != null:
			var ss:StatusState = hasStatus(_status)
			if ss != null:
				return ss.stack
	return 1

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
func getHitRate():
	var _hit = 1.0
	var features = getFeatures()
	for f in features:
		if f is HitRateFeature:
			_hit += f.amount
	return _hit
func getEvasion():
	var _eva = 0.0
	var features = getFeatures()
	for f in features:
		if f is EvasionFeature:
			_eva += f.evasion
	return _eva

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

func canGetExp():
	for s in states:
		var data:Status = Global.Db.getStatus(s.id)
		if (data.flags & Global.EStatusFlags.NO_EXP) != 0: return false
	return true

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
func pickActionScript(battle:BattleManager) -> ActionScript:
	var actions = getActionScriptList()
	if actions.size() == 0:
		return null
	var validActions:Array[ActionScript] = []
	var maxPriority = 0
	for a in actions:
		var valid = true
		for c in a.conditions:
			if c != null && !c.evaluate(self,battle):
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
func setPosition(v:int):
	pass

func canUse(action:Resource):
	if action is UseableSkill:
		var skill = action as UseableSkill
		# MP Cost
		var mpCost = skill.getMPCost(self)
		if mpCost > currMP: return false
		var hpCost = skill.getHPCost(self)
		if hpCost > currHP: return false
		# cooldown
		var skId = skill.getId()
		if skill.cooldown != 0:
			var cd = getSkillCooldown(skId)
			if cd > 0: return false
		# charges left
		if skill.charges != 0:
			var ch = getSkillChargesSpent(skId)
			if ch >= skill.charges: return false
	elif action is UseableItem:
		var item = action as UseableItem
		var itId = item.getId()
		var count = Global.State.party.itemCount(itId)
		if count <= 0: return false
	else:
		return false
	return true

func resolveSkillCost(skill,battle=true):
	# take off MP
	var mpCost = skill.getMPCost(self)
	var hpCost = skill.getHPCost(self)
	self.changeMP(-mpCost)
	self.changeHP(-hpCost)
	# set cooldown
	var skId = skill.getId()
	if battle:
		if skill.cooldown != 0:
			self.setSkillCooldown(skId, skill.cooldown+1)
	# add spent charge
	if skill.charges != 0:
		self.addSkillChargesSpent(skId)
	return true

func resolveItemCost(item):
	# remove 1 of item on chance
	var r = randf()
	if (r < item.spendOnUseChance):
		Global.State.party.loseItem(item.getId(), 1)
		return true
	return false

func getDefaultSkill(i):
	return Global.Db.defaultAttackSkills[0] as UseableSkill

func stateConditionMet(state:Global.ETargetState):
	if state==Global.ETargetState.ANY: return true
	return (state==Global.ETargetState.DEAD) == isDead()
