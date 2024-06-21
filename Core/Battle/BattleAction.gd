extends Object
class_name BattleAction

var battler:Battler
var action:Resource #(Status, BaseSkill or BaseItem)
var kind:Global.ETargetKind
var scope:Global.ETargetScope
var targetIdx:int
# This must be set by the effects themselves, which sounds terrible
var targets:Array[Battler]=[]

# Don't set manually (except for maybe cleave)
var repeatIdx:int = 0
var totalRepeats:int = 0

func anyAllyOnTargets():
	for t in targets:
		if battler.battler.isEnemy(t.battler)==false:
			return true
	return false

func resolveCost():
	if action is UseableSkill:
		var skill = action as UseableSkill
		battler.battler.resolveSkillCost(skill)
		# reduce atb
		battler.atbValue -= skill.cpCost
	elif action is UseableItem:
		var item = action as UseableItem
		battler.battler.resolveItemCost(item)
		# reduce atb
		battler.atbValue -= item.cpCost

func selectSpecificTarget(t:Battler):
	var targetState = Global.ETargetState.ALIVE
	if action is Status:
		targetState = Global.ETargetState.ANY
	elif action is UseableSkill:
		var sk = action as UseableSkill
		targetState = sk.targetState
	elif action is UseableItem:
		var it = action as UseableItem
		targetState = it.targetState
	var ary = getTargetArray(targetState)
	if ary.size()==0: 
		targetIdx = 0
	else:
		targetIdx = ary.find(t)
		if targetIdx==-1:
			targetIdx = randi() % ary.size()
func selectRandomTarget():
	var targetState = Global.ETargetState.ALIVE
	if action is Status:
		targetState = Global.ETargetState.ANY
	elif action is UseableSkill:
		var sk = action as UseableSkill
		targetState = sk.targetState
	elif action is UseableItem:
		var it = action as UseableItem
		targetState = it.targetState
	var ary = getTargetArray(targetState)
	if ary.size()==0: 
		targetIdx = 0
	else:
		var _weightedAry = []
		for t in ary:
			match t.battler.getPosition():
				0:
					_weightedAry.append(t)
					_weightedAry.append(t)
					_weightedAry.append(t)
				1:
					_weightedAry.append(t)
		targetIdx = randi() % _weightedAry.size()

func setRepeats():
	totalRepeats = resolveRepeats()
	repeatIdx = 0
func repeatAvailable():
	return repeatIdx <= totalRepeats;
func advanceRepeat():
	repeatIdx += 1
func resolveRepeats() -> int: 
	if action is UseableSkill:
		var sk = action as UseableSkill
		return sk.repeats
	return 0
func unsetRepeats():
	repeatIdx = totalRepeats+1

func resolveActionList(type:int) -> Array[BaseEffect]:
	if action is UseableSkill:
		var sk = action as UseableSkill
		match type:
			0:
				return sk.startSequence
			1:
				return sk.actionSequence
			2:
				return sk.endSequence
	elif action is UseableItem:
		var it = action as UseableItem
		match type:
			0:
				return it.startSequence
			1:
				return it.actionSequence
			2:
				return it.endSequence
	elif action is Status:
		var st = action as Status
		return st.eotSequence
	return []

func resolveTargets() -> Array[Battler]:
	var targetState = Global.ETargetState.ALIVE
	if action is UseableSkill:
		var sk = action as UseableSkill
		targetState = sk.targetState
	elif action is UseableItem:
		var it = action as UseableItem
		targetState = it.targetState
	elif action is Status:
		targetState = Global.ETargetState.ANY
	var ary = getTargetArray(targetState)
	match scope:
		Global.ETargetScope.ALL:
			return ary
		Global.ETargetScope.ONE:
			if ary.size()==0: return []
			return [ary[targetIdx % ary.size()]]
		_:
			if ary.size()==0: return []
			var rndIdx = randi() % ary.size()
			return [ary[rndIdx]]

func getTargetArray(state:Global.ETargetState):
	var _originalTargets = _innerGetTargetArray(kind,state)
	if scope == Global.ETargetScope.ONE:
		if action is UseableSkill:
			var _skill = action as UseableSkill
			if _skill.targetCanChangeKind:
				match kind:
					Global.ETargetKind.ALLY:
						var _newTargets = _innerGetTargetArray(Global.ETargetKind.ENEMY,state)
						_originalTargets.append_array(_newTargets)
					Global.ETargetKind.ENEMY:
						var _newTargets = _innerGetTargetArray(Global.ETargetKind.ALLY,state)
						_originalTargets.append_array(_newTargets)
	return _originalTargets

func _innerGetTargetArray(kind:Global.ETargetKind,state:Global.ETargetState):
	# Invert kind if is i.e. confused
	if battler.battler.hasRestriction(Global.ERestriction.AttackAlly):
		match kind:
			Global.ETargetKind.ENEMY:
				kind = Global.ETargetKind.ALLY
			Global.ETargetKind.ALLY:
				kind = Global.ETargetKind.ENEMY
			Global.ETargetKind.ANY:
				kind = Global.ETargetKind.ALLY
	# Return the array of viable targets
	match kind:
		Global.ETargetKind.ENEMY:
			return battler.getEnemies(state)
		Global.ETargetKind.ALLY:
			return battler.getAllies(Global.ETargetState.ANY) # allies can be targeted no matter the state
		Global.ETargetKind.ANY:
			return battler.getAll(state)
		Global.ETargetKind.USER:
			return [battler]
		_:
			return []
